import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'dart:async';

import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';

class AddPropertyDetailsController extends GetxController {
  // Get the central data manager instance
  late final PropertyDataManager _dataManager;

  // Controllers for Localisation fields
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController rueController = TextEditingController();
  final TextEditingController complementController = TextEditingController();
  final TextEditingController boiteController = TextEditingController();
  final TextEditingController codePostalController = TextEditingController();
  final TextEditingController villeController = TextEditingController();
  final TextEditingController departementController = TextEditingController();

  // Focus nodes for each text field
  final Map<TextEditingController, FocusNode> focusNodes = {};

  // Reactive variables for each field's input status
  final RxBool numeroHasInput = false.obs;
  final RxBool rueHasInput = false.obs;
  final RxBool complementHasInput = false.obs;
  final RxBool boiteHasInput = false.obs;
  final RxBool codePostalHasInput = false.obs;
  final RxBool villeHasInput = false.obs;
  final RxBool departementHasInput = false.obs;

  // ADD: Reactive variable for button state
  final RxBool canProceedValue = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize the data manager
    _dataManager = Get.find<PropertyDataManager>();

    // Initialize focus nodes and input listeners for each controller
    _initializeField(numeroController, numeroHasInput);
    _initializeField(rueController, rueHasInput);
    _initializeField(complementController, complementHasInput);
    _initializeField(boiteController, boiteHasInput);
    _initializeField(codePostalController, codePostalHasInput);
    _initializeField(villeController, villeHasInput);
    _initializeField(departementController, departementHasInput);

    // Load existing data if returning to this step
    _loadExistingData();

    // Setup reactive validation
    _setupReactiveValidation();
  }

  void _initializeField(TextEditingController controller, RxBool hasInput) {
    focusNodes[controller] = FocusNode();
    controller.addListener(() {
      hasInput.value = controller.text.isNotEmpty;
      // Update validation when text changes
      _updateCanProceed();
      // Auto-save when data changes (with debounce)
      _saveDataToManagerDebounced();
    });
  }

  /// Setup reactive validation
  void _setupReactiveValidation() {
    // Initial validation check
    _updateCanProceed();
  }

  /// Update the reactive canProceed value
  void _updateCanProceed() {
    canProceedValue.value = _validateForm();
  }

  /// Internal validation method
  bool _validateForm() {
    return numeroController.text.isNotEmpty &&
        rueController.text.isNotEmpty &&
        codePostalController.text.isNotEmpty &&
        villeController.text.isNotEmpty &&
        departementController.text.isNotEmpty;
  }

  /// Load existing data when returning to this step
  void _loadExistingData() {
    final existingData =
        _dataManager.getSectionData<Map<String, dynamic>>('location');

    if (existingData != null) {
      // Populate fields with existing data
      numeroController.text = existingData['numero'] ?? '';
      rueController.text = existingData['rue'] ?? '';
      complementController.text = existingData['complement'] ?? '';
      boiteController.text = existingData['boite'] ?? '';
      codePostalController.text = existingData['codePostal'] ?? '';
      villeController.text = existingData['ville'] ?? '';
      departementController.text = existingData['departement'] ?? '';

      print('📋 Loaded existing location data');
      _updateCanProceed(); // Update button state after loading
    }
  }

  /// Save current form data to central manager (with debounce to avoid too many saves)
  Timer? _saveTimer;
  void _saveDataToManagerDebounced() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      _saveDataToManager();
    });
  }

  /// Save current form data to central manager immediately
  void _saveDataToManager() {
    final locationData = getLocalisationData();
    _dataManager.updateLocation(locationData);
  }

  // Validation for Localisation fields based on BienImmo model (kept for backward compatibility)
  bool validateLocation() {
    return _validateForm();
  }

  // Helper method to get validation error message
  String? getValidationError() {
    if (numeroController.text.isEmpty) {
      return 'Veuillez saisir le numéro';
    }
    if (rueController.text.isEmpty) {
      return 'Veuillez saisir le nom de la rue';
    }
    if (codePostalController.text.isEmpty) {
      return 'Veuillez saisir le code postal';
    }
    if (codePostalController.text.length < 5) {
      return 'Le code postal doit contenir au moins 5 chiffres';
    }
    if (villeController.text.isEmpty) {
      return 'Veuillez saisir la ville';
    }
    if (departementController.text.isEmpty) {
      return 'Veuillez saisir le département';
    }
    return null;
  }

  // Prepare localisation data to pass to the central manager
  Map<String, dynamic> getLocalisationData() {
    return {
      'numero': numeroController.text,
      'rue': rueController.text,
      'complement': complementController.text.isNotEmpty
          ? complementController.text
          : null,
      'boite': boiteController.text.isNotEmpty ? boiteController.text : null,
      'codePostal': codePostalController.text,
      'ville': villeController.text,
      'departement': departementController.text,
    };
  }

  /// Navigate to next step with data validation and saving
  void proceedToNextStep() {
    final error = getValidationError();
    if (error == null) {
      // Save data to central manager
      _saveDataToManager();

      // Show progress info
      final progress = _dataManager.getProgress();
      print('📊 Progress: ${(progress * 100).toStringAsFixed(1)}%');

      // Navigate to next step - Surfaces
      try {
        Get.toNamed(
            AppRoutes.addAmenitiesView); // This should be your surfaces page
      } catch (e) {
        // Fallback: try alternative route names
        print('❌ Navigation error with AppRoutes: $e');

        final alternativeRoutes = [
          '/add-amenities',
          '/surfaces',
          '/add-surfaces',
        ];

        bool navigated = false;
        for (String route in alternativeRoutes) {
          try {
            Get.toNamed(route);
            navigated = true;
            print('✅ Successfully navigated to: $route');
            break;
          } catch (e) {
            print('❌ Failed to navigate to $route: $e');
            continue;
          }
        }

        if (!navigated) {
          Get.snackbar(
            'Erreur de navigation',
            'Impossible de naviguer vers la page suivante. Vérifiez la configuration des routes.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        }
      }
    } else {
      Get.snackbar(
        'Erreur de validation',
        error,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Go back to previous step
  void goBackToPreviousStep() {
    // Save current data before going back
    _saveDataToManager();

    // Go back to the first step (basic info)
    Get.back();
  }

  /// Save and exit (save as draft)
  void saveAndExit() {
    _saveDataToManager();

    Get.snackbar(
      'Brouillon sauvegardé',
      'Vos données ont été sauvegardées. Vous pouvez reprendre plus tard.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );

    // Navigate back to main screen or property list
    Get.offAllNamed('/properties'); // Update with your actual route
  }

  /// Check if user can proceed (for button state) - NOW REACTIVE
  bool canProceed() {
    return canProceedValue.value;
  }

  /// Get current step info for progress indicator
  Map<String, dynamic> getStepInfo() {
    return {
      'currentStep': 2,
      'totalSteps': 9,
      'progress': _dataManager.getProgress(),
      'stepTitle': 'Localisation du bien',
      'isCompleted': _dataManager.isSectionCompleted('location'),
    };
  }

  @override
  void onClose() {
    // Cancel any pending save timer
    _saveTimer?.cancel();

    // Save data before closing if valid
    if (canProceed()) {
      _saveDataToManager();
    }

    // Dispose all controllers and focus nodes
    numeroController.dispose();
    rueController.dispose();
    complementController.dispose();
    boiteController.dispose();
    codePostalController.dispose();
    villeController.dispose();
    departementController.dispose();
    focusNodes.forEach((_, focusNode) => focusNode.dispose());
    super.onClose();
  }
}
