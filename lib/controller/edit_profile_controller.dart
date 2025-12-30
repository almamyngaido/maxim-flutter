import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/user_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/user_utils.dart';

class EditProfileController extends GetxController {
  final UserService _userService = UserService();
  final storage = GetStorage();

  RxBool hasFullNameFocus = true.obs;
  RxBool hasFullNameInput = true.obs;
  RxBool hasPhoneNumberFocus = true.obs;
  RxBool hasPhoneNumberInput = true.obs;
  RxBool hasPhoneNumber2Focus = false.obs;
  RxBool hasPhoneNumber2Input = false.obs;
  RxBool hasEmailFocus = true.obs;
  RxBool hasEmailInput = true.obs;
  FocusNode focusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode phoneNumber2FocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController phoneNumber2Controller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController aboutMeController = TextEditingController();
  TextEditingController whatAreYouHereController = TextEditingController();

  RxBool isWhatAreYouHereExpanded = false.obs;
  RxInt isWhatAreYouHereSelect = 0.obs;
  RxString profileImagePath = ''.obs;
  Rx<Uint8List?> webImage = Rx<Uint8List?>(null);
  RxString profileImage = "".obs;

  // Variables pour l'upload de fichiers
  RxBool isUploadingFile = false.obs;
  RxString selectedFileName = ''.obs;
  RxString selectedFilePath = ''.obs;

  // Loading state for save operation
  RxBool isSavingProfile = false.obs;

  // User data
  String? userId;
  Map<String, dynamic>? currentUserData;

  @override
  void onInit() {
    super.onInit();

    // Load current user data
    _loadUserData();

    focusNode.addListener(() {
      hasFullNameFocus.value = focusNode.hasFocus;
    });
    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });
    phoneNumber2FocusNode.addListener(() {
      hasPhoneNumber2Focus.value = phoneNumber2FocusNode.hasFocus;
    });
    emailFocusNode.addListener(() {
      hasEmailFocus.value = emailFocusNode.hasFocus;
    });
    fullNameController.addListener(() {
      hasFullNameInput.value = fullNameController.text.isNotEmpty;
    });
    phoneNumberController.addListener(() {
      hasPhoneNumberInput.value = phoneNumberController.text.isNotEmpty;
    });
    phoneNumber2Controller.addListener(() {
      hasPhoneNumber2Input.value = phoneNumber2Controller.text.isNotEmpty;
    });
    emailController.addListener(() {
      hasEmailInput.value = emailController.text.isNotEmpty;
    });
  }

  /// Load current user data and populate form fields
  void _loadUserData() {
    try {
      currentUserData = loadUserData();

      if (currentUserData != null) {
        userId = currentUserData!['id']?.toString();

        // Populate form fields with current user data
        final prenom = currentUserData!['prenom']?.toString() ?? '';
        final nom = currentUserData!['nom']?.toString() ?? '';
        fullNameController.text = '$prenom $nom'.trim();

        emailController.text = currentUserData!['email']?.toString() ?? '';
        phoneNumberController.text = currentUserData!['phoneNumber']?.toString() ?? '';

        // Set the role dropdown
        final role = currentUserData!['role']?.toString() ?? '';
        if (role.isNotEmpty) {
          // Map backend role to UI text
          int roleIndex = 0;
          if (role == 'user') roleIndex = 0; // "To buy property"
          else if (role == 'agent') roleIndex = 2; // "I am a broker"

          updateWhatAreYouHere(roleIndex);
        }

        print('✅ User data loaded: ${currentUserData!['email']}');
      } else {
        print('⚠️ No user data found in storage');
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les données utilisateur',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Save profile changes
  Future<void> saveProfile() async {
    try {
      isSavingProfile.value = true;

      // Get auth token
      String? token = storage.read('authToken');
      if (token == null || token.isEmpty) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      }

      if (userId == null || userId!.isEmpty) {
        throw Exception('ID utilisateur manquant');
      }

      // Validate inputs
      if (fullNameController.text.trim().isEmpty) {
        throw Exception('Le nom complet est requis');
      }

      if (emailController.text.trim().isEmpty) {
        throw Exception('L\'email est requis');
      }

      if (phoneNumberController.text.trim().isEmpty) {
        throw Exception('Le numéro de téléphone est requis');
      }

      // Parse full name into prenom and nom
      final nameParts = fullNameController.text.trim().split(' ');
      final prenom = nameParts.length > 1 ? nameParts.first : '';
      final nom = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : nameParts.first;

      // Get selected role
      String? role;
      if (whatAreYouHereController.text.isNotEmpty) {
        // Map UI text to backend role
        if (isWhatAreYouHereSelect.value == 0) role = 'user'; // "To buy property"
        else if (isWhatAreYouHereSelect.value == 1) role = 'user'; // "To sell property"
        else if (isWhatAreYouHereSelect.value == 2) role = 'agent'; // "I am a broker"
      }

      print('🔄 Updating profile for user: $userId');

      // Call the update API
      final response = await _userService.updateUserProfile(
        userId: userId!,
        token: token,
        nom: nom,
        prenom: prenom,
        email: emailController.text.trim(),
        phoneNumber: phoneNumberController.text.trim(),
        role: role,
      );

      print('✅ Profile updated successfully');

      // Update stored user data
      if (response.isNotEmpty) {
        await storage.write('userData', jsonEncode(response));
        print('✅ User data updated in storage');
      }

      Get.snackbar(
        'Succès',
        'Profil mis à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.2),
        colorText: Get.theme.primaryColor,
      );

      // Go back to profile view
      await Future.delayed(Duration(milliseconds: 500));
      Get.back();

    } catch (e) {
      print('❌ Error saving profile: $e');
      Get.snackbar(
        'Erreur',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.red,
      );
    } finally {
      isSavingProfile.value = false;
    }
  }

  void toggleWhatAreYouHereExpansion() {
    isWhatAreYouHereExpanded.value = !isWhatAreYouHereExpanded.value;
  }

  void updateWhatAreYouHere(int index) {
    isWhatAreYouHereSelect.value = index;
    whatAreYouHereController.text = whatAreYouHereList[index];
  }

  Future<void> updateProfileImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        webImage.value = await image.readAsBytes();
      } else {
        profileImage.value = image.path;
      }
    }
  }

  // Sélectionner un fichier (document, PDF, etc.)
  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null) {
        selectedFilePath.value = result.files.single.path ?? '';
        selectedFileName.value = result.files.single.name;
        print('✅ Fichier sélectionné: ${selectedFileName.value}');

        Get.snackbar(
          'Fichier sélectionné',
          selectedFileName.value,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la sélection du fichier: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner le fichier',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Uploader le fichier vers le serveur
  Future<void> uploadFile() async {
    if (selectedFilePath.value.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez d\'abord sélectionner un fichier',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isUploadingFile.value = true;

      // Récupérer l'ID de l'utilisateur connecté
      final userData = loadUserData();
      if (userData == null || userData['_id'] == null) {
        throw Exception('Utilisateur non connecté');
      }

      final userId = userData['_id'];

      // Déterminer le type de fichier
      String fileType = 'document';
      final extension = selectedFileName.value.split('.').last.toLowerCase();
      if (['jpg', 'jpeg', 'png'].contains(extension)) {
        fileType = 'image';
      } else if (extension == 'pdf') {
        fileType = 'pdf';
      }

      // Uploader le fichier
      final response = await _userService.uploadProfileFile(
        userId,
        selectedFilePath.value,
        fileType,
      );

      print('✅ Fichier uploadé avec succès: ${response}');

      Get.snackbar(
        'Succès',
        'Fichier uploadé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.1),
      );

      // Réinitialiser la sélection
      selectedFilePath.value = '';
      selectedFileName.value = '';
    } catch (e) {
      print('❌ Erreur lors de l\'upload: $e');
      Get.snackbar(
        'Erreur',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingFile.value = false;
    }
  }

  RxList<String> whatAreYouHereList = [
    AppString.toBuyProperty,
    AppString.toSellProperty,
    AppString.iAmABroker,
  ].obs;

  @override
  void onClose() {
    focusNode.dispose();
    phoneNumberFocusNode.dispose();
    phoneNumber2FocusNode.dispose();
    emailFocusNode.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    phoneNumber2Controller.dispose();
    emailController.dispose();
    aboutMeController.dispose();
    whatAreYouHereController.dispose();
    _userService.dispose();
    super.onClose();
  }
}