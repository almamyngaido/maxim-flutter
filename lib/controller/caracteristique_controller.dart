import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'dart:async';

class PropertyFeaturesController extends GetxController {
  // Get the central data manager instance
  late final PropertyDataManager _dataManager;

  // Boolean reactive variables for all Caracteristiques fields from BienImmo model
  final RxBool grenier = false.obs;
  final RxBool balcon = false.obs;
  final RxBool cave = false.obs;
  final RxBool parkingOuvert = false.obs;
  final RxBool jardin = false.obs;
  final RxBool dependance = false.obs;
  final RxBool box = false.obs;
  final RxBool ascenseur = false.obs;
  final RxBool piscine = false.obs;
  final RxBool accesEgout = false.obs;
  final RxBool terrasse = false.obs;

  // ADD: Reactive variable for button state (always true since all optional)
  final RxBool canProceedValue = true.obs;

  // Feature definitions with display names and descriptions
  final List<Map<String, dynamic>> features = [
    {
      'key': 'grenier',
      'label': 'Grenier',
      'description': 'Espace sous les combles',
      'icon': '🏠',
    },
    {
      'key': 'balcon',
      'label': 'Balcon',
      'description': 'Espace extérieur en surplomb',
      'icon': '🏢',
    },
    {
      'key': 'cave',
      'label': 'Cave',
      'description': 'Espace de stockage en sous-sol',
      'icon': '🪣',
    },
    {
      'key': 'parkingOuvert',
      'label': 'Parking ouvert',
      'description': 'Place de stationnement découverte',
      'icon': '🚗',
    },
    {
      'key': 'jardin',
      'label': 'Jardin',
      'description': 'Espace vert privatif',
      'icon': '🌳',
    },
    {
      'key': 'dependance',
      'label': 'Dépendance',
      'description': 'Bâtiment annexe',
      'icon': '🏘️',
    },
    {
      'key': 'box',
      'label': 'Box/Garage fermé',
      'description': 'Garage ou box privatif',
      'icon': '🏠',
    },
    {
      'key': 'ascenseur',
      'label': 'Ascenseur',
      'description': 'Ascenseur dans l\'immeuble',
      'icon': '⬆️',
    },
    {
      'key': 'piscine',
      'label': 'Piscine',
      'description': 'Piscine privée ou commune',
      'icon': '🏊',
    },
    {
      'key': 'accesEgout',
      'label': 'Accès égout',
      'description': 'Raccordement au tout-à-l\'égout',
      'icon': '🚰',
    },
    {
      'key': 'terrasse',
      'label': 'Terrasse',
      'description': 'Espace extérieur au niveau du sol',
      'icon': '🌞',
    },
  ];

  @override
  void onInit() {
    super.onInit();

    // Initialize the data manager
    _dataManager = Get.find<PropertyDataManager>();

    // Setup reactive listeners for auto-save
    _setupReactiveListeners();

    // Load existing data if returning to this step
    _loadExistingData();
  }

  /// Setup reactive listeners for all features
  void _setupReactiveListeners() {
    // Listen to each feature change and auto-save
    ever(grenier, (_) => _saveDataToManagerDebounced());
    ever(balcon, (_) => _saveDataToManagerDebounced());
    ever(cave, (_) => _saveDataToManagerDebounced());
    ever(parkingOuvert, (_) => _saveDataToManagerDebounced());
    ever(jardin, (_) => _saveDataToManagerDebounced());
    ever(dependance, (_) => _saveDataToManagerDebounced());
    ever(box, (_) => _saveDataToManagerDebounced());
    ever(ascenseur, (_) => _saveDataToManagerDebounced());
    ever(piscine, (_) => _saveDataToManagerDebounced());
    ever(accesEgout, (_) => _saveDataToManagerDebounced());
    ever(terrasse, (_) => _saveDataToManagerDebounced());
  }

  /// Load existing data when returning to this step
  void _loadExistingData() {
    final existingData =
        _dataManager.getSectionData<Map<String, dynamic>>('features');

    if (existingData != null) {
      // Populate features with existing data
      grenier.value = existingData['grenier'] ?? false;
      balcon.value = existingData['balcon'] ?? false;
      cave.value = existingData['cave'] ?? false;
      parkingOuvert.value = existingData['parkingOuvert'] ?? false;
      jardin.value = existingData['jardin'] ?? false;
      dependance.value = existingData['dependance'] ?? false;
      box.value = existingData['box'] ?? false;
      ascenseur.value = existingData['ascenseur'] ?? false;
      piscine.value = existingData['piscine'] ?? false;
      accesEgout.value = existingData['accesEgout'] ?? false;
      terrasse.value = existingData['terrasse'] ?? false;

      final selectedCount = getSelectedFeaturesCount();
      print('📋 Loaded existing features data ($selectedCount selected)');
    }
  }

  /// Save current form data to central manager (with debounce)
  Timer? _saveTimer;
  void _saveDataToManagerDebounced() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 300), () {
      _saveDataToManager();
    });
  }

  /// Save current form data to central manager immediately
  void _saveDataToManager() {
    final featuresData = getFeaturesData();
    _dataManager.updateFeatures(featuresData);
  }

  // Get reactive boolean for a feature key
  RxBool getFeatureValue(String key) {
    switch (key) {
      case 'grenier':
        return grenier;
      case 'balcon':
        return balcon;
      case 'cave':
        return cave;
      case 'parkingOuvert':
        return parkingOuvert;
      case 'jardin':
        return jardin;
      case 'dependance':
        return dependance;
      case 'box':
        return box;
      case 'ascenseur':
        return ascenseur;
      case 'piscine':
        return piscine;
      case 'accesEgout':
        return accesEgout;
      case 'terrasse':
        return terrasse;
      default:
        return false.obs;
    }
  }

  // Toggle a specific feature
  void toggleFeature(String key) {
    switch (key) {
      case 'grenier':
        grenier.value = !grenier.value;
        break;
      case 'balcon':
        balcon.value = !balcon.value;
        break;
      case 'cave':
        cave.value = !cave.value;
        break;
      case 'parkingOuvert':
        parkingOuvert.value = !parkingOuvert.value;
        break;
      case 'jardin':
        jardin.value = !jardin.value;
        break;
      case 'dependance':
        dependance.value = !dependance.value;
        break;
      case 'box':
        box.value = !box.value;
        break;
      case 'ascenseur':
        ascenseur.value = !ascenseur.value;
        break;
      case 'piscine':
        piscine.value = !piscine.value;
        break;
      case 'accesEgout':
        accesEgout.value = !accesEgout.value;
        break;
      case 'terrasse':
        terrasse.value = !terrasse.value;
        break;
    }
    // Auto-save is handled by the reactive listeners
  }

  // Set all features to false (reset)
  void resetAllFeatures() {
    grenier.value = false;
    balcon.value = false;
    cave.value = false;
    parkingOuvert.value = false;
    jardin.value = false;
    dependance.value = false;
    box.value = false;
    ascenseur.value = false;
    piscine.value = false;
    accesEgout.value = false;
    terrasse.value = false;
    // Auto-save will be triggered by the reactive listeners
  }

  // Get count of selected features
  int getSelectedFeaturesCount() {
    int count = 0;
    if (grenier.value) count++;
    if (balcon.value) count++;
    if (cave.value) count++;
    if (parkingOuvert.value) count++;
    if (jardin.value) count++;
    if (dependance.value) count++;
    if (box.value) count++;
    if (ascenseur.value) count++;
    if (piscine.value) count++;
    if (accesEgout.value) count++;
    if (terrasse.value) count++;
    return count;
  }

  // Get list of selected feature labels
  List<String> getSelectedFeatures() {
    List<String> selected = [];
    for (final feature in features) {
      if (getFeatureValue(feature['key']).value) {
        selected.add(feature['label']);
      }
    }
    return selected;
  }

  // Validation (all features are optional)
  bool validateFeatures() {
    // All features are optional, so always valid
    return true;
  }

  // Get validation error - should always return null since features are optional
  String? getValidationError() {
    // No validation needed - all features are optional
    return null;
  }

  // Prepare features data for API (matches Caracteristiques model)
  Map<String, dynamic> getFeaturesData() {
    return {
      'grenier': grenier.value,
      'balcon': balcon.value,
      'cave': cave.value,
      'parkingOuvert': parkingOuvert.value,
      'jardin': jardin.value,
      'dependance': dependance.value,
      'box': box.value,
      'ascenseur': ascenseur.value,
      'piscine': piscine.value,
      'accesEgout': accesEgout.value,
      'terrasse': terrasse.value,
    };
  }

  /// Navigate to next step with data validation and saving
  void proceedToNextStep() {
    // Save data to central manager
    _saveDataToManager();

    // Show progress info
    final progress = _dataManager.getProgress();
    final selectedCount = getSelectedFeaturesCount();
    print(
        '📊 Progress: ${(progress * 100).toStringAsFixed(1)}% ($selectedCount features selected)');

    // Navigate to next step - Technical Details
    try {
      Get.toNamed(AppRoutes.techniqueDetailsView);
    } catch (e) {
      // Fallback: try alternative route names
      print('❌ Navigation error with AppRoutes: $e');

      final alternativeRoutes = [
        '/technical-details',
        '/technique-details',
        '/details-techniques',
        '/technical',
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
          backgroundColor: AppColor.border2Color,
          colorText: AppColor.maximPrimeColor,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  /// Go back to previous step
  void goBackToPreviousStep() {
    // Save current data before going back
    _saveDataToManager();

    // Go back to room details page
    Get.back();
  }

  /// Save and exit (save as draft)
  void saveAndExit() {
    _saveDataToManager();

    Get.snackbar(
      'Brouillon sauvegardé',
      'Vos données ont été sauvegardées. Vous pouvez reprendre plus tard.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColor.positiveColor,
      colorText: AppColor.primaryColor,
      duration: const Duration(seconds: 3),
    );

    // Navigate back to main screen or property list
    Get.offAllNamed('/properties');
  }

  /// Check if user can proceed (always true since all features are optional)
  bool canProceed() {
    return canProceedValue.value; // Always true for this page
  }

  /// Get current step info for progress indicator
  Map<String, dynamic> getStepInfo() {
    return {
      'currentStep': 5,
      'totalSteps': 9,
      'progress': _dataManager.getProgress(),
      'stepTitle': 'Caractéristiques du bien',
      'isCompleted': _dataManager.isSectionCompleted('features'),
    };
  }

  @override
  void onClose() {
    // Cancel any pending save timer
    _saveTimer?.cancel();

    // Save data before closing
    _saveDataToManager();

    super.onClose();
  }
}
