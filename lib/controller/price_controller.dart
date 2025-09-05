import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PricingController extends GetxController {
  // Controllers for all pricing fields
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
    // Initialize input listeners
    _initializeListeners();

    // Add listeners for automatic calculations
    haiController.addListener(_calculateNetVendeur);
    honorairePourcentageController.addListener(_calculateHonoraireEuros);
    honoraireEurosController.addListener(_calculateHonorairePourcentage);
  }

  void _initializeListeners() {
    haiController.addListener(() {
      haiHasInput.value = haiController.text.isNotEmpty;
      haiText.value = haiController.text; // Update reactive text
    });
    honorairePourcentageController.addListener(() {
      honorairePourcentageHasInput.value =
          honorairePourcentageController.text.isNotEmpty;
    });
    honoraireEurosController.addListener(() {
      honoraireEurosHasInput.value = honoraireEurosController.text.isNotEmpty;
      honoraireEurosText.value =
          honoraireEurosController.text; // Update reactive text
    });
    chargesAcheteurVendeurController.addListener(() {
      chargesAcheteurVendeurHasInput.value =
          chargesAcheteurVendeurController.text.isNotEmpty;
    });
    netVendeurController.addListener(() {
      netVendeurHasInput.value = netVendeurController.text.isNotEmpty;
      netVendeurText.value = netVendeurController.text; // Update reactive text
    });
    chargesAnnuellesCoproprieteController.addListener(() {
      chargesAnnuellesCoproprieteHasInput.value =
          chargesAnnuellesCoproprieteController.text.isNotEmpty;
    });
  }

  // Update charges type
  void updateChargesType(String? value) {
    selectedChargesType.value = value ?? '';
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
    // Dispose all controllers and focus nodes
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
