import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  TextEditingController pinController = TextEditingController();

  RxString otp = ''.obs;
  RxBool isOTPValid = false.obs;
  RxInt countdown = 60.obs;
  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    startCountdown();
  }

  void validateOTP(String value) {
    otp.value = value;
    isOTPValid.value =
        otp.value.length == 6 && _isNumeric(otp.value); // Changed to 6
  }

  bool _isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  void startCountdown() {
    countdown.value = 60;
    timer?.cancel(); // Cancel any existing timer
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

  @override
  void dispose() {
    timer?.cancel();
    pinController.clear();
    pinController.dispose();
    super.dispose();
  }
}
