import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'dart:async';

class TechnicalDetailsController extends GetxController {
  // Get the central data manager instance
  late final PropertyDataManager _dataManager;

  // Controllers for text inputs
  final TextEditingController anneeConstructionController =
      TextEditingController();

  // Focus nodes
  final FocusNode anneeConstructionFocusNode = FocusNode();

  // Input status tracking
  final RxBool anneeConstructionHasInput = false.obs;

  // ADD: Reactive variable for button state (always true since all optional)
  final RxBool canProceedValue = true.obs;

  // ===== ChauffageClim boolean fields =====
  final RxBool cheminee = false.obs;
  final RxBool poeleABois = false.obs;
  final RxBool insertABois = false.obs;
  final RxBool poeleAPellets = false.obs;
  final RxBool chauffageIndividuelChaudiere = false.obs;
  final RxBool chauffageAuSol = false.obs;
  final RxBool chauffageIndividuelElectrique = false.obs;
  final RxBool chauffageUrbain = false.obs;

  // ===== Energie boolean fields =====
  final RxBool electricite = false.obs;
  final RxBool gaz = false.obs;
  final RxBool fioul = false.obs;
  final RxBool pompeAChaleur = false.obs;
  final RxBool geothermie = false.obs;

  // ===== Batiment fields =====
  final RxBool copropriete = false.obs;

  // ===== Orientation fields =====
  final RxString orientationJardin = ''.obs;
  final RxString orientationTerrasse = ''.obs;
  final RxString orientationPrincipale = ''.obs;

  // Heating/Climate options with display names
  final List<Map<String, dynamic>> heatingOptions = [
    {
      'key': 'cheminee',
      'label': 'Cheminée',
      'description': 'Cheminée traditionnelle',
    },
    {
      'key': 'poeleABois',
      'label': 'Poêle à bois',
      'description': 'Poêle alimenté au bois',
    },
    {
      'key': 'insertABois',
      'label': 'Insert à bois',
      'description': 'Insert de cheminée au bois',
    },
    {
      'key': 'poeleAPellets',
      'label': 'Poêle à pellets',
      'description': 'Poêle alimenté aux granulés',
    },
    {
      'key': 'chauffageIndividuelChaudiere',
      'label': 'Chaudière individuelle',
      'description': 'Chauffage par chaudière privée',
    },
    {
      'key': 'chauffageAuSol',
      'label': 'Chauffage au sol',
      'description': 'Plancher chauffant',
    },
    {
      'key': 'chauffageIndividuelElectrique',
      'label': 'Chauffage électrique',
      'description': 'Radiateurs électriques',
    },
    {
      'key': 'chauffageUrbain',
      'label': 'Chauffage urbain',
      'description': 'Réseau de chaleur urbain',
    },
  ];

  // Energy options with display names
  final List<Map<String, dynamic>> energyOptions = [
    {
      'key': 'electricite',
      'label': 'Électricité',
      'description': 'Énergie électrique',
    },
    {
      'key': 'gaz',
      'label': 'Gaz',
      'description': 'Gaz naturel ou propane',
    },
    {
      'key': 'fioul',
      'label': 'Fioul',
      'description': 'Fuel domestique',
    },
    {
      'key': 'pompeAChaleur',
      'label': 'Pompe à chaleur',
      'description': 'PAC air/eau ou géothermique',
    },
    {
      'key': 'geothermie',
      'label': 'Géothermie',
      'description': 'Énergie géothermique',
    },
  ];

  // Orientation options
  final List<String> orientationOptions = [
    'Nord',
    'Sud',
    'Est',
    'Ouest',
    'Nord-Est',
    'Nord-Ouest',
    'Sud-Est',
    'Sud-Ouest'
  ];

  @override
  void onInit() {
    super.onInit();

    // Initialize the data manager
    _dataManager = Get.find<PropertyDataManager>();

    // Initialize input listener
    anneeConstructionController.addListener(() {
      anneeConstructionHasInput.value =
          anneeConstructionController.text.isNotEmpty;
      _updateCanProceed();
      _saveDataToManagerDebounced();
    });

    // Setup reactive listeners for auto-save
    _setupReactiveListeners();

    // Load existing data if returning to this step
    _loadExistingData();
  }

  /// Setup reactive listeners for all technical details
  void _setupReactiveListeners() {
    // Listen to heating system changes
    ever(cheminee, (_) => _saveDataToManagerDebounced());
    ever(poeleABois, (_) => _saveDataToManagerDebounced());
    ever(insertABois, (_) => _saveDataToManagerDebounced());
    ever(poeleAPellets, (_) => _saveDataToManagerDebounced());
    ever(chauffageIndividuelChaudiere, (_) => _saveDataToManagerDebounced());
    ever(chauffageAuSol, (_) => _saveDataToManagerDebounced());
    ever(chauffageIndividuelElectrique, (_) => _saveDataToManagerDebounced());
    ever(chauffageUrbain, (_) => _saveDataToManagerDebounced());

    // Listen to energy source changes
    ever(electricite, (_) => _saveDataToManagerDebounced());
    ever(gaz, (_) => _saveDataToManagerDebounced());
    ever(fioul, (_) => _saveDataToManagerDebounced());
    ever(pompeAChaleur, (_) => _saveDataToManagerDebounced());
    ever(geothermie, (_) => _saveDataToManagerDebounced());

    // Listen to building info changes
    ever(copropriete, (_) => _saveDataToManagerDebounced());

    // Listen to orientation changes
    ever(orientationJardin, (_) => _saveDataToManagerDebounced());
    ever(orientationTerrasse, (_) => _saveDataToManagerDebounced());
    ever(orientationPrincipale, (_) => _saveDataToManagerDebounced());
  }

  /// Load existing data when returning to this step
  void _loadExistingData() {
    final existingData =
        _dataManager.getSectionData<Map<String, dynamic>>('technicalDetails');

    if (existingData != null) {
      // Load construction year
      final batiment = existingData['batiment'] as Map<String, dynamic>?;
      if (batiment != null) {
        final annee = batiment['anneeConstruction'];
        anneeConstructionController.text = annee?.toString() ?? '';
        copropriete.value = batiment['copropriete'] ?? false;
      }

      // Load heating systems
      final chauffageClim =
          existingData['chauffageClim'] as Map<String, dynamic>?;
      if (chauffageClim != null) {
        cheminee.value = chauffageClim['cheminee'] ?? false;
        poeleABois.value = chauffageClim['poeleABois'] ?? false;
        insertABois.value = chauffageClim['insertABois'] ?? false;
        poeleAPellets.value = chauffageClim['poeleAPellets'] ?? false;
        chauffageIndividuelChaudiere.value =
            chauffageClim['chauffageIndividuelChaudiere'] ?? false;
        chauffageAuSol.value = chauffageClim['chauffageAuSol'] ?? false;
        chauffageIndividuelElectrique.value =
            chauffageClim['chauffageIndividuelElectrique'] ?? false;
        chauffageUrbain.value = chauffageClim['chauffageUrbain'] ?? false;
      }

      // Load energy sources
      final energie = existingData['energie'] as Map<String, dynamic>?;
      if (energie != null) {
        electricite.value = energie['electricite'] ?? false;
        gaz.value = energie['gaz'] ?? false;
        fioul.value = energie['fioul'] ?? false;
        pompeAChaleur.value = energie['pompeAChaleur'] ?? false;
        geothermie.value = energie['geothermie'] ?? false;
      }

      // Load orientations
      final orientation = existingData['orientation'] as Map<String, dynamic>?;
      if (orientation != null) {
        orientationJardin.value = orientation['jardin'] ?? '';
        orientationTerrasse.value = orientation['terrasse'] ?? '';
        orientationPrincipale.value = orientation['principale'] ?? '';
      }

      print('📋 Loaded existing technical details data');
      _updateCanProceed();
    }
  }

  /// Update the reactive canProceed value
  void _updateCanProceed() {
    // Validate construction year if provided
    bool isValid = true;
    if (anneeConstructionController.text.isNotEmpty) {
      final year = int.tryParse(anneeConstructionController.text);
      isValid = year != null && year >= 1800 && year <= DateTime.now().year + 2;
    }
    canProceedValue.value = isValid;
  }

  /// Save current form data to central manager (with debounce)
  Timer? _saveTimer;
  void _saveDataToManagerDebounced() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), () {
      if (canProceedValue.value) {
        _saveDataToManager();
      }
    });
  }

  /// Save current form data to central manager immediately
  void _saveDataToManager() {
    final technicalData = getTechnicalDetailsData();
    _dataManager.updateTechnicalDetails(technicalData);
  }

  // Get heating value by key
  RxBool getHeatingValue(String key) {
    switch (key) {
      case 'cheminee':
        return cheminee;
      case 'poeleABois':
        return poeleABois;
      case 'insertABois':
        return insertABois;
      case 'poeleAPellets':
        return poeleAPellets;
      case 'chauffageIndividuelChaudiere':
        return chauffageIndividuelChaudiere;
      case 'chauffageAuSol':
        return chauffageAuSol;
      case 'chauffageIndividuelElectrique':
        return chauffageIndividuelElectrique;
      case 'chauffageUrbain':
        return chauffageUrbain;
      default:
        return false.obs;
    }
  }

  // Get energy value by key
  RxBool getEnergyValue(String key) {
    switch (key) {
      case 'electricite':
        return electricite;
      case 'gaz':
        return gaz;
      case 'fioul':
        return fioul;
      case 'pompeAChaleur':
        return pompeAChaleur;
      case 'geothermie':
        return geothermie;
      default:
        return false.obs;
    }
  }

  // Toggle heating option
  void toggleHeating(String key) {
    switch (key) {
      case 'cheminee':
        cheminee.value = !cheminee.value;
        break;
      case 'poeleABois':
        poeleABois.value = !poeleABois.value;
        break;
      case 'insertABois':
        insertABois.value = !insertABois.value;
        break;
      case 'poeleAPellets':
        poeleAPellets.value = !poeleAPellets.value;
        break;
      case 'chauffageIndividuelChaudiere':
        chauffageIndividuelChaudiere.value =
            !chauffageIndividuelChaudiere.value;
        break;
      case 'chauffageAuSol':
        chauffageAuSol.value = !chauffageAuSol.value;
        break;
      case 'chauffageIndividuelElectrique':
        chauffageIndividuelElectrique.value =
            !chauffageIndividuelElectrique.value;
        break;
      case 'chauffageUrbain':
        chauffageUrbain.value = !chauffageUrbain.value;
        break;
    }
    // Auto-save is handled by reactive listeners
  }

  // Toggle energy option
  void toggleEnergy(String key) {
    switch (key) {
      case 'electricite':
        electricite.value = !electricite.value;
        break;
      case 'gaz':
        gaz.value = !gaz.value;
        break;
      case 'fioul':
        fioul.value = !fioul.value;
        break;
      case 'pompeAChaleur':
        pompeAChaleur.value = !pompeAChaleur.value;
        break;
      case 'geothermie':
        geothermie.value = !geothermie.value;
        break;
    }
    // Auto-save is handled by reactive listeners
  }

  // Toggle copropriete
  void toggleCopropriete() {
    copropriete.value = !copropriete.value;
    // Auto-save is handled by reactive listeners
  }

  // Update orientation values
  void updateOrientationJardin(String? value) {
    orientationJardin.value = value ?? '';
  }

  void updateOrientationTerrasse(String? value) {
    orientationTerrasse.value = value ?? '';
  }

  void updateOrientationPrincipale(String? value) {
    orientationPrincipale.value = value ?? '';
  }

  // Validation (all fields are optional, but construction year must be valid if provided)
  bool validateTechnicalDetails() {
    return canProceedValue.value;
  }

  // Get validation error message
  String? getValidationError() {
    if (anneeConstructionController.text.isNotEmpty) {
      final year = int.tryParse(anneeConstructionController.text);
      if (year == null) {
        return 'L\'année de construction doit être un nombre';
      }
      if (year < 1800) {
        return 'L\'année de construction ne peut pas être antérieure à 1800';
      }
      if (year > DateTime.now().year + 2) {
        return 'L\'année de construction ne peut pas être dans le futur';
      }
    }
    return null;
  }

  // Get all technical details data for API
  Map<String, dynamic> getTechnicalDetailsData() {
    return {
      'chauffageClim': {
        'cheminee': cheminee.value,
        'poeleABois': poeleABois.value,
        'insertABois': insertABois.value,
        'poeleAPellets': poeleAPellets.value,
        'chauffageIndividuelChaudiere': chauffageIndividuelChaudiere.value,
        'chauffageAuSol': chauffageAuSol.value,
        'chauffageIndividuelElectrique': chauffageIndividuelElectrique.value,
        'chauffageUrbain': chauffageUrbain.value,
      },
      'energie': {
        'electricite': electricite.value,
        'gaz': gaz.value,
        'fioul': fioul.value,
        'pompeAChaleur': pompeAChaleur.value,
        'geothermie': geothermie.value,
      },
      'batiment': {
        'anneeConstruction': anneeConstructionController.text.isNotEmpty
            ? int.tryParse(anneeConstructionController.text)
            : null,
        'copropriete': copropriete.value,
      },
      'orientation': {
        'jardin':
            orientationJardin.value.isNotEmpty ? orientationJardin.value : null,
        'terrasse': orientationTerrasse.value.isNotEmpty
            ? orientationTerrasse.value
            : null,
        'principale': orientationPrincipale.value.isNotEmpty
            ? orientationPrincipale.value
            : null,
      },
    };
  }

  /// Get count of selected technical features
  int getSelectedTechnicalFeaturesCount() {
    int count = 0;

    // Count heating systems
    if (cheminee.value) count++;
    if (poeleABois.value) count++;
    if (insertABois.value) count++;
    if (poeleAPellets.value) count++;
    if (chauffageIndividuelChaudiere.value) count++;
    if (chauffageAuSol.value) count++;
    if (chauffageIndividuelElectrique.value) count++;
    if (chauffageUrbain.value) count++;

    // Count energy sources
    if (electricite.value) count++;
    if (gaz.value) count++;
    if (fioul.value) count++;
    if (pompeAChaleur.value) count++;
    if (geothermie.value) count++;

    // Count building features
    if (copropriete.value) count++;
    if (anneeConstructionController.text.isNotEmpty) count++;

    // Count orientations
    if (orientationJardin.value.isNotEmpty) count++;
    if (orientationTerrasse.value.isNotEmpty) count++;
    if (orientationPrincipale.value.isNotEmpty) count++;

    return count;
  }

  /// Navigate to next step with data validation and saving
  void proceedToNextStep() {
    final error = getValidationError();
    if (error == null) {
      // Save data to central manager
      _saveDataToManager();

      // Show progress info
      final progress = _dataManager.getProgress();
      final selectedCount = getSelectedTechnicalFeaturesCount();
      print(
          '📊 Progress: ${(progress * 100).toStringAsFixed(1)}% ($selectedCount technical details)');

      // Navigate to next step - Energy Diagnostics
      try {
        Get.toNamed(AppRoutes.energieDiagView);
      } catch (e) {
        // Fallback: try alternative route names
        print('❌ Navigation error with AppRoutes: $e');

        final alternativeRoutes = [
          '/energy-diagnostics',
          '/energie-diag',
          '/diagnostics-energie',
          '/energy',
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

    // Go back to property features page
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
    Get.offAllNamed('/properties');
  }

  /// Check if user can proceed (for button state)
  bool canProceed() {
    return canProceedValue.value;
  }

  /// Get current step info for progress indicator
  Map<String, dynamic> getStepInfo() {
    return {
      'currentStep': 6,
      'totalSteps': 9,
      'progress': _dataManager.getProgress(),
      'stepTitle': 'Détails techniques',
      'isCompleted': _dataManager.isSectionCompleted('technicalDetails'),
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

    // Dispose controllers and focus nodes
    anneeConstructionController.dispose();
    anneeConstructionFocusNode.dispose();
    super.onClose();
  }
}
