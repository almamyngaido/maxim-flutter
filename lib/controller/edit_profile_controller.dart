import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/user_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/user_utils.dart';

class EditProfileController extends GetxController {
  final UserService _userService = UserService();

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
  TextEditingController fullNameController = TextEditingController(text: AppString.francisZieme);
  TextEditingController phoneNumberController = TextEditingController(text: AppString.francisZiemeNumber);
  TextEditingController phoneNumber2Controller = TextEditingController();
  TextEditingController emailController = TextEditingController(text: AppString.francisZiemeEmail);
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

  @override
  void onInit() {
    super.onInit();
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