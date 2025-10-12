import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/user_utils.dart';

class PricingController extends GetxController {
  // Controllers for all pricing fields
  late final PropertyDataManager _dataManager;
  Map<String, dynamic>? userData;
  final TextEditingController haiController = TextEditingController();
  final TextEditingController honorairePourcentageController =
      TextEditingController();
  final TextEditingController honoraireEurosController =
      TextEditingController();
  final TextEditingController chargesAcheteurVendeurController =
      TextEditingController();
  final TextEditingController netVendeurController = TextEditingController();
  final TextEditingController chargesAnnuellesCoproprieteController =
      TextEditingController();

  // Focus nodes
  final FocusNode haiFocusNode = FocusNode();
  final FocusNode honorairePourcentageFocusNode = FocusNode();
  final FocusNode honoraireEurosFocusNode = FocusNode();
  final FocusNode chargesAcheteurVendeurFocusNode = FocusNode();
  final FocusNode netVendeurFocusNode = FocusNode();
  final FocusNode chargesAnnuellesCoproprieteeFocusNode = FocusNode();

  // Input status tracking
  final RxBool haiHasInput = false.obs;
  final RxBool honorairePourcentageHasInput = false.obs;
  final RxBool honoraireEurosHasInput = false.obs;
  final RxBool chargesAcheteurVendeurHasInput = false.obs;
  final RxBool netVendeurHasInput = false.obs;
  final RxBool chargesAnnuellesCoproprieteHasInput = false.obs;

  // Reactive text values for summary updates
  final RxString haiText = ''.obs;
  final RxString honoraireEurosText = ''.obs;
  final RxString netVendeurText = ''.obs;

  // Dropdown for charges buyer/seller
  final RxString selectedChargesType = ''.obs;
  final List<String> chargesTypeOptions = [
    'À la charge de l\'acheteur',
    'À la charge du vendeur',
    'Partagées',
  ];

  @override
  void onInit() {

    super.onInit();
    _dataManager = Get.find<PropertyDataManager>();
    userData = loadUserData();
    print('👤 User data in PricingController: $userData');

    // Initialize input listeners
    _initializeListeners();
    _loadExistingData();

    // Add listeners for automatic calculations
    haiController.addListener(_calculateNetVendeur);
    honorairePourcentageController.addListener(_calculateHonoraireEuros);
    honoraireEurosController.addListener(_calculateHonorairePourcentage);
  }

  void _initializeListeners() {
    haiController.addListener(() {
      haiHasInput.value = haiController.text.isNotEmpty;
      haiText.value = haiController.text;
      _saveDataToManagerDebounced(); // AJOUTEZ cette ligne
    });

    honorairePourcentageController.addListener(() {
      honorairePourcentageHasInput.value =
          honorairePourcentageController.text.isNotEmpty;
      _saveDataToManagerDebounced(); // AJOUTEZ cette ligne
    });

    honoraireEurosController.addListener(() {
      honoraireEurosHasInput.value = honoraireEurosController.text.isNotEmpty;
      honoraireEurosText.value = honoraireEurosController.text;
      _saveDataToManagerDebounced(); // AJOUTEZ cette ligne
    });

    chargesAcheteurVendeurController.addListener(() {
      chargesAcheteurVendeurHasInput.value =
          chargesAcheteurVendeurController.text.isNotEmpty;
      _saveDataToManagerDebounced(); // AJOUTEZ cette ligne
    });

    netVendeurController.addListener(() {
      netVendeurHasInput.value = netVendeurController.text.isNotEmpty;
      netVendeurText.value = netVendeurController.text;
      _saveDataToManagerDebounced(); // AJOUTEZ cette ligne
    });

    chargesAnnuellesCoproprieteController.addListener(() {
      chargesAnnuellesCoproprieteHasInput.value =
          chargesAnnuellesCoproprieteController.text.isNotEmpty;
      _saveDataToManagerDebounced(); // AJOUTEZ cette ligne
    });
  }

  // Update charges type
  void updateChargesType(String? value) {
    selectedChargesType.value = value ?? '';
    _saveDataToManagerDebounced(); // AJOUTEZ cette ligne
  }

  void _loadExistingData() {
    final existingData =
        _dataManager.getSectionData<Map<String, dynamic>>('pricing');

    if (existingData != null) {
      haiController.text = existingData['hai']?.toString() ?? '';
      honorairePourcentageController.text =
          existingData['honorairePourcentage']?.toString() ?? '';
      honoraireEurosController.text =
          existingData['honoraireEuros']?.toString() ?? '';
      netVendeurController.text = existingData['netVendeur']?.toString() ?? '';
      chargesAnnuellesCoproprieteController.text =
          existingData['chargesAnnuellesCopropriete']?.toString() ?? '';
      selectedChargesType.value = existingData['chargesAcheteurVendeur'] ?? '';

      print('📋 Loaded existing pricing data');
    }
  }

  Timer? _saveTimer;
  void _saveDataToManagerDebounced() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), () {
      _saveDataToManager();
    });
  }

  void _saveDataToManager() {
    final pricingData = getPricingData();
    _dataManager.updatePricing(pricingData);
    print('💰 Pricing saved: $pricingData');
  }

  // Auto-calculate net vendeur based on HAI and fees
  void _calculateNetVendeur() {
    if (haiController.text.isNotEmpty &&
        honoraireEurosController.text.isNotEmpty) {
      final hai = double.tryParse(haiController.text.replaceAll(',', '.'));
      final honoraires =
          double.tryParse(honoraireEurosController.text.replaceAll(',', '.'));

      if (hai != null && honoraires != null) {
        final netVendeur = hai - honoraires;
        if (netVendeur > 0) {
          netVendeurController.text = formatCurrency(netVendeur);
        }
      }
    }
  }

  // Auto-calculate honoraires in euros from percentage
  void _calculateHonoraireEuros() {
    if (haiController.text.isNotEmpty &&
        honorairePourcentageController.text.isNotEmpty) {
      final hai = double.tryParse(haiController.text.replaceAll(',', '.'));
      final percentage = double.tryParse(
          honorairePourcentageController.text.replaceAll(',', '.'));

      if (hai != null &&
          percentage != null &&
          percentage > 0 &&
          percentage <= 100) {
        final honorairesEuros = (hai * percentage) / 100;
        honoraireEurosController.text = formatCurrency(honorairesEuros);
      }
    }
  }

  // Auto-calculate percentage from euros
  void _calculateHonorairePourcentage() {
    if (haiController.text.isNotEmpty &&
        honoraireEurosController.text.isNotEmpty) {
      final hai = double.tryParse(haiController.text.replaceAll(',', '.'));
      final honoraires =
          double.tryParse(honoraireEurosController.text.replaceAll(',', '.'));

      if (hai != null && honoraires != null && hai > 0) {
        final percentage = (honoraires / hai) * 100;
        if (percentage <= 100) {
          honorairePourcentageController.text = percentage.toStringAsFixed(2);
        }
      }
    }
  }

  // Format currency for display
  String formatCurrency(double amount) {
    return amount.toStringAsFixed(2).replaceAll('.', ',');
  }

  // Parse currency string to double
  double? parseCurrency(String value) {
    if (value.isEmpty) return null;
    return double.tryParse(value.replaceAll(',', '.'));
  }

  // Validation
  bool validatePricing() {
    return haiController.text.isNotEmpty &&
        parseCurrency(haiController.text) != null &&
        (parseCurrency(haiController.text) ?? 0) > 0;
  }

  // Get validation error message
  String? getValidationError() {
    if (haiController.text.isEmpty) {
      return 'Veuillez saisir le prix HAI (Honoraires Acquéreur Inclus)';
    }

    final hai = parseCurrency(haiController.text);
    if (hai == null) {
      return 'Le prix HAI doit être un nombre valide';
    }

    if (hai <= 0) {
      return 'Le prix HAI doit être positif';
    }

    // Validate optional fields if they have values
    if (honorairePourcentageController.text.isNotEmpty) {
      final percentage = parseCurrency(honorairePourcentageController.text);
      if (percentage == null || percentage < 0 || percentage > 100) {
        return 'Le pourcentage d\'honoraires doit être entre 0 et 100%';
      }
    }

    if (honoraireEurosController.text.isNotEmpty) {
      final honoraires = parseCurrency(honoraireEurosController.text);
      if (honoraires == null || honoraires < 0) {
        return 'Les honoraires en euros doivent être positifs';
      }
      if (honoraires >= hai) {
        return 'Les honoraires ne peuvent pas être supérieurs ou égaux au prix HAI';
      }
    }

    if (netVendeurController.text.isNotEmpty) {
      final netVendeur = parseCurrency(netVendeurController.text);
      if (netVendeur == null || netVendeur < 0) {
        return 'Le net vendeur doit être positif';
      }
    }

    if (chargesAnnuellesCoproprieteController.text.isNotEmpty) {
      final charges = parseCurrency(chargesAnnuellesCoproprieteController.text);
      if (charges == null || charges < 0) {
        return 'Les charges de copropriété doivent être positives';
      }
    }

    return null;
  }

  // Get pricing data for API (matches Prix model)
  Map<String, dynamic> getPricingData() {
    return {
      'hai': parseCurrency(haiController.text),
      'honorairePourcentage': honorairePourcentageController.text.isNotEmpty
          ? parseCurrency(honorairePourcentageController.text)
          : null,
      'honoraireEuros': honoraireEurosController.text.isNotEmpty
          ? parseCurrency(honoraireEurosController.text)
          : null,
      'chargesAcheteurVendeur': selectedChargesType.value.isNotEmpty
          ? selectedChargesType.value
          : null,
      'netVendeur': netVendeurController.text.isNotEmpty
          ? parseCurrency(netVendeurController.text)
          : null,
      'chargesAnnuellesCopropriete':
          chargesAnnuellesCoproprieteController.text.isNotEmpty
              ? parseCurrency(chargesAnnuellesCoproprieteController.text)
              : null,
    };
  }

  @override
  void onClose() {
    // AJOUTEZ ces lignes au début :
    _saveTimer?.cancel();
    if (validatePricing()) {
      _saveDataToManager();
    }

    // Votre code existant :
    haiController.dispose();
    honorairePourcentageController.dispose();
    honoraireEurosController.dispose();
    chargesAcheteurVendeurController.dispose();
    netVendeurController.dispose();
    chargesAnnuellesCoproprieteController.dispose();

    haiFocusNode.dispose();
    honorairePourcentageFocusNode.dispose();
    honoraireEurosFocusNode.dispose();
    chargesAcheteurVendeurFocusNode.dispose();
    netVendeurFocusNode.dispose();
    chargesAnnuellesCoproprieteeFocusNode.dispose();

    super.onClose();
  }
}
