import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'dart:async';

// Enhanced RoomDetail model class with better integration
class RoomDetail {
  String id;
  TextEditingController typeController;
  TextEditingController nomController;
  TextEditingController surfaceController;
  TextEditingController orientationController;
  TextEditingController niveauController;
  TextEditingController descriptionController;

  RxString selectedType;
  RxBool avecBalcon;
  RxBool avecTerrasse;
  RxBool avecDressing;
  RxBool avecSalleDeBainPrivee;

  // Focus nodes for each field
  FocusNode nomFocusNode;
  FocusNode surfaceFocusNode;
  FocusNode orientationFocusNode;
  FocusNode niveauFocusNode;
  FocusNode descriptionFocusNode;

  // Input status tracking
  RxBool nomHasInput;
  RxBool surfaceHasInput;
  RxBool orientationHasInput;
  RxBool niveauHasInput;
  RxBool descriptionHasInput;

  // ADD: Callback for when room data changes
  final VoidCallback? onDataChanged;

  RoomDetail({
    required this.id,
    this.onDataChanged,
  })  : typeController = TextEditingController(),
        nomController = TextEditingController(),
        surfaceController = TextEditingController(),
        orientationController = TextEditingController(),
        niveauController = TextEditingController(),
        descriptionController = TextEditingController(),
        selectedType = ''.obs,
        avecBalcon = false.obs,
        avecTerrasse = false.obs,
        avecDressing = false.obs,
        avecSalleDeBainPrivee = false.obs,
        nomFocusNode = FocusNode(),
        surfaceFocusNode = FocusNode(),
        orientationFocusNode = FocusNode(),
        niveauFocusNode = FocusNode(),
        descriptionFocusNode = FocusNode(),
        nomHasInput = false.obs,
        surfaceHasInput = false.obs,
        orientationHasInput = false.obs,
        niveauHasInput = false.obs,
        descriptionHasInput = false.obs {
    // Initialize listeners with change callbacks
    _initializeListeners();
  }

  void _initializeListeners() {
    nomController.addListener(() {
      nomHasInput.value = nomController.text.isNotEmpty;
      onDataChanged?.call();
    });
    surfaceController.addListener(() {
      surfaceHasInput.value = surfaceController.text.isNotEmpty;
      onDataChanged?.call();
    });
    orientationController.addListener(() {
      orientationHasInput.value = orientationController.text.isNotEmpty;
      onDataChanged?.call();
    });
    niveauController.addListener(() {
      niveauHasInput.value = niveauController.text.isNotEmpty;
      onDataChanged?.call();
    });
    descriptionController.addListener(() {
      descriptionHasInput.value = descriptionController.text.isNotEmpty;
      onDataChanged?.call();
    });

    // Listen to boolean changes
    ever(selectedType, (_) => onDataChanged?.call());
    ever(avecBalcon, (_) => onDataChanged?.call());
    ever(avecTerrasse, (_) => onDataChanged?.call());
    ever(avecDressing, (_) => onDataChanged?.call());
    ever(avecSalleDeBainPrivee, (_) => onDataChanged?.call());
  }

  // Load data from JSON
  void fromJson(Map<String, dynamic> json) {
    selectedType.value = json['type'] ?? '';
    nomController.text = json['nom'] ?? '';
    surfaceController.text = json['surface']?.toString() ?? '';
    orientationController.text = json['orientation'] ?? '';
    niveauController.text = json['niveau']?.toString() ?? '';
    descriptionController.text = json['description'] ?? '';
    avecBalcon.value = json['avecBalcon'] ?? false;
    avecTerrasse.value = json['avecTerrasse'] ?? false;
    avecDressing.value = json['avecDressing'] ?? false;
    avecSalleDeBainPrivee.value = json['avecSalleDeBainPrivee'] ?? false;
  }

  void dispose() {
    typeController.dispose();
    nomController.dispose();
    surfaceController.dispose();
    orientationController.dispose();
    niveauController.dispose();
    descriptionController.dispose();

    nomFocusNode.dispose();
    surfaceFocusNode.dispose();
    orientationFocusNode.dispose();
    niveauFocusNode.dispose();
    descriptionFocusNode.dispose();
  }

  // Convert to API format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': selectedType.value,
      'nom': nomController.text.isNotEmpty ? nomController.text : null,
      'surface': double.tryParse(surfaceController.text) ?? 0,
      'orientation': orientationController.text.isNotEmpty
          ? orientationController.text
          : null,
      'niveau': niveauController.text.isNotEmpty
          ? int.tryParse(niveauController.text)
          : null,
      'description': descriptionController.text.isNotEmpty
          ? descriptionController.text
          : null,
      'avecBalcon': avecBalcon.value,
      'avecTerrasse': avecTerrasse.value,
      'avecDressing': avecDressing.value,
      'avecSalleDeBainPrivee': avecSalleDeBainPrivee.value,
    };
  }

  // Validate this room
  bool isValid() {
    return selectedType.value.isNotEmpty &&
        surfaceController.text.isNotEmpty &&
        (double.tryParse(surfaceController.text) ?? 0) > 0;
  }
}

class RoomDetailsController extends GetxController {
  // Get the central data manager instance
  late final PropertyDataManager _dataManager;

  // List of rooms
  final RxList<RoomDetail> rooms = <RoomDetail>[].obs;

  // ADD: Reactive variable for button state
  final RxBool canProceedValue = false.obs;

  // Room type options
  final List<String> roomTypes = [
    'chambre',
    'cuisine',
    'salleDeBain',
    'salleDEau',
    'wc',
    'sejour',
    'salon',
    'bureau',
    'dressing',
    'cellier',
    'lingerie',
    'entree',
    'couloir',
    'garage',
    'cave',
    'grenier',
    'veranda',
    'degagement'
  ];

  // Room type display names
  final Map<String, String> roomTypeDisplayNames = {
    'chambre': 'Chambre',
    'cuisine': 'Cuisine',
    'salleDeBain': 'Salle de bain',
    'salleDEau': 'Salle d\'eau',
    'wc': 'WC',
    'sejour': 'Séjour',
    'salon': 'Salon',
    'bureau': 'Bureau',
    'dressing': 'Dressing',
    'cellier': 'Cellier',
    'lingerie': 'Lingerie',
    'entree': 'Entrée',
    'couloir': 'Couloir',
    'garage': 'Garage',
    'cave': 'Cave',
    'grenier': 'Grenier',
    'veranda': 'Véranda',
    'degagement': 'Dégagement'
  };

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

    // Load existing data if returning to this step
    _loadExistingData();

    // If no rooms exist, add one by default
    if (rooms.isEmpty) {
      addRoom();
    }

    // Setup reactive validation
    _setupReactiveValidation();
  }

  /// Load existing data when returning to this step
  void _loadExistingData() {
    final existingData = _dataManager.getSectionData<List<dynamic>>('rooms');

    if (existingData != null && existingData.isNotEmpty) {
      // Clear current rooms
      for (final room in rooms) {
        room.dispose();
      }
      rooms.clear();

      // Load existing rooms
      for (final roomData in existingData) {
        final room = RoomDetail(
          id: roomData['id'] ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          onDataChanged: _onRoomDataChanged,
        );
        room.fromJson(roomData);
        rooms.add(room);
      }

      print('📋 Loaded ${rooms.length} existing rooms');
      _updateCanProceed();
    }
  }

  /// Setup reactive validation
  void _setupReactiveValidation() {
    // Listen to room list changes
    ever(rooms, (_) => _updateCanProceed());

    // Initial validation check
    _updateCanProceed();
  }

  /// Update the reactive canProceed value
  void _updateCanProceed() {
    canProceedValue.value = _validateForm();
  }

  /// Internal validation method
  bool _validateForm() {
    if (rooms.isEmpty) return false;

    for (final room in rooms) {
      if (!room.isValid()) return false;
    }
    return true;
  }

  /// Called when any room data changes
  void _onRoomDataChanged() {
    _updateCanProceed();
    _saveDataToManagerDebounced();
  }

  /// Save current form data to central manager (with debounce)
  Timer? _saveTimer;
  void _saveDataToManagerDebounced() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), () {
      _saveDataToManager();
    });
  }

  /// Save current form data to central manager immediately
  void _saveDataToManager() {
    final roomsData = getRoomsData();
    _dataManager.updateRooms(roomsData);
  }

  // Add a new room
  void addRoom() {
    final room = RoomDetail(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      onDataChanged: _onRoomDataChanged,
    );
    rooms.add(room);
    _updateCanProceed();
  }

  // Remove a room by index
  void removeRoom(int index) {
    if (rooms.length > 1 && index >= 0 && index < rooms.length) {
      rooms[index].dispose();
      rooms.removeAt(index);
      _updateCanProceed();
      _saveDataToManagerDebounced();
    }
  }

  // Update room type
  void updateRoomType(int roomIndex, String type) {
    if (roomIndex >= 0 && roomIndex < rooms.length) {
      rooms[roomIndex].selectedType.value = type;
      // onDataChanged will be called automatically via the listener
    }
  }

  // Toggle boolean options
  void toggleBalcon(int roomIndex) {
    if (roomIndex >= 0 && roomIndex < rooms.length) {
      rooms[roomIndex].avecBalcon.value = !rooms[roomIndex].avecBalcon.value;
    }
  }

  void toggleTerrasse(int roomIndex) {
    if (roomIndex >= 0 && roomIndex < rooms.length) {
      rooms[roomIndex].avecTerrasse.value =
          !rooms[roomIndex].avecTerrasse.value;
    }
  }

  void toggleDressing(int roomIndex) {
    if (roomIndex >= 0 && roomIndex < rooms.length) {
      rooms[roomIndex].avecDressing.value =
          !rooms[roomIndex].avecDressing.value;
    }
  }

  void toggleSalleDeBainPrivee(int roomIndex) {
    if (roomIndex >= 0 && roomIndex < rooms.length) {
      rooms[roomIndex].avecSalleDeBainPrivee.value =
          !rooms[roomIndex].avecSalleDeBainPrivee.value;
    }
  }

  // Validation (kept for backward compatibility)
  bool validateRooms() {
    return _validateForm();
  }

  // Get validation error
  String? getValidationError() {
    if (rooms.isEmpty) {
      return 'Veuillez ajouter au moins une pièce';
    }

    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      if (room.selectedType.value.isEmpty) {
        return 'Veuillez sélectionner le type pour la pièce ${i + 1}';
      }
      if (room.surfaceController.text.isEmpty) {
        return 'Veuillez saisir la surface pour la pièce ${i + 1}';
      }
      if ((double.tryParse(room.surfaceController.text) ?? 0) <= 0) {
        return 'La surface doit être positive pour la pièce ${i + 1}';
      }
      if (room.niveauController.text.isNotEmpty &&
          (int.tryParse(room.niveauController.text) ?? 0) <= 0) {
        return 'Le niveau doit être positif pour la pièce ${i + 1}';
      }
    }
    return null;
  }

  // Get rooms data for API
  List<Map<String, dynamic>> getRoomsData() {
    return rooms.map((room) => room.toJson()).toList();
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

      // Navigate to next step - Property Features/Characteristics
      try {
        Get.toNamed(AppRoutes.addPropertyFeaturesView);
      } catch (e) {
        // Fallback: try alternative route names
        print('❌ Navigation error with AppRoutes: $e');

        final alternativeRoutes = [
          '/property-features',
          '/characteristics',
          '/caracteristiques',
          '/features',
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

    // Go back to surfaces page
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

  /// Check if user can proceed (for button state) - NOW REACTIVE
  bool canProceed() {
    return canProceedValue.value;
  }

  /// Get current step info for progress indicator
  Map<String, dynamic> getStepInfo() {
    return {
      'currentStep': 4,
      'totalSteps': 9,
      'progress': _dataManager.getProgress(),
      'stepTitle': 'Détails des pièces',
      'isCompleted': _dataManager.isSectionCompleted('rooms'),
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

    // Dispose all rooms
    for (final room in rooms) {
      room.dispose();
    }
    super.onClose();
  }
}
