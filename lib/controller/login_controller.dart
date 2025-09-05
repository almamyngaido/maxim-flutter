// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Add this import
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/auth.service.dart';

class LoginController extends GetxController {
  // Phone number fields (existing)
  RxBool hasFocus = false.obs;
  RxBool hasInput = false.obs;
  FocusNode focusNode = FocusNode();
  TextEditingController mobileController = TextEditingController();

  // Email/Password fields (new)
  RxBool hasEmailFocus = false.obs;
  RxBool hasEmailInput = false.obs;
  RxBool hasPasswordFocus = false.obs;
  RxBool hasPasswordInput = false.obs;
  RxBool isPasswordVisible = false.obs;

  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Login type toggle
  RxString loginType = 'email'.obs; // 'email' or 'phone'
  RxBool isLoading = false.obs;

  // Initialize GetStorage
  final storage = GetStorage();

  // Get AuthService
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
    // Phone focus
    focusNode.addListener(() {
      hasFocus.value = focusNode.hasFocus;
    });

    // Email focus
    emailFocusNode.addListener(() {
      hasEmailFocus.value = emailFocusNode.hasFocus;
    });

    // Password focus
    passwordFocusNode.addListener(() {
      hasPasswordFocus.value = passwordFocusNode.hasFocus;
    });
  }

  void _setupInputListeners() {
    // Phone input
    mobileController.addListener(() {
      hasInput.value = mobileController.text.isNotEmpty;
    });

    // Email input
    emailController.addListener(() {
      hasEmailInput.value = emailController.text.isNotEmpty;
    });

    // Password input
    passwordController.addListener(() {
      hasPasswordInput.value = passwordController.text.isNotEmpty;
    });
  }

  // Toggle login type
  void toggleLoginType(String type) {
    loginType.value = type;
    // Clear the other form when switching
    if (type == 'email') {
      mobileController.clear();
    } else {
      emailController.clear();
      passwordController.clear();
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  // Validate email
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // Validate phone
  bool _isValidPhone(String phone) {
    return phone.isNotEmpty && phone.length >= 8;
  }

  // Login with Email and Password
  Future<void> loginWithEmail() async {
    if (!_isValidEmail(emailController.text.trim())) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir une adresse email valide',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (passwordController.text.length < 8) {
      Get.snackbar(
        'Erreur',
        'Le mot de passe doit contenir au moins 8 caractères',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final credentials = {
        'identifier': emailController.text.trim().toLowerCase(),
        'type': 'email',
        'motDePasse': passwordController.text,
      };

      print('Login attempt with email: ${emailController.text.trim()}');

      final response = await authService.login(credentials);

      // Handle successful login
      if (response['token'] != null) {
        await storage.write('authToken', response['token']); // Store token
        print('Token stored: ${response['token']}'); // Debug

        Get.snackbar(
          'Succès',
          'Connexion réussie !',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Navigate to main app
        Get.offAllNamed(AppRoutes.bottomBarView);
      }
    } catch (e) {
      print('Login error: $e');

      String errorMessage = e.toString();
      if (errorMessage.contains('Email not verified')) {
        errorMessage = 'Email non vérifié. Veuillez vérifier votre email.';
      } else if (errorMessage.contains('Invalid credentials')) {
        errorMessage = 'Email ou mot de passe incorrect.';
      }

      Get.snackbar(
        'Erreur de connexion',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Login with Phone (OTP)
  Future<void> loginWithPhone() async {
    if (!_isValidPhone(mobileController.text.trim())) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir un numéro de téléphone valide',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Format phone number with country code
      String formattedPhone = mobileController.text.trim();
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+33${mobileController.text.trim()}';
      }

      final credentials = {
        'identifier': formattedPhone,
        'type': 'phone',
      };

      print('Login attempt with phone: $formattedPhone');

      final response = await authService.login(credentials);

      // This should trigger OTP sending according to your backend
      Get.snackbar(
        'Code OTP envoyé',
        'Vérifiez votre email pour le code OTP',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );

      // Navigate to OTP verification
      Get.toNamed(AppRoutes.otpView, arguments: {
        'phone': formattedPhone,
        'isLogin': true,
      });
    } catch (e) {
      print('Phone login error: $e');

      String errorMessage = e.toString();
      if (errorMessage.contains('Email not verified')) {
        errorMessage = 'Compte non vérifié. Veuillez vérifier votre email.';
      } else if (errorMessage.contains('not found')) {
        errorMessage = 'Numéro de téléphone non trouvé.';
      }

      Get.snackbar(
        'Erreur',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Main login method
  Future<void> performLogin() async {
    if (loginType.value == 'email') {
      await loginWithEmail();
    } else {
      await loginWithPhone();
    }
  }

  // Clear all forms
  void clearForms() {
    emailController.clear();
    passwordController.clear();
    mobileController.clear();
  }

  // In LoginController
  Future<void> verifyOtp(String phone, String otp) async {
    try {
      isLoading.value = true;

      final credentials = {
        'identifier': phone,
        'type': 'phone',
        'otp': otp,
      };

      print('OTP verification attempt for phone: $phone');

      final response = await authService.login(credentials);

      if (response['token'] != null) {
        await storage.write('authToken', response['token']);
        print('Token stored after OTP: ${response['token']}');

        Get.snackbar(
          'Succès',
          'Connexion réussie !',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed(AppRoutes.bottomBarView);
      }
    } catch (e) {
      print('OTP verification error: $e');

      String errorMessage = e.toString();
      if (errorMessage.contains('Invalid or expired OTP')) {
        errorMessage = 'Code OTP invalide ou expiré.';
      }

      Get.snackbar(
        'Erreur',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    focusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    mobileController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
