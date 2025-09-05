import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EnergyDiagnosticsController extends GetxController {
  // Reactive variables for diagnostics
  final RxString selectedDpe = ''.obs;
  final RxString selectedGes = ''.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  // Text controller for date display
  final TextEditingController dateController = TextEditingController();

  // Focus node for date field
  final FocusNode dateFocusNode = FocusNode();
  final RxBool dateHasInput = false.obs;

  // Energy rating options (A is best, G is worst)
  final List<String> energyRatings = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];

  // Rating descriptions and colors
  final Map<String, Map<String, dynamic>> ratingInfo = {
    'A': {
      'label': 'Très performant',
      'description': 'Consommation très faible',
      'color': const Color(0xFF2E7D32), // Dark green
    },
    'B': {
      'label': 'Performant',
      'description': 'Consommation faible',
      'color': const Color(0xFF43A047), // Green
    },
    'C': {
      'label': 'Assez performant',
      'description': 'Consommation modérée',
      'color': const Color(0xFF8BC34A), // Light green
    },
    'D': {
      'label': 'Peu performant',
      'description': 'Consommation moyenne',
      'color': const Color(0xFFFFC107), // Yellow
    },
    'E': {
      'label': 'Peu performant',
      'description': 'Consommation élevée',
      'color': const Color(0xFFFF9800), // Orange
    },
    'F': {
      'label': 'Très peu performant',
      'description': 'Consommation très élevée',
      'color': const Color(0xFFFF5722), // Deep orange
    },
    'G': {
      'label': 'Extrêmement peu performant',
      'description': 'Consommation excessive',
      'color': const Color(0xFFD32F2F), // Red
    },
  };

  @override
  void onInit() {
    super.onInit();
    // Initialize date controller listener
    dateController.addListener(() {
      dateHasInput.value = dateController.text.isNotEmpty;
    });
  }

  // Update DPE rating
  void updateDpe(String? rating) {
    selectedDpe.value = rating ?? '';
  }

  // Update GES rating
  void updateGes(String? rating) {
    selectedGes.value = rating ?? '';
  }

  // Show date picker and update selected date
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000), // DPE diagnostics started around 2006
      lastDate: DateTime.now()
          .add(const Duration(days: 30)), // Allow future dates within a month
      locale: const Locale('fr', 'FR'), // Now this will work!
      helpText: 'Sélectionner la date du diagnostic',
      cancelText: 'Annuler',
      confirmText: 'Confirmer',
    );

    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      dateController.text = formatDateForDisplay(picked);
    }
  }

  // Format date for display
  String formatDateForDisplay(DateTime date) {
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // Format date for API (ISO format)
  String? formatDateForApi(DateTime? date) {
    if (date == null) return null;
    return date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
  }

  // Get color for rating
  Color getRatingColor(String rating) {
    return ratingInfo[rating]?['color'] ?? Colors.grey;
  }

  // Get label for rating
  String getRatingLabel(String rating) {
    return ratingInfo[rating]?['label'] ?? '';
  }

  // Get description for rating
  String getRatingDescription(String rating) {
    return ratingInfo[rating]?['description'] ?? '';
  }

  // Clear date selection
  void clearDate() {
    selectedDate.value = null;
    dateController.clear();
  }

  // Validation (all fields are optional)
  bool validateDiagnostics() {
    // All fields are optional, so always valid
    return true;
  }

  // Get validation error (should always return null since all optional)
  String? getValidationError() {
    // Check if date is not in the future by more than 30 days
    if (selectedDate.value != null) {
      final now = DateTime.now();
      final maxFutureDate = now.add(const Duration(days: 30));
      if (selectedDate.value!.isAfter(maxFutureDate)) {
        return 'La date du diagnostic ne peut pas être trop éloignée dans le futur';
      }
      // Check if date is not too old (before DPE was mandatory)
      if (selectedDate.value!.isBefore(DateTime(2000))) {
        return 'La date du diagnostic semble trop ancienne';
      }
    }
    return null;
  }

  // Check if any diagnostic info is provided
  bool hasDiagnosticInfo() {
    return selectedDpe.value.isNotEmpty ||
        selectedGes.value.isNotEmpty ||
        selectedDate.value != null;
  }

  // Get energy diagnostics data for API (matches DiagnosticsEnergie model)
  Map<String, dynamic> getEnergyDiagnosticsData() {
    return {
      'dpe': selectedDpe.value.isNotEmpty ? selectedDpe.value : null,
      'ges': selectedGes.value.isNotEmpty ? selectedGes.value : null,
      'dateDiagnostique': formatDateForApi(selectedDate.value),
    };
  }

  @override
  void onClose() {
    dateController.dispose();
    dateFocusNode.dispose();
    super.onClose();
  }
}
