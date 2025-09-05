import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PhotosDescriptionController extends GetxController {
  // Controllers for description fields
  final TextEditingController titreController = TextEditingController();
  final TextEditingController annonceController = TextEditingController();

  // Focus nodes
  final FocusNode titreFocusNode = FocusNode();
  final FocusNode annonceFocusNode = FocusNode();

  // Input status tracking
  final RxBool titreHasInput = false.obs;
  final RxBool annonceHasInput = false.obs;

  // Reactive text values for validation
  final RxString titreText = ''.obs;
  final RxString annonceText = ''.obs;

  // Image management
  final RxList<File> selectedImages = <File>[].obs;
  final RxBool isUploadingImages = false.obs;
  final ImagePicker _picker = ImagePicker();

  // Max images allowed
  final int maxImages = 10;

  @override
  void onInit() {
    super.onInit();
    _initializeListeners();
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

  // Image selection methods
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

  // Validation methods
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

  // Get description data for API
  Map<String, dynamic> getDescriptionData() {
    return {
      'titre': titreController.text.trim(),
      'annonce': annonceController.text.trim(),
    };
  }

  // Get image paths for API (this would normally be URLs after upload)
  List<String> getImagePaths() {
    // In a real app, you would upload these to a server first
    // and return the server URLs/paths
    return selectedImages.map((file) => file.path).toList();
  }

  // Character counting helpers
  int get titreCharacterCount => titreController.text.length;
  int get annonceCharacterCount => annonceController.text.length;

  String get titreCharacterDisplay => '$titreCharacterCount/100';
  String get annonceCharacterDisplay => '$annonceCharacterCount/2000';

  @override
  void onClose() {
    titreController.dispose();
    annonceController.dispose();
    titreFocusNode.dispose();
    annonceFocusNode.dispose();
    super.onClose();
  }
}
