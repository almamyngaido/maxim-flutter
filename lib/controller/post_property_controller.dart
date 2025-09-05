import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class PostPropertyController extends GetxController {
  // Get the central data manager instance
  late final PropertyDataManager _dataManager;

  // Controllers for Property Type & Basic Info fields
  final TextEditingController nombrePiecesTotalController =
      TextEditingController();
  final TextEditingController nombreNiveauxController = TextEditingController();

  // Focus nodes for text fields
  final Map<TextEditingController, FocusNode> focusNodes = {};

  // Reactive variables for text field input status
  final RxBool nombrePiecesTotalHasInput = false.obs;
  final RxBool nombreNiveauxHasInput = false.obs;

  // Dropdown selections
  final RxString selectedTypeBien = ''.obs;
  final RxString selectedStatut = ''.obs;

  // ADD: Reactive variable for button state
  final RxBool canProceedValue = false.obs;

  // Dropdown options
  final List<String> typeBienOptions = [
    'Maison',
    'Appartement',
    'Studio',
    'Villa',
    'Duplex',
    'Triplex',
    'Loft',
    'Penthouse',
    'Terrain',
    'Commerce',
    'Bureau',
    'Garage',
    'Autre'
  ];

  final List<String> statutOptions = [
    'À vendre',
    'Vendu',
    'En négociation',
    'Retiré de la vente',
    'Suspendu'
  ];

  @override
  void onInit() {
    super.onInit();

    // Initialize the data manager
    _dataManager = Get.find<PropertyDataManager>();

    // Initialize focus nodes and input listeners for each controller
    _initializeField(nombrePiecesTotalController, nombrePiecesTotalHasInput);
    _initializeField(nombreNiveauxController, nombreNiveauxHasInput);

    // Load existing data if returning to this step
    _loadExistingData();

    // ADD: Listen to all form changes and update canProceed reactively
    _setupReactiveValidation();
  }

  void _initializeField(TextEditingController controller, RxBool hasInput) {
    focusNodes[controller] = FocusNode();
    controller.addListener(() {
      hasInput.value = controller.text.isNotEmpty;
      // ADD: Update validation when text changes
      _updateCanProceed();
      // ADD: Auto-save when data changes (with debounce)
      _saveDataToManagerDebounced();
    });
  }

  /// NEW: Setup reactive validation
  void _setupReactiveValidation() {
    // Listen to dropdown changes
    ever(selectedTypeBien, (_) {
      _updateCanProceed();
      _saveDataToManagerDebounced();
    });

    ever(selectedStatut, (_) {
      _updateCanProceed();
      _saveDataToManagerDebounced();
    });

    // Initial validation check
    _updateCanProceed();
  }

  /// NEW: Update the reactive canProceed value
  void _updateCanProceed() {
    canProceedValue.value = _validateForm();
  }

  /// NEW: Internal validation method
  bool _validateForm() {
    return selectedTypeBien.value.isNotEmpty &&
        nombrePiecesTotalController.text.isNotEmpty &&
        selectedStatut.value.isNotEmpty &&
        int.tryParse(nombrePiecesTotalController.text) != null &&
        int.parse(nombrePiecesTotalController.text) > 0;
  }

  /// Load existing data when returning to this step
  void _loadExistingData() {
    final existingData =
        _dataManager.getSectionData<Map<String, dynamic>>('basicInfo');

    if (existingData != null) {
      // Populate fields with existing data
      selectedTypeBien.value = existingData['typeBien'] ?? '';
      nombrePiecesTotalController.text =
          existingData['nombrePiecesTotal']?.toString() ?? '';
      nombreNiveauxController.text =
          existingData['nombreNiveaux']?.toString() ?? '';
      selectedStatut.value = existingData['statut'] ?? '';

      print('📋 Loaded existing basic info data');
      _updateCanProceed(); // Update button state after loading
    }
  }

  // Update dropdown selections
  void updateTypeBien(String value) {
    selectedTypeBien.value = value;
    // Reactivity is handled in _setupReactiveValidation()
  }

  void updateStatut(String value) {
    selectedStatut.value = value;
    // Reactivity is handled in _setupReactiveValidation()
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
    final basicInfoData = getPropertyBasicInfoData();
    _dataManager.updateBasicInfo(basicInfoData);
  }

  // Validation for Property Type & Basic Info fields (kept for backward compatibility)
  bool validatePropertyBasicInfo() {
    return _validateForm();
  }

  // Prepare property basic info data to pass to the central manager
  Map<String, dynamic> getPropertyBasicInfoData() {
    return {
      'typeBien': selectedTypeBien.value,
      'nombrePiecesTotal': nombrePiecesTotalController.text.isNotEmpty
          ? int.tryParse(nombrePiecesTotalController.text)
          : null,
      'nombreNiveaux': nombreNiveauxController.text.isNotEmpty
          ? int.tryParse(nombreNiveauxController.text)
          : null,
      'statut': selectedStatut.value,
    };
  }

  // Helper method to get validation error message
  String? getValidationError() {
    if (selectedTypeBien.value.isEmpty) {
      return 'Veuillez sélectionner le type de bien';
    }
    if (nombrePiecesTotalController.text.isEmpty) {
      return 'Veuillez saisir le nombre de pièces';
    }
    if (int.tryParse(nombrePiecesTotalController.text) == null ||
        int.parse(nombrePiecesTotalController.text) <= 0) {
      return 'Le nombre de pièces doit être un nombre positif';
    }
    if (selectedStatut.value.isEmpty) {
      return 'Veuillez sélectionner le statut';
    }
    if (nombreNiveauxController.text.isNotEmpty &&
        (int.tryParse(nombreNiveauxController.text) == null ||
            int.parse(nombreNiveauxController.text) <= 0)) {
      return 'Le nombre de niveaux doit être un nombre positif';
    }
    return null;
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

      // FIXED: Use the correct route from AppRoutes
      try {
        Get.toNamed(AppRoutes.addPropertyDetailsView);
      } catch (e) {
        // Fallback if route doesn't exist
        print('❌ Route error: $e');
        Get.snackbar(
          'Erreur de navigation',
          'Route non trouvée. Vérifiez la configuration des routes.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF44336),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 3),
        );
      }
    } else {
      Get.snackbar(
        'Erreur de validation',
        error,
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336), // Red
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Go back to previous step (if any)
  void goBackToPreviousStep() {
    // Save current data before going back
    _saveDataToManager();

    // This is the first step, so go back to main screen or show confirmation
    Get.back();
  }

  /// Save and exit (save as draft)
  void saveAndExit() {
    _saveDataToManager();

    Get.snackbar(
      'Brouillon sauvegardé',
      'Vos données ont été sauvegardées. Vous pouvez reprendre plus tard.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF4CAF50), // Green
      colorText: const Color(0xFFFFFFFF),
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
      'currentStep': 1,
      'totalSteps': 9,
      'progress': _dataManager.getProgress(),
      'stepTitle': 'Informations de base',
      'isCompleted': _dataManager.isSectionCompleted('basicInfo'),
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
    nombrePiecesTotalController.dispose();
    nombreNiveauxController.dispose();
    focusNodes.forEach((_, focusNode) => focusNode.dispose());
    super.onClose();
  }
}
