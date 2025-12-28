import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/auth.service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class EmailVerificationOtpController extends GetxController {
  TextEditingController pinController = TextEditingController();

  RxString otp = ''.obs;
  RxBool isOTPValid = false.obs;
  RxInt countdown = 60.obs;
  RxBool isLoading = false.obs;
  RxBool isResending = false.obs;
  Timer? timer;

  // Email passed from registration/login
  late String userEmail;

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
    // Get email from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    userEmail = args?['email'] ?? '';

    if (userEmail.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Email manquant. Veuillez réessayer.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
      return;
    }

    startCountdown();
  }

  void validateOTP(String value) {
    otp.value = value;
    isOTPValid.value = otp.value.length == 6 && _isNumeric(otp.value);
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

  String get formattedCountdown {
    int minutes = countdown.value ~/ 60;
    int seconds = countdown.value % 60;
    return '${_formatTimeComponent(minutes)}:${_formatTimeComponent(seconds)}';
  }

  String _formatTimeComponent(int time) {
    return time < 10 ? '0$time' : '$time';
  }

  // Verify OTP
  Future<void> verifyOtp() async {
    if (pinController.text.length != 6) {
      Get.snackbar(
        'Erreur',
        'Veuillez saisir un code OTP à 6 chiffres',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      print('Verifying OTP for email: $userEmail');
      print('OTP: ${pinController.text.trim()}');

      await authService.verifyEmailOtp(userEmail, pinController.text.trim());

      Get.snackbar(
        'Succès',
        'Votre compte a été vérifié avec succès !',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Clear the registration form if it exists
      try {
        final registerController = Get.find<dynamic>(tag: 'RegisterController');
        if (registerController != null && registerController.hasMethod('clearFormAfterSuccess')) {
          registerController.clearFormAfterSuccess();
        }
      } catch (e) {
        // RegisterController not found, that's okay
        print('RegisterController not found: $e');
      }

      // Navigate to login
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.loginView);
    } catch (e) {
      print('OTP verification error: $e');

      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('Invalid or expired OTP')) {
        errorMessage = 'Code OTP invalide ou expiré. Veuillez réessayer.';
      } else if (errorMessage.contains('User already verified')) {
        errorMessage = 'Votre compte est déjà vérifié. Veuillez vous connecter.';
        // Navigate to login after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          Get.offAllNamed(AppRoutes.loginView);
        });
      }

      Get.snackbar(
        'Erreur',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOtp() async {
    if (countdown.value > 0) {
      Get.snackbar(
        'Info',
        'Veuillez attendre ${formattedCountdown} avant de renvoyer le code',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isResending.value = true;

      print('Resending OTP to email: $userEmail');

      await authService.resendEmailOtp(userEmail);

      Get.snackbar(
        'Succès',
        'Code OTP renvoyé à votre email !',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Restart countdown
      startCountdown();
    } catch (e) {
      print('Resend OTP error: $e');

      String errorMessage = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Erreur',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isResending.value = false;
    }
  }

  @override
  void onClose() {
    timer?.cancel();
    pinController.dispose();
    super.onClose();
  }
}
