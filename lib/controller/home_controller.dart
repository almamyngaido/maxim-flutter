import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/user_utils.dart';

class HomeController extends GetxController {
  TextEditingController searchController = TextEditingController();
  RxList<bool> isTrendPropertyLiked = <bool>[].obs;
  String? userId;
  RxString userName = 'Guest'.obs;
  final storage = GetStorage();
  Map<String, dynamic>? userData;

  // User properties
  RxList<Map<String, dynamic>> userProperties = <Map<String, dynamic>>[].obs;
  RxBool isLoadingProperties = false.obs;
  RxInt totalProperties = 0.obs;

  // All properties (from all users)
  RxList<Map<String, dynamic>> allProperties = <Map<String, dynamic>>[].obs;
  RxBool isLoadingAllProperties = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser().then((_) {
      // Load user properties after user data is fetched
      loadUserProperties();
    });
    // Load all properties for the recommended section
    loadAllProperties();
    // Load user data using utility function (handles both Map and JSON formats)
    userData = loadUserData();
    print('👤 User data in HomeController: $userData');
    // Initialize the like status for trend properties
    isTrendPropertyLiked.value = List<bool>.filled(10, false);
  }

  Future<void> fetchCurrentUser() async {
    try {
      String? token = storage.read('authToken');
      print('Retrieved token in HomeController: $token'); // Debug

      if (token == null || token.isEmpty) {
        print('No token found, redirecting to login');
        // Wait for the first frame to complete before navigating
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar('Error', 'No token found. Please log in.');
          Get.offNamed(AppRoutes.loginView);
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Response from /me: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        // Store as JSON string to avoid type errors
        await storage.write('userData', jsonEncode(userData));
        userId = userData['id']?.toString();
        userName.value = userData['prenom']?.isNotEmpty == true
            ? userData['prenom']
            : userData['nom'] ?? 'Guest';
        print('👤 User name set to: ${userName.value}');
        print('🆔 User ID set to: $userId');
      } else {
        print(
            'Failed to fetch user: ${response.statusCode} ${response.reasonPhrase}');
        if (response.statusCode == 401) {
          storage.remove('authToken');
          // Wait for the first frame to complete before navigating
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.snackbar('Error', 'Session expirée. Veuillez vous reconnecter.');
            Get.offNamed(AppRoutes.loginView);
          });
        } else {
          Get.snackbar('Error', 'Failed to fetch user: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      print('Network error in fetchCurrentUser: $e');
      Get.snackbar('Error', 'Network error: $e');
    }
  }

  /// Load user's properties from API
  Future<void> loadUserProperties() async {
    try {
      isLoadingProperties.value = true;
      String? token = storage.read('authToken');

      if (token == null || token.isEmpty) {
        print('❌ No token found for loading properties');
        return;
      }

      // First, ensure we have the userId
      if (userId == null || userId!.isEmpty) {
        print('⏳ Waiting for userId to be loaded...');
        // Wait a bit for userId to be set by fetchCurrentUser
        await Future.delayed(Duration(milliseconds: 500));
        if (userId == null || userId!.isEmpty) {
          print('❌ Still no userId available');
          return;
        }
      }

      print('🔍 Loading properties for user: $userId');

      // Use the correct endpoint with filter and include owner data
      final filter = {
        "where": {"utilisateurId": userId},
        'include': [
          {
            'relation': 'utilisateur',
            'scope': {
              'fields': ['id', 'nom', 'prenom', 'email', 'phoneNumber', 'role']
            }
          }
        ]
      };

      final url = '${ApiConfig.baseUrl}/bien-immos?filter=${jsonEncode(filter)}';
      print('📡 Fetching from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🏠 User Properties API Response Status: ${response.statusCode}');
      print('🏠 User Properties API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> properties = jsonDecode(response.body);
        userProperties.value = properties.cast<Map<String, dynamic>>();
        totalProperties.value = userProperties.length;
        print('✅ Loaded ${totalProperties.value} properties');

        // Log first property details for debugging
        if (userProperties.isNotEmpty) {
          final firstProperty = userProperties.first;
          print('📸 First property images: ${firstProperty['listeImages']}');
          print('💰 First property price: ${firstProperty['prix']}');
          print('🏷️ First property type: ${firstProperty['typeBien']}');
        }
      } else {
        print('❌ Failed to load properties: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error loading user properties: $e');
      print('❌ Stack trace: ${StackTrace.current}');
    } finally {
      isLoadingProperties.value = false;
    }
  }

  /// Load all properties from all users
  Future<void> loadAllProperties() async {
    try {
      isLoadingAllProperties.value = true;
      String? token = storage.read('authToken');

      if (token == null || token.isEmpty) {
        print('❌ No token found for loading all properties');
        return;
      }

      print('🌍 Loading all properties from all users...');

      // Add filter to include utilisateur relation
      final filter = {
        'include': [
          {
            'relation': 'utilisateur',
            'scope': {
              'fields': ['id', 'nom', 'prenom', 'email', 'phoneNumber', 'role']
            }
          }
        ]
      };

      final url = '${ApiConfig.baseUrl}/bien-immos?filter=${jsonEncode(filter)}';
      print('📡 Fetching from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🌍 All Properties API Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> properties = jsonDecode(response.body);
        allProperties.value = properties.cast<Map<String, dynamic>>();
        print('✅ Loaded ${allProperties.length} properties from all users');

        // Log first few properties for debugging
        if (allProperties.isNotEmpty) {
          print('📊 First property: ${allProperties.first['typeBien']} - ${allProperties.first['prix']?['hai']} €');
          print('👤 First property owner: ${allProperties.first['utilisateur'] != null ? allProperties.first['utilisateur']['prenom'] + " " + allProperties.first['utilisateur']['nom'] : "No owner data"}');
        }
      } else {
        print('❌ Failed to load all properties: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error loading all properties: $e');
    } finally {
      isLoadingAllProperties.value = false;
    }
  }

  // Charger les données utilisateur depuis le storage
// Map<String, dynamic>? _loadUserData() {
//     try {
//       final userData = storage.read('userData');
//       if (userData != null) {
//         userId = userData['id']?.toString();
//       return Map<String, dynamic>.from(userData);
//       } else {
//         return null;
//       }
//     } catch (e) {
//       print("Erreur chargement userData: $e");
//     }
//   }

  // Toggle du like pour les propriétés
  void toggleLike(int index) {
    if (index < isTrendPropertyLiked.length) {
      isTrendPropertyLiked[index] = !isTrendPropertyLiked[index];
      print("Property $index liked: ${isTrendPropertyLiked[index]}");
    }
  }

  /// Reset controller state to defaults
  ///
  /// Called during logout to ensure clean state for next login
  void reset() {
    isTrendPropertyLiked.value = List<bool>.filled(10, false);
    userId = null;
    userName.value = 'Guest';
    userData = null;
    searchController.clear();
    userProperties.clear();
    totalProperties.value = 0;
    allProperties.clear();
    print('🔄 HomeController reset');
  }

  RxList<String> projectImageList = [
    Assets.images.project1.path,
    Assets.images.project2.path,
    Assets.images.project1.path,
  ].obs;

  RxList<String> projectPriceList = [
    AppString.rupees4Cr,
    AppString.priceOnRequest,
    AppString.priceOnRequest,
  ].obs;

  RxList<String> projectTitleList = [
    AppString.residentialApart,
    AppString.residentialApart2,
    AppString.plot2000ft,
  ].obs;

  RxList<String> projectAddressList = [
    AppString.address1,
    AppString.address2,
    AppString.address3,
  ].obs;

  RxList<String> projectTimingList = [
    AppString.days2Ago,
    AppString.month2Ago,
    AppString.month2Ago,
  ].obs;

  RxList<String> project2ImageList = [
    Assets.images.project3.path,
    Assets.images.project4.path,
    Assets.images.project3.path,
  ].obs;

  RxList<String> project2PriceList = [
    AppString.rupees2Cr,
    AppString.rupees5Cr,
    AppString.rupees2Cr,
  ].obs;

  RxList<String> project2TitleList = [
    AppString.residentialApart,
    AppString.plot2000ft,
    AppString.residentialApart,
  ].obs;

  RxList<String> project2AddressList = [
    AppString.address4,
    AppString.address5,
    AppString.address4,
  ].obs;

  RxList<String> project2TimingList = [
    AppString.days2Ago,
    AppString.month2Ago,
    AppString.days2Ago,
  ].obs;

  RxList<String> responseImageList = [
    Assets.images.response1.path,
    Assets.images.response2.path,
    Assets.images.response3.path,
    Assets.images.response4.path,
  ].obs;

  RxList<String> responseNameList = [
    AppString.rudraProperties,
    AppString.claudeAnderson,
    AppString.rohitBhati,
    AppString.heerKher,
  ].obs;

  RxList<String> responseTimingList = [
    AppString.today,
    AppString.today,
    AppString.yesterday,
    AppString.days4Ago,
  ].obs;

  RxList<String> responseEmailList = [
    AppString.rudraEmail,
    AppString.rudraEmail,
    AppString.rudraEmail,
    AppString.heerEmail,
  ].obs;

  RxList<String> searchImageList = [
    Assets.images.searchProperty1.path,
    Assets.images.searchProperty2.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.semiModernHouse,
    AppString.modernHouse,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.address6,
    AppString.address7,
  ].obs;

  RxList<String> searchRupeesList = [
    AppString.rupees58Lakh,
    AppString.rupees22Lakh,
  ].obs;

  RxList<String> searchPropertyImageList = [
    Assets.images.bath.path,
    Assets.images.bed.path,
    Assets.images.plot.path,
  ].obs;

  RxList<String> searchPropertyTitleList = [
    AppString.point2,
    AppString.point1,
    AppString.sq456,
  ].obs;

  RxList<String> popularBuilderImageList = [
    Assets.images.builder1.path,
    Assets.images.builder2.path,
    Assets.images.builder3.path,
    Assets.images.builder4.path,
    Assets.images.builder5.path,
    Assets.images.builder6.path,
  ].obs;

  RxList<String> popularBuilderTitleList = [
    AppString.sobhaDevelopers,
    AppString.kalpataru,
    AppString.godrej,
    AppString.unitech,
    AppString.casagrand,
    AppString.brigade,
  ].obs;

  RxList<String> upcomingProjectImageList = [
    Assets.images.upcomingProject1.path,
    Assets.images.upcomingProject2.path,
    Assets.images.upcomingProject3.path,
  ].obs;

  RxList<String> upcomingProjectTitleList = [
    AppString.luxuryVilla,
    AppString.shreenathjiResidency,
    AppString.pramukhDevelopersSurat,
  ].obs;

  RxList<String> upcomingProjectAddressList = [
    AppString.address8,
    AppString.address9,
    AppString.address10,
  ].obs;

  RxList<String> upcomingProjectFlatSizeList = [
    AppString.bhk3Apartment,
    AppString.bhk4Apartment,
    AppString.bhk5Apartment,
  ].obs;

  RxList<String> upcomingProjectPriceList = [
    AppString.lakh45,
    AppString.lakh85,
    AppString.lakh85,
  ].obs;

  RxList<String> popularCityImageList = [
    Assets.images.city1.path,
    Assets.images.city2.path,
    Assets.images.city3.path,
    Assets.images.city4.path,
    Assets.images.city5.path,
    Assets.images.city6.path,
    Assets.images.city7.path,
  ].obs;

  RxList<String> popularCityTitleList = [
    AppString.mumbai,
    AppString.newDelhi,
    AppString.gurgaon,
    AppString.noida,
    AppString.bangalore,
    AppString.ahmedabad,
    AppString.kolkata,
  ].obs;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }
}
