import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';

class PhotosDescriptionController extends GetxController {
  // Get the central data manager
  late final PropertyDataManager _propertyDataManager;

  // Controllers for description fields (your existing code)
  final TextEditingController titreController = TextEditingController();
  final TextEditingController annonceController = TextEditingController();

  // Focus nodes (your existing code)
  final FocusNode titreFocusNode = FocusNode();
  final FocusNode annonceFocusNode = FocusNode();

  // Input status tracking (your existing code)
  final RxBool titreHasInput = false.obs;
  final RxBool annonceHasInput = false.obs;

  // Reactive text values for validation (your existing code)
  final RxString titreText = ''.obs;
  final RxString annonceText = ''.obs;

  // Image management (your existing code)
  final RxList<File> selectedImages = <File>[].obs;
  final RxBool isUploadingImages = false.obs;
  final ImagePicker _picker = ImagePicker();

  // Max images allowed (your existing code)
  final int maxImages = 10;

  // NEW: Submission state tracking
  final RxBool isSubmitting = false.obs;
  final RxString submissionStatus = 'Prêt à publier'.obs;
  final RxDouble submissionProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    // Initialize services
    _propertyDataManager = Get.find<PropertyDataManager>();

    // Initialize listeners (your existing code)
    _initializeListeners();

    // NEW: Load existing data if returning to this step
    _loadExistingData();
  }

  void _initializeListeners() {
    titreController.addListener(() {
      titreHasInput.value = titreController.text.isNotEmpty;
      titreText.value = titreController.text;
    });

    annonceController.addListener(() {
      annonceHasInput.value = annonceController.text.isNotEmpty;
      annonceText.value = annonceController.text;
    });
  }

  // NEW: Load existing data from PropertyDataManager
  void _loadExistingData() {
    final existingDescription = _propertyDataManager
        .getSectionData<Map<String, dynamic>>('description');
    if (existingDescription != null) {
      titreController.text = existingDescription['titre'] ?? '';
      annonceController.text = existingDescription['annonce'] ?? '';
      print('Loaded existing description data');
    }

    // Load existing images if any (though typically this is the first time)
    final existingImages =
        _propertyDataManager.getSectionData<List<String>>('images');
    if (existingImages != null && existingImages.isNotEmpty) {
      // Convert paths back to File objects if needed
      selectedImages.addAll(existingImages.map((path) => File(path)));
    }
  }

  // Image selection methods (your existing code - keeping all as is)
  Future<void> pickImageFromCamera() async {
    if (selectedImages.length >= maxImages) {
      Get.snackbar(
        'Limite atteinte',
        'Vous ne pouvez ajouter que $maxImages photos maximum',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImages.add(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de prendre la photo: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickImageFromGallery() async {
    if (selectedImages.length >= maxImages) {
      Get.snackbar(
        'Limite atteinte',
        'Vous ne pouvez ajouter que $maxImages photos maximum',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImages.add(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner la photo: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> pickMultipleImages() async {
    final int remainingSlots = maxImages - selectedImages.length;

    if (remainingSlots <= 0) {
      Get.snackbar(
        'Limite atteinte',
        'Vous ne pouvez ajouter que $maxImages photos maximum',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        // Take only the number of images that fit within the limit
        final List<XFile> imagesToAdd = images.take(remainingSlots).toList();

        for (XFile image in imagesToAdd) {
          selectedImages.add(File(image.path));
        }

        if (images.length > remainingSlots) {
          Get.snackbar(
            'Limite atteinte',
            'Seulement $remainingSlots photos ont été ajoutées (limite: $maxImages)',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner les photos: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final File item = selectedImages.removeAt(oldIndex);
    selectedImages.insert(newIndex, item);
  }

  // Validation methods (your existing code - keeping as is)
  String? getValidationError() {
    if (titreController.text.trim().isEmpty) {
      return 'Veuillez saisir un titre pour l\'annonce';
    }

    if (titreController.text.trim().length < 10) {
      return 'Le titre doit contenir au moins 10 caractères';
    }

    if (titreController.text.trim().length > 100) {
      return 'Le titre ne peut pas dépasser 100 caractères';
    }

    if (annonceController.text.trim().isEmpty) {
      return 'Veuillez saisir la description de l\'annonce';
    }

    if (annonceController.text.trim().length < 50) {
      return 'La description doit contenir au moins 50 caractères';
    }

    if (annonceController.text.trim().length > 2000) {
      return 'La description ne peut pas dépasser 2000 caractères';
    }

    return null;
  }

  bool validateForm() {
    return getValidationError() == null;
  }

  // Get description data for API (your existing code)
  Map<String, dynamic> getDescriptionData() {
    return {
      'titre': titreController.text.trim(),
      'annonce': annonceController.text.trim(),
    };
  }

  // Get image paths for API (your existing code)

  // Character counting helpers (your existing code)
  int get titreCharacterCount => titreController.text.length;
  int get annonceCharacterCount => annonceController.text.length;

  String get titreCharacterDisplay => '$titreCharacterCount/100';
  String get annonceCharacterDisplay => '$annonceCharacterCount/2000';

  // NEW: Save data to PropertyDataManager
  void _saveDataToManager() {
    _propertyDataManager.updateDescriptionAndImages(
      getDescriptionData(),
      selectedImages,
    );
    print('Description and images saved to PropertyDataManager');
  }

  // NEW: Final submission methods
  Future<void> submitProperty() async {
    final error = getValidationError();
    if (error != null) {
      Get.snackbar(
        'Erreur de validation',
        error,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmitting.value = true;
      submissionProgress.value = 0.1;
      submissionStatus.value = 'Sauvegarde des données...';

      // Step 1: Save current data to PropertyDataManager
      _saveDataToManager();

      // Step 2: Validate all data is complete
      submissionProgress.value = 0.2;
      submissionStatus.value = 'Vérification des données...';

      if (!_propertyDataManager.validateRequiredData()) {
        final errors = _propertyDataManager.getValidationErrors();
        throw Exception('Données incomplètes: ${errors.join(', ')}');
      }

      // Step 3: Show loading dialog
      _showSubmissionDialog();

      // Step 4: Submit using PropertyDataManager (which now uses ApiService)
      submissionProgress.value = 0.3;
      submissionStatus.value = 'Publication en cours...';

      final success = await _propertyDataManager.submitProperty();

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (success) {
        // Show success dialog
        _showSuccessDialog();
      }
      // Error handling is already done in PropertyDataManager.submitProperty()
    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Erreur',
        'Une erreur inattendue s\'est produite: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSubmitting.value = false;
      submissionProgress.value = 0.0;
      submissionStatus.value = 'Prêt à publier';
    }
  }

  // NEW: Save as draft
  Future<void> saveAsDraft() async {
    try {
      isSubmitting.value = true;
      submissionStatus.value = 'Sauvegarde du brouillon...';

      // Update with current data
      _saveDataToManager();

      // Save as draft using PropertyDataManager
      final success = await _propertyDataManager.saveAsDraft();

      if (success) {
        Get.snackbar(
          'Brouillon sauvegardé',
          'Votre bien a été sauvegardé comme brouillon',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder le brouillon: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
      submissionStatus.value = 'Prêt à publier';
    }
  }

  // NEW: Show submission loading dialog
  void _showSubmissionDialog() {
    Get.dialog(
      AlertDialog(
        content: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  value: submissionProgress.value > 0
                      ? submissionProgress.value
                      : null,
                ),
                const SizedBox(height: 16),
                Text(submissionStatus.value),
                const SizedBox(height: 8),
                Text(
                  'Veuillez patienter...',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            )),
      ),
      barrierDismissible: false,
    );
  }

  // NEW: Show success dialog
  void _showSuccessDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Succès !'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            const Text('Votre bien immobilier a été créé avec succès !'),
            const SizedBox(height: 8),
            Text(
              'Vous pouvez maintenant le consulter dans la liste de vos biens.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final data = _propertyDataManager.getAllData();
              final propertyId = data['metadata']?['submittedPropertyId'];
              if (propertyId != null) {
                return Text(
                  'ID du bien: $propertyId',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.offAllNamed('/properties'); // Navigate to property list
            },
            child: const Text('Voir mes biens'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              _propertyDataManager.clearAllData(); // Reset for new property
              Get.offAllNamed('/add-property'); // Start new property
            },
            child: const Text('Ajouter un autre bien'),
          ),
        ],
      ),
    );
  }

  // NEW: Debug method to check current data
  void debugPrintData() {
    print('=== PhotosDescriptionController Debug ===');
    print('Title: ${titreController.text}');
    print('Description: ${annonceController.text}');
    print('Images: ${selectedImages.length}');
    print('Validation: ${getValidationError() ?? 'OK'}');
    _propertyDataManager.printCurrentData();
  }

  // NEW: Get submission summary for UI
  Map<String, dynamic> getSubmissionSummary() {
    return {
      'canSubmit':
          validateForm() && _propertyDataManager.validateRequiredData(),
      'isSubmitting': isSubmitting.value,
      'submissionStatus': submissionStatus.value,
      'submissionProgress': submissionProgress.value,
      'imageCount': selectedImages.length,
      'titleLength': titreCharacterCount,
      'descriptionLength': annonceCharacterCount,
      'propertyProgress': _propertyDataManager.getProgress(),
      'missingData': _propertyDataManager.getValidationErrors(),
    };
  }

  @override
  void onClose() {
    // Save data before closing
    if (validateForm()) {
      _saveDataToManager();
    }

    titreController.dispose();
    annonceController.dispose();
    titreFocusNode.dispose();
    annonceFocusNode.dispose();
    super.onClose();
  }

// Dans imgDescription.controller.dart, ajoutez SEULEMENT ces 2 méthodes :

  /// Get selected image files for upload
  List<File> getSelectedImageFiles() {
    return selectedImages;
  }

  /// Get image paths as strings (for backward compatibility)
  List<String> getImagePaths() {
    return selectedImages.map((file) => file.path).toList();
  }
}
