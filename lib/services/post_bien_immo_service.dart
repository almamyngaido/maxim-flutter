import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'dart:io';

import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_service.dart';

class PropertyDataManager extends GetxService {
  // Central data storage
  final RxMap<String, dynamic> _propertyData = <String, dynamic>{}.obs;
  final storage = GetStorage();

  // Individual section data observables
  final RxBool isDataComplete = false.obs;
  final RxInt completedSteps = 0.obs;
  final RxBool isSubmitting = false.obs;

  // Total steps in the flow
  static const int totalSteps = 9;

  @override
  void onInit() {
    super.onInit();
    _initializeEmptyData();
  }

  void _initializeEmptyData() {
    _propertyData.value = {
      'basicInfo': null,
      'location': null,
      'surfaces': null,
      'rooms': null,
      'features': null,
      'technicalDetails': null,
      'energyDiagnostics': null,
      'pricing': null,
      'description': null,
      'images': <String>[],
      'metadata': {
        'createdAt': DateTime.now().toIso8601String(),
        'lastUpdated': DateTime.now().toIso8601String(),
        'currentStep': 1,
        'isComplete': false,
      }
    };
  }

  Future<String> _getCurrentUserId() async {
    try {
      String? token = storage.read('authToken');

      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${AppString.apiBaseUrl}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(
          'Getting current user ID - Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final userId = userData['id']?.toString();

        if (userId == null || userId.isEmpty) {
          throw Exception('User ID not found in response');
        }

        print('Current user ID: $userId');
        return userId;
      } else {
        throw Exception(
            'Failed to fetch user: ${response.statusCode} ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error getting current user ID: $e');

      // Fallback to a temporary ID if API fails
      final fallbackId = 'user-${DateTime.now().millisecondsSinceEpoch}';
      print('Using fallback user ID: $fallbackId');
      return fallbackId;
    }
  }

  // ===========================================
  // STEP DATA UPDATE METHODS
  // ===========================================

  /// Step 1: Update basic property info
  void updateBasicInfo(Map<String, dynamic> basicInfo) {
    _propertyData['basicInfo'] = basicInfo;
    _propertyData['metadata']['currentStep'] = 2;
    _updateTimestamp();
    _checkCompletion();

    print('✅ Basic Info Updated: $basicInfo');
  }

  /// Step 2: Update location data
  void updateLocation(Map<String, dynamic> location) {
    _propertyData['location'] = location;
    _propertyData['metadata']['currentStep'] = 3;
    _updateTimestamp();
    _checkCompletion();

    print('✅ Location Updated: $location');
  }

  /// Step 3: Update surfaces data
  void updateSurfaces(Map<String, dynamic> surfaces) {
    _propertyData['surfaces'] = surfaces;
    _propertyData['metadata']['currentStep'] = 4;
    _updateTimestamp();
    _checkCompletion();

    print('✅ Surfaces Updated: $surfaces');
  }

  /// Step 4: Update rooms data
  void updateRooms(List<Map<String, dynamic>> rooms) {
    _propertyData['rooms'] = rooms;
    _propertyData['metadata']['currentStep'] = 5;
    _updateTimestamp();
    _checkCompletion();

    print('✅ Rooms Updated: ${rooms.length} rooms');
  }

  /// Step 5: Update features/characteristics
  void updateFeatures(Map<String, dynamic> features) {
    _propertyData['features'] = features;
    _propertyData['metadata']['currentStep'] = 6;
    _updateTimestamp();
    _checkCompletion();

    print('✅ Features Updated: $features');
  }

  /// Step 6: Update technical details
  void updateTechnicalDetails(Map<String, dynamic> technicalDetails) {
    _propertyData['technicalDetails'] = technicalDetails;
    _propertyData['metadata']['currentStep'] = 7;
    _updateTimestamp();
    _checkCompletion();

    print('✅ Technical Details Updated: $technicalDetails');
  }

  /// Step 7: Update energy diagnostics
  void updateEnergyDiagnostics(Map<String, dynamic> energyDiagnostics) {
    _propertyData['energyDiagnostics'] = energyDiagnostics;
    _propertyData['metadata']['currentStep'] = 8;
    _updateTimestamp();
    _checkCompletion();

    print('✅ Energy Diagnostics Updated: $energyDiagnostics');
  }

  /// Step 8: Update pricing data
  void updatePricing(Map<String, dynamic> pricing) {
    _propertyData['pricing'] = pricing;
    _propertyData['metadata']['currentStep'] = 9;
    _updateTimestamp();
    _checkCompletion();

    print('✅ Pricing Updated: $pricing');
  }

  /// Step 9: Update description and images
  void updateDescriptionAndImages(
      Map<String, dynamic> description, List<File> imageFiles) {
    _propertyData['description'] = description;
    // Store file paths for now - we'll upload them later
    _propertyData['images'] = imageFiles.map((file) => file.path).toList();
    _propertyData['metadata']['currentStep'] = totalSteps;
    _propertyData['metadata']['isComplete'] = true;
    _updateTimestamp();
    _checkCompletion();

    print(
        '✅ Description & Images Updated: ${description}, ${imageFiles.length} images');
  }

  // ===========================================
  // DATA RETRIEVAL METHODS
  // ===========================================

  /// Get all property data
  Map<String, dynamic> getAllData() {
    return Map<String, dynamic>.from(_propertyData);
  }

  /// Get specific section data
  T? getSectionData<T>(String section) {
    return _propertyData[section] as T?;
  }

  /// Get current step
  int getCurrentStep() {
    return _propertyData['metadata']['currentStep'] ?? 1;
  }

  /// Check if specific section is completed
  bool isSectionCompleted(String section) {
    return _propertyData[section] != null;
  }

  /// Get completion progress (0.0 to 1.0)
  double getProgress() {
    int completed = 0;
    List<String> sections = [
      'basicInfo',
      'location',
      'surfaces',
      'rooms',
      'features',
      'technicalDetails',
      'energyDiagnostics',
      'pricing',
      'description'
    ];

    for (String section in sections) {
      if (isSectionCompleted(section)) completed++;
    }

    completedSteps.value = completed;
    return completed / sections.length;
  }

  // ===========================================
  // VALIDATION METHODS
  // ===========================================

  /// Validate required fields are present
  bool validateRequiredData() {
    final required = [
      'basicInfo',
      'location',
      'surfaces',
      'pricing',
      'description'
    ];

    for (String section in required) {
      if (!isSectionCompleted(section)) {
        print('❌ Missing required section: $section');
        return false;
      }
    }
    return true;
  }

  /// Get validation errors
  List<String> getValidationErrors() {
    List<String> errors = [];

    if (!isSectionCompleted('basicInfo')) {
      errors.add('Informations de base manquantes');
    }
    if (!isSectionCompleted('location')) {
      errors.add('Adresse du bien manquante');
    }
    if (!isSectionCompleted('surfaces')) {
      errors.add('Surfaces du bien manquantes');
    }
    if (!isSectionCompleted('pricing')) {
      errors.add('Prix du bien manquant');
    }
    if (!isSectionCompleted('description')) {
      errors.add('Description du bien manquante');
    }

    return errors;
  }

  // ===========================================
  // API PREPARATION METHODS
  // ===========================================

  /// Prepare data for LoopBack API submission
  /// Prepare data for LoopBack API submission - FIXED to match your model structure
  Future<Map<String, dynamic>> prepareForApi() async {
    final data = getAllData();

    // Get the current user ID dynamically
    final userId = await _getCurrentUserId();

    return {
      // Basic property information (matches your model)
      'typeBien': data['basicInfo']?['typeBien'],
      'nombrePiecesTotal': data['basicInfo']?['nombrePiecesTotal'],
      'nombreNiveaux': data['basicInfo']?['nombreNiveaux'],
      'statut': data['basicInfo']?['statut'] ?? 'brouillon',

      // Location information - matches Localisation model
      'localisation': {
        'numero': data['location']?['numero'],
        'rue': data['location']?['rue'],
        'complement': data['location']?['complement'],
        'boite': data['location']?['boite'],
        'codePostal': data['location']?['codePostal'],
        'ville': data['location']?['ville'],
        'departement': data['location']?['departement'],
      },

      // Surfaces as SurfacesPrincipales object
      'surfaces': {
        'habitable': data['surfaces']?['habitable'],
        'terrain': data['surfaces']?['terrain'],
        'habitableCarrez': data['surfaces']?['habitableCarrez'],
        'garage': data['surfaces']?['garage'],
      },

      // FIXED: Room details with proper null handling
      'pieces': data['rooms']
              ?.map((room) => {
                    'type': room['type'],
                    'nom': room['nom'] ?? '',
                    'surface': room['surface'],
                    'orientation': room['orientation'] ?? '',
                    'niveau': room['niveau'] ?? 0,
                    'description': room['description'] ?? '',
                    'avecBalcon': room['avecBalcon'] ?? false,
                    'avecTerrasse': room['avecTerrasse'] ?? false,
                    'avecDressing': room['avecDressing'] ?? false,
                    'avecSalleDeBainPrivee':
                        room['avecSalleDeBainPrivee'] ?? false,
                  })
              .toList() ??
          [],

      // Features as Caracteristiques object
      'caracteristiques': data['features'] ?? {},

      // Technical details - separate objects
      'chauffageClim': data['technicalDetails']?['chauffageClim'] ?? {},
      'energie': data['technicalDetails']?['energie'] ?? {},
      'batiment': data['technicalDetails']?['batiment'] ?? {},
      'orientation': data['technicalDetails']?['orientation'] ?? {},

      // Energy diagnostics
      'diagnosticsEnergie': data['energyDiagnostics'] ?? {},

      // Pricing as Prix object
      'prix': {
        'hai': data['pricing']?['hai'],
        'honorairePourcentage': data['pricing']?['honorairePourcentage'],
        'honoraireEuros': data['pricing']?['honoraireEuros'],
        'chargesAcheteurVendeur': data['pricing']?['chargesAcheteurVendeur'],
        'netVendeur': data['pricing']?['netVendeur'],
        'chargesAnnuellesCopropriete': data['pricing']
            ?['chargesAnnuellesCopropriete'],
      },

      // Description with proper structure
      'description': {
        'titre': data['description']?['titre'],
        'annonce': data['description']?['annonce'],
      },

      // Images (will be populated after upload)
      'listeImages': [],

      // FIXED: Proper date format for LoopBack
      'datePublication': DateTime.now().toUtc().toIso8601String(),

      // DYNAMIC: User ID fetched from API
      'utilisateurId': userId,
    };
  }

  /// Get image files for upload
  List<File> getImageFiles() {
    final imagePaths = _propertyData['images'] as List<String>? ?? [];
    return imagePaths.map((path) => File(path)).toList();
  }

  // ===========================================
  // SUBMISSION METHODS (Step 2 will implement the API calls)
  // ===========================================

  /// Submit property to API (placeholder for Step 2)
  Future<bool> submitProperty() async {
    if (!validateRequiredData()) {
      final errors = getValidationErrors();
      Get.snackbar(
        'Données incomplètes',
        errors.join('\n'),
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    isSubmitting.value = true;

    try {
      // Get the API service
      final apiService = Get.find<ApiService>();

      // Prepare data for API using your existing method
      final apiData = prepareForApi();

      // Get image files using your existing method
      final imageFiles = getImageFiles();

      print('🚀 Submitting property with ${imageFiles.length} images');
      print('📋 Property data: $apiData');

      // Submit property with images using the API service
      final result = await apiService.submitPropertyWithImages(
        propertyData: await apiData,
        imageFiles: imageFiles,
      );

      if (result != null && result['id'] != null) {
        // Success! Property created
        final propertyId = result['id'];

        // Store the property ID for future reference
        _propertyData['metadata']['submittedPropertyId'] = propertyId;
        _propertyData['metadata']['submissionDate'] =
            DateTime.now().toIso8601String();
        _propertyData['metadata']['status'] = 'submitted';

        Get.snackbar(
          'Succès',
          'Propriété créée avec succès!\nID: $propertyId',
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 5),
          snackPosition: SnackPosition.TOP,
        );

        print('🎉 Property submitted successfully with ID: $propertyId');
        return true;
      } else {
        throw Exception('API returned null result');
      }
    } catch (e) {
      print('💥 Submission failed: $e');

      String userMessage = 'Erreur lors de la soumission';
      if (e is ApiException) {
        userMessage = e.userMessage;
      } else {
        userMessage = 'Erreur de connexion: $e';
      }

      Get.snackbar(
        'Erreur',
        userMessage,
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  // ===========================================
  // UTILITY METHODS
  // ===========================================

  void _updateTimestamp() {
    _propertyData['metadata']['lastUpdated'] = DateTime.now().toIso8601String();
  }

  void _checkCompletion() {
    final progress = getProgress();
    isDataComplete.value = progress >= 1.0;
  }

  /// Clear all data (for new property)
  void clearAllData() {
    _initializeEmptyData();
    completedSteps.value = 0;
    isDataComplete.value = false;
    print('🔄 Property data cleared');
  }

  /// Get current user ID (implement based on your auth system)

  Future<bool> saveAsDraft() async {
    // Update status to draft before submitting
    if (_propertyData['basicInfo'] != null) {
      _propertyData['basicInfo']['statut'] = 'brouillon';
    }
    return await submitProperty();
  }

  // UPDATED: Publish property - now async
  Future<bool> publishProperty() async {
    // Update status to published before submitting
    if (_propertyData['basicInfo'] != null) {
      _propertyData['basicInfo']['statut'] = 'à vendre';
    }
    return await submitProperty();
  }

  /// Debug method to print all data
  void printCurrentData() {
    print('📊 Current Property Data:');
    print('Progress: ${(getProgress() * 100).toStringAsFixed(1)}%');
    print('Current Step: ${getCurrentStep()}/$totalSteps');
    print('Is Complete: ${isDataComplete.value}');
    print('Data: ${getAllData()}');
  }
}
