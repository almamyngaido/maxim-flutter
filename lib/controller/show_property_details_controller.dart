import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class ShowPropertyDetailsController extends GetxController {
  final storage = GetStorage();

  // UI State
  RxBool isExpanded = false.obs;
  RxInt selectAgent = 0.obs;
  RxBool isChecked = false.obs;
  RxInt selectProperty = 0.obs;
  RxBool isVisitExpanded = false.obs;
  String truncatedText = AppString.aboutPropertyString.substring(0, 200);

  // Focus and Input States
  RxBool hasFullNameFocus = false.obs;
  RxBool hasFullNameInput = false.obs;
  RxBool hasPhoneNumberFocus = true.obs;
  RxBool hasPhoneNumberInput = true.obs;
  RxBool hasEmailFocus = false.obs;
  RxBool hasEmailInput = false.obs;

  // Focus Nodes
  FocusNode focusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();

  // Text Controllers
  TextEditingController fullNameController =
      TextEditingController(text: AppString.francisZieme);
  TextEditingController mobileNumberController =
      TextEditingController(text: AppString.francisZiemeNumber);
  TextEditingController emailController =
      TextEditingController(text: AppString.francisZiemeEmail);

  // Property Data
  RxMap<String, dynamic> propertyData = <String, dynamic>{}.obs;
  RxBool isLoadingProperty = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  // Scroll Controller
  ScrollController scrollController = ScrollController();
  RxDouble selectedOffset = 0.0.obs;
  RxBool showBottomProperty = false.obs;

  // Similar Properties
  RxList<bool> isSimilarPropertyLiked = <bool>[].obs;

  @override
  void onInit() {
    super.onInit();

    // Get property ID from navigation arguments
    final String? propertyId = Get.arguments as String?;

    if (propertyId != null && propertyId.isNotEmpty) {
      loadPropertyData(propertyId);
    } else {
      hasError.value = true;
      errorMessage.value = 'ID de propriété manquant';
    }

    // Setup focus listeners
    _setupFocusListeners();

    // Setup text controller listeners
    _setupTextControllerListeners();
  }

  void _setupFocusListeners() {
    focusNode.addListener(() {
      hasFullNameFocus.value = focusNode.hasFocus;
    });

    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });

    emailFocusNode.addListener(() {
      hasEmailFocus.value = emailFocusNode.hasFocus;
    });
  }

  void _setupTextControllerListeners() {
    fullNameController.addListener(() {
      hasFullNameInput.value = fullNameController.text.isNotEmpty;
    });

    mobileNumberController.addListener(() {
      hasPhoneNumberInput.value = mobileNumberController.text.isNotEmpty;
    });

    emailController.addListener(() {
      hasEmailInput.value = emailController.text.isNotEmpty;
    });
  }

  /// Load property data from API
  Future<void> loadPropertyData(String propertyId) async {
    try {
      isLoadingProperty.value = true;
      hasError.value = false;
      errorMessage.value = '';

      String? token = storage.read('authToken');

      final response = await http.get(
        Uri.parse('${AppString.apiBaseUrl}/bien-immos/$propertyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Property Details API Response Status: ${response.statusCode}');
      print('Property Details API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        propertyData.value = data;

        print('✅ Property data loaded successfully');
      } else {
        throw Exception(
            'Échec du chargement de la propriété: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading property data: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoadingProperty.value = false;
    }
  }

  /// Helper methods to extract property information
  String get propertyTitle {
    try {
      if (propertyData['description'] != null &&
          propertyData['description']['titre'] != null &&
          propertyData['description']['titre'].toString().isNotEmpty) {
        return propertyData['description']['titre'].toString();
      }

      String type = propertyData['typeBien']?.toString() ?? 'Bien immobilier';
      int rooms = propertyData['nombrePiecesTotal']?.toInt() ?? 0;

      if (rooms > 0) {
        return '$type ${rooms}P';
      }

      return type;
    } catch (e) {
      return 'Bien immobilier';
    }
  }

  String get propertyAddress {
    try {
      if (propertyData['localisation'] == null) {
        return 'Adresse non spécifiée';
      }

      Map<String, dynamic> localisation = propertyData['localisation'];
      List<String> addressParts = [];

      if (localisation['rue'] != null &&
          localisation['rue'].toString().isNotEmpty) {
        addressParts.add(localisation['rue'].toString());
      }

      if (localisation['ville'] != null &&
          localisation['ville'].toString().isNotEmpty) {
        addressParts.add(localisation['ville'].toString());
      }

      if (localisation['codePostal'] != null &&
          localisation['codePostal'].toString().isNotEmpty) {
        addressParts.add(localisation['codePostal'].toString());
      }

      return addressParts.isNotEmpty
          ? addressParts.join(', ')
          : 'Adresse non spécifiée';
    } catch (e) {
      return 'Adresse non spécifiée';
    }
  }

  String get propertyPrice {
    try {
      if (propertyData['prix'] != null && propertyData['prix']['hai'] != null) {
        double price = propertyData['prix']['hai'].toDouble();

        if (price >= 1000000) {
          return '${(price / 1000000).toStringAsFixed(1)}M €';
        } else if (price >= 1000) {
          return '${(price / 1000).toStringAsFixed(0)}K €';
        } else {
          return '${price.toStringAsFixed(0)} €';
        }
      }

      return 'Prix sur demande';
    } catch (e) {
      return 'Prix sur demande';
    }
  }

  String get propertyType {
    return propertyData['typeBien']?.toString() ?? 'Non spécifié';
  }

  int get numberOfRooms {
    return propertyData['nombrePiecesTotal']?.toInt() ?? 0;
  }

  String get propertyStatus {
    return propertyData['statut']?.toString() ?? 'Non spécifié';
  }

  String get propertyDescription {
    try {
      if (propertyData['description'] != null &&
          propertyData['description']['annonce'] != null &&
          propertyData['description']['annonce'].toString().isNotEmpty) {
        return propertyData['description']['annonce'].toString();
      }
      return AppString.aboutPropertyString; // Fallback to default description
    } catch (e) {
      return AppString.aboutPropertyString;
    }
  }

  Map<String, dynamic> get surfaces {
    try {
      return propertyData['surfaces'] ?? {};
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> get characteristics {
    try {
      return propertyData['caracteristiques'] ?? {};
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> get heating {
    try {
      return propertyData['chauffageClim'] ?? {};
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> get energy {
    try {
      return propertyData['energie'] ?? {};
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> get building {
    try {
      return propertyData['batiment'] ?? {};
    } catch (e) {
      return {};
    }
  }

  Map<String, dynamic> get energyDiagnostics {
    try {
      return propertyData['diagnosticsEnergie'] ?? {};
    } catch (e) {
      return {};
    }
  }

  List<dynamic> get pieces {
    try {
      return propertyData['pieces'] ?? [];
    } catch (e) {
      return [];
    }
  }

  List<String> get propertyImages {
    try {
      if (propertyData['listeImages'] != null &&
          propertyData['listeImages'] is List &&
          (propertyData['listeImages'] as List).isNotEmpty) {
        return (propertyData['listeImages'] as List).cast<String>();
      }
      return [Assets.images.property3.path]; // Fallback image
    } catch (e) {
      return [Assets.images.property3.path];
    }
  }

  String get primaryImage {
    final images = propertyImages;
    return images.isNotEmpty ? images.first : Assets.images.property3.path;
  }

  /// UI interaction methods
  void toggleVisitExpansion() {
    isVisitExpanded.value = !isVisitExpanded.value;
  }

  void updateAgent(int index) {
    selectAgent.value = index;
  }

  void toggleCheckbox() {
    isChecked.toggle();
  }

  void updateProperty(int index) {
    selectProperty.value = index;
  }

  /// Refresh property data
  Future<void> refreshPropertyData() async {
    final String? propertyId = Get.arguments as String?;
    if (propertyId != null && propertyId.isNotEmpty) {
      await loadPropertyData(propertyId);
    }
  }

  // Static data for UI elements (keeping existing static lists)
  RxList<String> searchPropertyImageList = [
    Assets.images.bath.path,
    Assets.images.bed.path,
    Assets.images.plot.path,
  ].obs;

  RxList<String> searchPropertyTitleList = [
    AppString.point3,
    AppString.point3,
    AppString.bhk4,
  ].obs;

  RxList<String> searchProperty2ImageList = [
    Assets.images.plot.path,
    Assets.images.indianRupee.path,
  ].obs;

  RxList<String> searchProperty2TitleList = [
    AppString.squareFeet1000,
    AppString.rupee3005,
  ].obs;

  RxList<String> keyHighlightsTitleList = [
    AppString.parkingAvailable,
    AppString.poojaRoomAvailable,
    AppString.semiFurnishedText,
    AppString.balconies1,
  ].obs;

  RxList<String> furnishingDetailsImageList = [
    Assets.images.wardrobe.path,
    Assets.images.bedSheet.path,
    Assets.images.stove.path,
    Assets.images.waterPurifier.path,
    Assets.images.fan.path,
    Assets.images.lights.path,
  ].obs;

  RxList<String> furnishingDetailsTitleList = [
    AppString.wardrobe,
    AppString.sofa,
    AppString.stove,
    AppString.waterPurifier,
    AppString.fan,
    AppString.lights,
  ].obs;

  RxList<String> facilitiesImageList = [
    Assets.images.privateGarden.path,
    Assets.images.reservedParking.path,
    Assets.images.rainWater.path,
  ].obs;

  RxList<String> facilitiesTitleList = [
    AppString.privateGarden,
    AppString.reservedParking,
    AppString.rainWaterHarvesting,
  ].obs;

  RxList<String> realEstateList = [
    AppString.yes,
    AppString.no,
  ].obs;

  RxList<String> searchImageList = [
    Assets.images.alexaneFranecki.path,
    Assets.images.searchProperty5.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.alexane,
    AppString.happinessChasers,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.baumbachLakes,
    AppString.wildermanAddress,
  ].obs;

  RxList<String> searchRupeesList = [
    AppString.rupees58Lakh,
    AppString.crore1,
  ].obs;

  RxList<String> searchRatingList = [
    AppString.rating4Point5,
    AppString.rating4Point2,
  ].obs;

  RxList<String> similarPropertyTitleList = [
    AppString.point2,
    AppString.point1,
    AppString.squareMeter256,
  ].obs;

  RxList<String> interestingImageList = [
    Assets.images.read1.path,
    Assets.images.read2.path,
  ].obs;

  RxList<String> interestingTitleList = [
    AppString.readString1,
    AppString.readString2,
  ].obs;

  RxList<String> interestingDateList = [
    AppString.november23,
    AppString.october16,
  ].obs;

  RxList<String> propertyList = [
    AppString.overview,
    AppString.highlights,
    AppString.propertyDetails,
    AppString.photos,
    AppString.about,
    AppString.owner,
    AppString.articles,
  ].obs;

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    phoneNumberFocusNode.dispose();
    emailFocusNode.dispose();
    fullNameController.dispose();
    mobileNumberController.dispose();
    emailController.dispose();
    scrollController.dispose();
  }
}
