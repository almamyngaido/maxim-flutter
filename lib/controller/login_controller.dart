// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // Add this import
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/auth.service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/session_service.dart';

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
        print('✅ Login successful, initializing session...');

        final sessionService = Get.find<SessionService>();

        // Fetch user data from response or call /me endpoint
        Map<String, dynamic> userData;
        if (response['user'] != null) {
          print('📦 Using user data from response');
          userData = Map<String, dynamic>.from(response['user']);
        } else {
          // If user data not in response, fetch from /me endpoint
          print('🔄 Fetching user data from /me endpoint');
          userData = await authService.getCurrentUser(response['token']);
        }

        print('👤 User data to store: $userData');
        print('🔑 Token: ${response['token']}');

        // Initialize session with user data and token
        try {
          sessionService.initializeSession(userData, response['token']);
          print('✅ Session initialized successfully');
        } catch (sessionError) {
          print('❌ Error initializing session: $sessionError');
          print('❌ Session error details: ${sessionError.runtimeType}');
          rethrow;
        }

        print('✅ Session initialized, navigating to home');

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
        // Redirect to OTP verification screen
        Get.snackbar(
          'Vérification requise',
          'Votre compte n\'est pas encore vérifié. Veuillez entrer le code OTP reçu par email.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );

        // Navigate to email verification OTP screen
        await Future.delayed(const Duration(milliseconds: 500));
        Get.toNamed(AppRoutes.emailVerificationOtpView, arguments: {
          'email': emailController.text.trim().toLowerCase(),
        });
        return; // Don't show additional error
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

  // Reset controller state
  void reset() {
    clearForms();
    hasFocus.value = false;
    hasInput.value = false;
    hasEmailFocus.value = false;
    hasEmailInput.value = false;
    hasPasswordFocus.value = false;
    hasPasswordInput.value = false;
    isPasswordVisible.value = false;
    loginType.value = 'email';
    isLoading.value = false;
    print('🔄 LoginController reset');
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
        final sessionService = Get.find<SessionService>();

        // Fetch user data from response or call /me endpoint
        Map<String, dynamic> userData;
        if (response['user'] != null) {
          userData = response['user'];
        } else {
          userData = await authService.getCurrentUser(response['token']);
        }

        // Initialize session with user data and token
        sessionService.initializeSession(userData, response['token']);

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
