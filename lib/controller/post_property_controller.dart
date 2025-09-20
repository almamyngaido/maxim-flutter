// controller/post_property_controller.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// AJOUTER CET IMPORT
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class PostPropertyController extends GetxController {
  // AJOUTER CETTE LIGNE
  late final PropertyDataManager _dataManager;

  // Votre code existant reste exactement pareil
  final TextEditingController nombrePiecesTotalController =
      TextEditingController();
  final TextEditingController nombreNiveauxController = TextEditingController();
  final Map<TextEditingController, FocusNode> focusNodes = {};
  final RxBool nombrePiecesTotalHasInput = false.obs;
  final RxBool nombreNiveauxHasInput = false.obs;
  final RxString selectedTypeBien = ''.obs;
  final RxString selectedStatut = ''.obs;
  final RxBool canProceedValue = false.obs;

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

    // AJOUTER CETTE LIGNE
    _dataManager = Get.find<PropertyDataManager>();

    // Votre code existant reste exactement pareil
    _initializeField(nombrePiecesTotalController, nombrePiecesTotalHasInput);
    _initializeField(nombreNiveauxController, nombreNiveauxHasInput);

    _loadExistingData();
    _setupReactiveValidation();
  }

  // Votre code existant reste exactement pareil
  void _initializeField(TextEditingController controller, RxBool hasInput) {
    focusNodes[controller] = FocusNode();
    controller.addListener(() {
      hasInput.value = controller.text.isNotEmpty;
      _updateCanProceed();
      _saveDataToManagerDebounced();
    });
  }

  void _setupReactiveValidation() {
    ever(selectedTypeBien, (_) {
      _updateCanProceed();
      _saveDataToManagerDebounced();
    });

    ever(selectedStatut, (_) {
      _updateCanProceed();
      _saveDataToManagerDebounced();
    });

    _updateCanProceed();
  }

  void _updateCanProceed() {
    canProceedValue.value = _validateForm();
  }

  bool _validateForm() {
    return selectedTypeBien.value.isNotEmpty &&
        nombrePiecesTotalController.text.isNotEmpty &&
        selectedStatut.value.isNotEmpty &&
        int.tryParse(nombrePiecesTotalController.text) != null &&
        int.parse(nombrePiecesTotalController.text) > 0;
  }

  // MODIFIER CETTE MÉTHODE pour utiliser votre PropertyDataManager
  void _loadExistingData() {
    final existingData =
        _dataManager.getSectionData<Map<String, dynamic>>('basicInfo');

    if (existingData != null) {
      selectedTypeBien.value = existingData['typeBien'] ?? '';
      nombrePiecesTotalController.text =
          existingData['nombrePiecesTotal']?.toString() ?? '';
      nombreNiveauxController.text =
          existingData['nombreNiveaux']?.toString() ?? '';
      selectedStatut.value = existingData['statut'] ?? '';

      print('Loaded existing basic info data');
      _updateCanProceed();
    }
  }

  void updateTypeBien(String value) {
    selectedTypeBien.value = value;
  }

  void updateStatut(String value) {
    selectedStatut.value = value;
  }

  Timer? _saveTimer;
  void _saveDataToManagerDebounced() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      _saveDataToManager();
    });
  }

  // MODIFIER CETTE MÉTHODE pour utiliser votre PropertyDataManager
  void _saveDataToManager() {
    final basicInfoData = getPropertyBasicInfoData();
    _dataManager.updateBasicInfo(basicInfoData);
  }

  // Votre code existant reste exactement pareil
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

  void proceedToNextStep() {
    final error = getValidationError();
    if (error == null) {
      _saveDataToManager();

      // AJOUTER CES LIGNES pour voir la progression
      final progress = _dataManager.getProgress();
      final currentStep = _dataManager.getCurrentStep();
      print(
          'Progress: ${(progress * 100).toStringAsFixed(1)}% - Step: $currentStep');

      try {
        Get.toNamed(AppRoutes.addPropertyDetailsView);
      } catch (e) {
        print('Route error: $e');
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
        backgroundColor: const Color(0xFFF44336),
        colorText: const Color(0xFFFFFFFF),
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Votre code existant reste exactement pareil
  @override
  void onClose() {
    _saveTimer?.cancel();
    if (canProceed()) {
      _saveDataToManager();
    }
    nombrePiecesTotalController.dispose();
    nombreNiveauxController.dispose();
    focusNodes.forEach((_, focusNode) => focusNode.dispose());
    super.onClose();
  }

  bool canProceed() {
    return canProceedValue.value;
  }
}
