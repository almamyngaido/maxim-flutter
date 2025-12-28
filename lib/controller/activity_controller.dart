import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class ActivityController extends GetxController {
  TextEditingController searchListController = TextEditingController();
  final storage = GetStorage();

  // Observable states
  RxInt selectListing = 0.obs;
  RxInt selectSorting = 0.obs;
  RxBool deleteShowing = false.obs;
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  RxString errorMessage = ''.obs;

  // Real property data from API - using Map instead of model to handle dynamic structure
  RxList<Map<String, dynamic>> userProperties = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredProperties =
      <Map<String, dynamic>>[].obs;

  // Static data for listing states and sorting
  RxList<String> listingStatesList = [
    AppString.active,
    AppString.expired,
    AppString.deleted,
    AppString.underScreening,
  ].obs;

  RxList<String> sortListingList = [
    AppString.newestFirst,
    AppString.oldestFirst,
    AppString.expiringFirst,
    AppString.expiringLast,
  ].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProperties();

    // Listen to search input changes
    searchListController.addListener(_filterProperties);
  }

  void updateListing(int index) {
    selectListing.value = index;
    _applyStatusFilter();
  }

  void updateSorting(int index) {
    selectSorting.value = index;
    _applySorting();
  }

  /// Get current user ID from stored token
  Future<String?> _getCurrentUserId() async {
    try {
      String? token = storage.read('authToken');

      if (token == null || token.isEmpty) {
        print('No authentication token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return userData['id']?.toString();
      } else {
        print('Failed to fetch current user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  /// Fetch user properties from API
  Future<void> fetchUserProperties() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      // Get current user ID
      String? userId = await _getCurrentUserId();
      if (userId == null) {
        throw Exception('Unable to get current user ID');
      }

      print('Fetching properties for user: $userId');

      // Get auth token for the request
      String? token = storage.read('authToken');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/utilisateurs/$userId/bien-immos'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        // 🔍 DEBUG: Print full response to help debug image issues
        print('=' * 80);
        print('📦 API RESPONSE - User Properties:');
        print('Total properties: ${jsonList.length}');
        print('=' * 80);

        // Store raw JSON data instead of trying to convert to model
        userProperties.value = jsonList.cast<Map<String, dynamic>>();

        // 🔍 DEBUG: Print each property's image data
        for (int i = 0; i < userProperties.length && i < 3; i++) {
          var property = userProperties[i];
          print('🏠 Property ${i + 1}: ${property['typeBien'] ?? 'Unknown'}');
          print('   ID: ${property['_id']}');
          print('   listeImages: ${property['listeImages']}');
          print('   Has images: ${property['listeImages'] != null && (property['listeImages'] as List?)?.isNotEmpty == true}');
          if (i < userProperties.length - 1) print('---');
        }
        if (userProperties.length > 3) {
          print('... and ${userProperties.length - 3} more properties');
        }
        print('=' * 80);

        // Initialize filtered properties
        filteredProperties.value = List.from(userProperties);

        print('✅ Fetched ${userProperties.length} properties');
        _applySorting(); // Apply default sorting
      } else {
        throw Exception('Failed to fetch properties: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user properties: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Filter properties based on search text
  void _filterProperties() {
    String searchText = searchListController.text.toLowerCase();

    if (searchText.isEmpty) {
      filteredProperties.value = List.from(userProperties);
    } else {
      filteredProperties.value = userProperties.where((property) {
        // Search in title, address, and type
        String title = _getPropertyTitle(property).toLowerCase();
        String address = _getPropertyAddress(property).toLowerCase();
        String type = _getPropertyType(property).toLowerCase();

        return title.contains(searchText) ||
            address.contains(searchText) ||
            type.contains(searchText);
      }).toList();
    }

    _applySorting();
  }

  /// Apply status filter based on selected listing state
  void _applyStatusFilter() {
    String selectedStatus = listingStatesList[selectListing.value];

    // Map UI status to API status values
    String? apiStatus;
    switch (selectedStatus) {
      case 'Active':
        apiStatus = 'à vendre';
        break;
      case 'Expired':
        apiStatus = 'expiré';
        break;
      case 'Deleted':
        apiStatus = 'supprimé';
        break;
      case 'Under Screening':
        apiStatus = 'en cours de vérification';
        break;
    }

    if (apiStatus != null) {
      filteredProperties.value = userProperties.where((property) {
        String propertyStatus = _getPropertyStatus(property);
        return propertyStatus.toLowerCase() == apiStatus?.toLowerCase();
      }).toList();
    } else {
      filteredProperties.value = List.from(userProperties);
    }

    _applySorting();
  }

  /// Apply sorting based on selected sort option
  void _applySorting() {
    String selectedSort = sortListingList[selectSorting.value];

    switch (selectedSort) {
      case 'Newest First':
        filteredProperties.sort((a, b) {
          DateTime dateA = _parseDate(_getDatePublication(a));
          DateTime dateB = _parseDate(_getDatePublication(b));
          return dateB.compareTo(dateA); // Newest first
        });
        break;
      case 'Oldest First':
        filteredProperties.sort((a, b) {
          DateTime dateA = _parseDate(_getDatePublication(a));
          DateTime dateB = _parseDate(_getDatePublication(b));
          return dateA.compareTo(dateB); // Oldest first
        });
        break;
      case 'Expiring First':
        filteredProperties.sort((a, b) {
          DateTime dateA = _parseDate(_getDatePublication(a));
          DateTime dateB = _parseDate(_getDatePublication(b));
          return dateA.compareTo(dateB);
        });
        break;
      case 'Expiring Last':
        filteredProperties.sort((a, b) {
          DateTime dateA = _parseDate(_getDatePublication(a));
          DateTime dateB = _parseDate(_getDatePublication(b));
          return dateB.compareTo(dateA);
        });
        break;
    }

    // Trigger UI update
    filteredProperties.refresh();
  }

  /// Helper method to parse date string to DateTime
  DateTime _parseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return DateTime.now();
    }

    try {
      // Try to parse ISO 8601 format first
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date: $dateString - $e');
      // Return current time as fallback
      return DateTime.now();
    }
  }

  /// Safe getters for property data based on actual API structure

  String _getPropertyTitle(Map<String, dynamic> property) {
    try {
      // Try description.titre first
      if (property['description'] != null &&
          property['description']['titre'] != null &&
          property['description']['titre'].toString().isNotEmpty) {
        return property['description']['titre'].toString();
      }

      // Fallback to type + number of rooms
      String type = _getPropertyType(property);
      int rooms = property['nombrePiecesTotal']?.toInt() ?? 0;

      if (rooms > 0) {
        return '$type ${rooms}P';
      }

      return type;
    } catch (e) {
      print('Error getting property title: $e');
      return 'Bien immobilier';
    }
  }

  String _getPropertyType(Map<String, dynamic> property) {
    try {
      return property['typeBien']?.toString() ?? 'Bien immobilier';
    } catch (e) {
      return 'Bien immobilier';
    }
  }

  String _getPropertyAddress(Map<String, dynamic> property) {
    try {
      if (property['localisation'] == null) {
        return 'Adresse non spécifiée';
      }

      Map<String, dynamic> localisation = property['localisation'];
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
      print('Error getting property address: $e');
      return 'Adresse non spécifiée';
    }
  }

  String _getPropertyPrice(Map<String, dynamic> property) {
    try {
      if (property['prix'] != null && property['prix']['hai'] != null) {
        double price = property['prix']['hai'].toDouble();

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
      print('Error getting property price: $e');
      return 'Prix sur demande';
    }
  }

  String _getPropertyImage(Map<String, dynamic> property) {
    try {
      String propertyType = property['typeBien'] ?? 'Unknown';

      // If the property has images, return the first one
      if (property['listeImages'] != null &&
          property['listeImages'] is List &&
          (property['listeImages'] as List).isNotEmpty) {
        String imagePath = (property['listeImages'] as List).first.toString();

        // 🔍 DEBUG: Show image processing
        print('🖼️ Processing image for $propertyType:');
        print('   Raw path: "$imagePath"');

        // Convert to full URL if it's a relative path
        String fullUrl = _buildImageUrl(imagePath);
        print('   Full URL: "$fullUrl"');
        return fullUrl;
      }

      // Fallback to asset images based on property type
      String type = _getPropertyType(property).toLowerCase();
      print('⚠️ No images for $propertyType - using fallback: $type');

      switch (type) {
        case 'appartement':
          return Assets.images.listing1.path;
        case 'maison':
          return Assets.images.listing2.path;
        case 'terrain':
          return Assets.images.listing3.path;
        default:
          return Assets.images.listing4.path;
      }
    } catch (e) {
      print('❌ Error getting property image: $e');
      return Assets.images.listing1.path;
    }
  }

  /// Build full image URL from path
  /// Handles:
  /// - Full URLs (http://... or https://...) - return as is
  /// - Relative paths (uploads/...) - prepend base URL
  /// - Filenames (image.jpg) - prepend base URL + /uploads/
  String _buildImageUrl(String imagePath) {
    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // If it starts with /, remove it
    if (imagePath.startsWith('/')) {
      imagePath = imagePath.substring(1);
    }

    // If it's a relative path or filename, prepend base URL
    return '${ApiConfig.baseUrl}/$imagePath';
  }

  String _getPropertyStatus(Map<String, dynamic> property) {
    try {
      return property['statut']?.toString() ?? 'brouillon';
    } catch (e) {
      return 'brouillon';
    }
  }

  String _getDatePublication(Map<String, dynamic> property) {
    try {
      // Handle MongoDB date format: { "$date": "2025-09-20T17:25:00.632Z" }
      if (property['datePublication'] is Map) {
        return property['datePublication']['\$date']?.toString() ?? '';
      }
      // Handle direct string format
      return property['datePublication']?.toString() ?? '';
    } catch (e) {
      print('Error getting date publication: $e');
      return '';
    }
  }

  String _getPropertyId(Map<String, dynamic> property) {
    try {
      print('🔍 DEBUG: ActivityController extracting property ID');
      print('🔍 DEBUG: Property keys: ${property.keys}');

      String propertyId = '';

      // Handle MongoDB ObjectId format: { "$oid": "..." }
      if (property['_id'] is Map && property['_id']['\$oid'] != null) {
        propertyId = property['_id']['\$oid'].toString();
        print('✅ DEBUG: Found MongoDB ObjectId: $propertyId');
      }
      // Handle direct string format
      else if (property['_id'] != null) {
        propertyId = property['_id'].toString();
        print('✅ DEBUG: Found direct _id: $propertyId');
      }
      // Fallback to 'id' field
      else if (property['id'] != null) {
        propertyId = property['id'].toString();
        print('✅ DEBUG: Found id field: $propertyId');
      } else {
        print('❌ DEBUG: No ID found in property data');
        // Print all keys to help debug
        property.forEach((key, value) {
          print(
              '🔍 DEBUG: Available field $key: ${value.runtimeType} = $value');
        });
      }

      return propertyId;
    } catch (e) {
      print('❌ DEBUG: Error getting property ID: $e');
      return '';
    }
  }
  // PUBLIC METHODS FOR VIEW ACCESS

  /// Public method to get property ID from property data
  String getPropertyId(Map<String, dynamic> property) {
    return _getPropertyId(property);
  }

  /// Public method to get property status from property data
  String getPropertyStatus(Map<String, dynamic> property) {
    return _getPropertyStatus(property);
  }

  /// Public getters for the view to use
  List<String> get propertyListImage => filteredProperties
      .map((property) => _getPropertyImage(property))
      .toList();

  List<String> get propertyListRupee => filteredProperties
      .map((property) => _getPropertyPrice(property))
      .toList();

  List<String> get propertyListTitle => filteredProperties
      .map((property) => _getPropertyTitle(property))
      .toList();

  List<String> get propertyListAddress => filteredProperties
      .map((property) => _getPropertyAddress(property))
      .toList();

  /// Refresh properties (pull to refresh)
  Future<void> refreshProperties() async {
    await fetchUserProperties();
  }

  /// Delete a property
  Future<void> deleteProperty(String propertyId) async {
    try {
      String? token = storage.read('authToken');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/bien-immos/$propertyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Remove from local lists
        userProperties
            .removeWhere((property) => _getPropertyId(property) == propertyId);
        filteredProperties
            .removeWhere((property) => _getPropertyId(property) == propertyId);

        Get.snackbar(
          'Succès',
          'Propriété supprimée avec succès',
          backgroundColor: Get.theme.primaryColor,
          colorText: Get.theme.colorScheme.onPrimary,
        );
      } else {
        throw Exception('Failed to delete property');
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer la propriété',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    searchListController.dispose();
  }
}
