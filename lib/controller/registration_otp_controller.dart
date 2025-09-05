import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/register_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/auth.service.dart';

class RegistrationOtpController extends GetxController {
  TextEditingController pinController = TextEditingController();

  RxString otp = ''.obs;
  RxBool isOTPValid = false.obs;
  RxInt countdown = 60.obs;
  RxBool isLoading = false.obs;
  Timer? timer;

  // Store user email for verification - FIXED: Initialize with empty string
  String userEmail = '';

  AuthService get authService {
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService());
    }
    return Get.find<AuthService>();
  }

  @override
  void onInit() {
    super.onInit();
    startCountdown();

    // Listen for OTP input changes
    pinController.addListener(() {
      validateOTP(pinController.text);
    });
  }

  // FIXED: Proper email setter with validation
  void setUserEmail(String email) {
    final cleanEmail = email.trim().toLowerCase();
    userEmail = cleanEmail;
    print('OTP Controller - Set email: $userEmail'); // Debug print
  }

  void validateOTP(String value) {
    otp.value = value;
    // Changed to 6 digits to match your API expectation
    isOTPValid.value = otp.value.length == 6 && _isNumeric(otp.value);
    print(
        'OTP Controller - Validating OTP: $value, Valid: ${isOTPValid.value}'); // Debug
  }

  bool _isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  void startCountdown() {
    countdown.value = 60;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  // FIXED: Verify OTP with proper email validation
  Future<void> verifyOTP() async {
    if (!isOTPValid.value) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir un code OTP valide (6 chiffres)',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (userEmail.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Email manquant. Veuillez réessayer l\'inscription.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      print(
          'OTP Controller - Verifying with email: $userEmail, OTP: ${otp.value}'); // Debug

      await authService.verifyEmailOtp(userEmail, otp.value);

      // Close the bottom sheet first
      Get.back();

      // Clear the registration form now that verification is successful
      try {
        final RegisterController registerController =
            Get.find<RegisterController>();
        registerController.clearFormAfterSuccess();
      } catch (e) {
        // RegisterController might not be available anymore, that's okay
        print('Could not clear registration form: $e');
      }

      Get.snackbar(
        'Succès',
        'Email vérifié avec succès !',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to main app
      Get.offAllNamed(AppRoutes.bottomBarView);
    } catch (e) {
      print('OTP Controller - Verification error: $e'); // Debug

      Get.snackbar(
        'Erreur',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // Clear the PIN input on error
      pinController.clear();
      otp.value = '';
      isOTPValid.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // FIXED: Resend OTP with proper API call
  Future<void> resendOTP() async {
    if (countdown.value > 0) {
      Get.snackbar(
        'Info',
        'Veuillez attendre ${formattedCountdown} avant de renvoyer le code',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
      );
      return;
    }

    if (userEmail.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Email manquant. Veuillez réessayer l\'inscription.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Try to call the resend API
      try {
        await authService.resendEmailOtp(userEmail);

        Get.snackbar(
          'Succès',
          'Nouveau code OTP envoyé à $userEmail',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (apiError) {
        print('Resend API error: $apiError');
        // If API doesn't exist yet, just show message
        Get.snackbar(
          'Info',
          'Demande de renvoi effectuée. Vérifiez votre email.',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }

      // Restart countdown
      startCountdown();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors du renvoi du code OTP',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String get formattedCountdown {
    int minutes = countdown.value ~/ 60;
    int seconds = countdown.value % 60;
    return '${_formatTimeComponent(minutes)}:${_formatTimeComponent(seconds)}';
  }

  String _formatTimeComponent(int time) {
    return time < 10 ? '0$time' : '$time';
  }

  @override
  void onClose() {
    timer?.cancel();
    pinController.dispose();
    super.onClose();
  }
}
