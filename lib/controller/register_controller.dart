import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/register_country_picker_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/auth.service.dart';

class RegisterController extends GetxController {
  // Focus states
  RxBool hasNomFocus = false.obs;
  RxBool hasNomInput = false.obs;
  RxBool hasPrenomFocus = false.obs;
  RxBool hasPrenomInput = false.obs;
  RxBool hasEmailFocus = false.obs;
  RxBool hasEmailInput = false.obs;
  RxBool hasMotDePasseFocus = false.obs;
  RxBool hasMotDePasseInput = false.obs;
  RxBool hasPhoneNumberFocus = false.obs;
  RxBool hasPhoneNumberInput = false.obs;

  // Focus nodes
  FocusNode nomFocusNode = FocusNode();
  FocusNode prenomFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode motDePasseFocusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();

  // Text controllers
  TextEditingController nomController = TextEditingController();
  TextEditingController prenomController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController motDePasseController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  // UI state
  RxInt selectOption = 0.obs;
  RxBool isChecked = false.obs;
  RxBool isLoading = false.obs;

  // Initialize AuthService directly
  AuthService get authService {
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService());
    }
    return Get.find<AuthService>();
  }

  @override
  void onInit() {
    super.onInit();
    _setupFocusListeners();
    _setupInputListeners();
  }

  void _setupFocusListeners() {
    nomFocusNode.addListener(() {
      hasNomFocus.value = nomFocusNode.hasFocus;
    });
    prenomFocusNode.addListener(() {
      hasPrenomFocus.value = prenomFocusNode.hasFocus;
    });
    emailFocusNode.addListener(() {
      hasEmailFocus.value = emailFocusNode.hasFocus;
    });
    motDePasseFocusNode.addListener(() {
      hasMotDePasseFocus.value = motDePasseFocusNode.hasFocus;
    });
    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });
  }

  void _setupInputListeners() {
    nomController.addListener(() {
      hasNomInput.value = nomController.text.isNotEmpty;
    });
    prenomController.addListener(() {
      hasPrenomInput.value = prenomController.text.isNotEmpty;
    });
    emailController.addListener(() {
      hasEmailInput.value = emailController.text.isNotEmpty;
    });
    motDePasseController.addListener(() {
      hasMotDePasseInput.value = motDePasseController.text.isNotEmpty;
    });
    phoneNumberController.addListener(() {
      hasPhoneNumberInput.value = phoneNumberController.text.isNotEmpty;
    });
  }

  void updateOption(int index) {
    selectOption.value = index;
  }

  void toggleCheckbox() {
    isChecked.toggle();
  }

  RxList<String> optionList = [
    AppString.yes,
    AppString.no,
  ].obs;

  // Form validation
  bool get isFormValid {
    return nomController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneNumberController.text.isNotEmpty &&
        motDePasseController.text.length >= 8 &&
        isChecked.value &&
        _isValidEmail(emailController.text);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Register user
  // Modified registerUser method - don't clear form immediately
  Future<void> registerUser() async {
    if (!isFormValid) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs requis correctement',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Get selected country code
      final RegisterCountryPickerController countryController =
          Get.find<RegisterCountryPickerController>();
      final selectedCountryData =
          countryController.countries[countryController.selectedIndex.value];
      final countryCode = selectedCountryData[AppString.codeText] ?? '+33';

      // Format phone number with country code
      String formattedPhone = phoneNumberController.text;
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '$countryCode${phoneNumberController.text}';
      }

      final signupData = {
        'nom': nomController.text.trim(),
        'prenom': prenomController.text.trim().isEmpty
            ? null
            : prenomController.text.trim(),
        'email': emailController.text.trim().toLowerCase(),
        'phoneNumber': formattedPhone,
        'motDePasse': motDePasseController.text,
        'role': selectOption.value == 0
            ? 'agent'
            : 'user', // Yes = agent, No = user
        'dateInscription':
            DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD format
      };

      print(
          'Registration email before API call: ${emailController.text.trim()}'); // Debug

      await authService.signup(signupData);

      Get.snackbar(
        'Succès',
        'Inscription réussie ! Vérifiez votre email pour le code OTP.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      print(
          'Registration successful, email still available: ${emailController.text.trim()}'); // Debug

      // DON'T clear form here - clear it only after successful OTP verification
      // _clearForm(); // <-- Commented out
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Method to clear form - call this after successful OTP verification
  void clearFormAfterSuccess() {
    _clearForm();
  }

  void _clearForm() {
    nomController.clear();
    prenomController.clear();
    emailController.clear();
    motDePasseController.clear();
    phoneNumberController.clear();
    selectOption.value = 0;
    isChecked.value = false;
  }

  @override
  void onClose() {
    nomFocusNode.dispose();
    prenomFocusNode.dispose();
    emailFocusNode.dispose();
    motDePasseFocusNode.dispose();
    phoneNumberFocusNode.dispose();
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    motDePasseController.dispose();
    phoneNumberController.dispose();
    super.onClose();
  }
}
