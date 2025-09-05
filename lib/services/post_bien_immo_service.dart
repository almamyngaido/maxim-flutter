import 'dart:ui';

import 'package:get/get.dart';
import 'dart:io';

class PropertyDataManager extends GetxService {
  // Central data storage
  final RxMap<String, dynamic> _propertyData = <String, dynamic>{}.obs;

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
  Map<String, dynamic> prepareForApi() {
    final data = getAllData();

    return {
      // Basic property information
      'typeBien': data['basicInfo']?['typeBien'],
      'nombrePiecesTotal': data['basicInfo']?['nombrePiecesTotal'],
      'nombreNiveaux': data['basicInfo']?['nombreNiveaux'],
      'statut': data['basicInfo']?['statut'] ?? 'brouillon',

      // Location information
      'localisation': data['location'],

      // Surfaces
      'surfaces': data['surfaces'],

      // Room details
      'pieces': data['rooms'] ?? [],

      // Characteristics/Features
      'caracteristiques': data['features'],

      // Technical details
      'detailsTechniques': data['technicalDetails'],

      // Energy diagnostics
      'diagnosticsEnergie': data['energyDiagnostics'],

      // Pricing
      'prix': data['pricing'],

      // Description and title
      'titre': data['description']?['titre'],
      'description': data['description']?['annonce'],

      // Images (will be populated after upload)
      'listeImages': [],

      // Metadata
      'datePublication': DateTime.now().toIso8601String(),
      'dateCreation': data['metadata']['createdAt'],
      'derniereModification': data['metadata']['lastUpdated'],

      // User ID (you'll need to get this from your auth system)
      'utilisateurId': _getCurrentUserId(),
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
      );
      return false;
    }

    isSubmitting.value = true;

    try {
      // Prepare data for API
      final apiData = prepareForApi();
      print('🚀 Ready to submit to API: $apiData');

      // TODO: Step 2 will implement actual API calls
      // 1. Upload images first
      // 2. Submit property data with image URLs

      // Simulate API call for now
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Succès',
        'Propriété soumise avec succès! (Mode simulation)',
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la soumission: $e',
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
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
  String _getCurrentUserId() {
    // TODO: Implement based on your authentication system
    // For now return a placeholder
    return 'user-${DateTime.now().millisecondsSinceEpoch}';
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
