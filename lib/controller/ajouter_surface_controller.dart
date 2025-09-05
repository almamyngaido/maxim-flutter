import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'dart:async';

class AddAmenitiesController extends GetxController {
  // Get the central data manager instance
  late final PropertyDataManager _dataManager;

  // Controllers for SurfacesPrincipales fields
  final TextEditingController habitableController = TextEditingController();
  final TextEditingController terrainController = TextEditingController();
  final TextEditingController habitableCarrezController =
      TextEditingController();
  final TextEditingController garageController = TextEditingController();

  // Individual focus nodes to avoid GlobalKey conflicts
  final FocusNode habitableFocusNode = FocusNode();
  final FocusNode terrainFocusNode = FocusNode();
  final FocusNode habitableCarrezFocusNode = FocusNode();
  final FocusNode garageFocusNode = FocusNode();

  // Reactive variables for each field's input status
  final RxBool habitableHasInput = false.obs;
  final RxBool terrainHasInput = false.obs;
  final RxBool habitableCarrezHasInput = false.obs;
  final RxBool garageHasInput = false.obs;

  // ADD: Reactive variable for button state
  final RxBool canProceedValue = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize the data manager
    _dataManager = Get.find<PropertyDataManager>();

    // Initialize input listeners for each controller
    _initializeField(habitableController, habitableHasInput);
    _initializeField(terrainController, terrainHasInput);
    _initializeField(habitableCarrezController, habitableCarrezHasInput);
    _initializeField(garageController, garageHasInput);

    // Load existing data if returning to this step
    _loadExistingData();

    // Setup reactive validation
    _setupReactiveValidation();
  }

  void _initializeField(TextEditingController controller, RxBool hasInput) {
    controller.addListener(() {
      final newValue = controller.text.isNotEmpty;
      if (hasInput.value != newValue) {
        hasInput.value = newValue;
      }

      // Update validation and save
      _updateCanProceed();
      _saveDataToManagerDebounced();
    });

    // Initial state
    hasInput.value = controller.text.isNotEmpty;
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
    return habitableController.text.isNotEmpty &&
        _isValidSurface(habitableController.text);
  }

  /// Load existing data when returning to this step
  void _loadExistingData() {
    final existingData =
        _dataManager.getSectionData<Map<String, dynamic>>('surfaces');

    if (existingData != null) {
      // Populate fields with existing data
      habitableController.text = existingData['habitable']?.toString() ?? '';
      terrainController.text = existingData['terrain']?.toString() ?? '';
      habitableCarrezController.text =
          existingData['habitableCarrez']?.toString() ?? '';
      garageController.text = existingData['garage']?.toString() ?? '';

      print('📋 Loaded existing surfaces data');
      _updateCanProceed(); // Update button state after loading
    }
  }

  /// Save current form data to central manager (with debounce to avoid too many saves)
  Timer? _saveTimer;
  void _saveDataToManagerDebounced() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      if (_validateForm()) {
        _saveDataToManager();
      }
    });
  }

  /// Save current form data to central manager immediately
  void _saveDataToManager() {
    final surfacesData = getSurfacesData();
    _dataManager.updateSurfaces(surfacesData);
  }

  // Validation for SurfacesPrincipales fields (kept for backward compatibility)
  bool validateSurfaces() {
    return _validateForm();
  }

  // Helper method to validate surface input
  bool _isValidSurface(String value) {
    if (value.isEmpty) return false;
    final surface = double.tryParse(value);
    return surface != null && surface > 0;
  }

  // Helper method to get validation error message
  String? getValidationError() {
    if (habitableController.text.isEmpty) {
      return 'Veuillez saisir la surface habitable';
    }
    if (!_isValidSurface(habitableController.text)) {
      return 'La surface habitable doit être un nombre positif';
    }

    // Validate optional fields if they have input
    if (terrainController.text.isNotEmpty &&
        !_isValidSurface(terrainController.text)) {
      return 'La surface terrain doit être un nombre positif';
    }
    if (habitableCarrezController.text.isNotEmpty &&
        !_isValidSurface(habitableCarrezController.text)) {
      return 'La surface habitable (loi Carrez) doit être un nombre positif';
    }
    if (garageController.text.isNotEmpty &&
        !_isValidSurface(garageController.text)) {
      return 'La surface garage doit être un nombre positif';
    }
    return null;
  }

  // Prepare surfaces data to pass to the central manager
  Map<String, dynamic> getSurfacesData() {
    return {
      'habitable': double.tryParse(habitableController.text) ?? 0.0,
      'terrain': terrainController.text.isNotEmpty
          ? double.tryParse(terrainController.text)
          : null,
      'habitableCarrez': habitableCarrezController.text.isNotEmpty
          ? double.tryParse(habitableCarrezController.text)
          : null,
      'garage': garageController.text.isNotEmpty
          ? double.tryParse(garageController.text)
          : null,
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

      // Navigate to next step - Room Details
      try {
        Get.toNamed(AppRoutes.roomDetailsView);
      } catch (e) {
        // Fallback: try alternative route names
        print('❌ Navigation error with AppRoutes: $e');

        final alternativeRoutes = [
          '/room-details',
          '/pieces',
          '/add-rooms',
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
    if (_validateForm()) {
      _saveDataToManager();
    }

    // Go back to location page
    Get.back();
  }

  /// Save and exit (save as draft)
  void saveAndExit() {
    if (_validateForm()) {
      _saveDataToManager();
    }

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
      'currentStep': 3,
      'totalSteps': 9,
      'progress': _dataManager.getProgress(),
      'stepTitle': 'Surfaces du bien',
      'isCompleted': _dataManager.isSectionCompleted('surfaces'),
    };
  }

  // Helper methods for UI display (kept for backward compatibility)
  String formatSurfaceHint(String baseSurface) {
    return 'Ex: $baseSurface m²';
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
    habitableController.dispose();
    terrainController.dispose();
    habitableCarrezController.dispose();
    garageController.dispose();

    habitableFocusNode.dispose();
    terrainFocusNode.dispose();
    habitableCarrezFocusNode.dispose();
    garageFocusNode.dispose();

    super.onClose();
  }
}
