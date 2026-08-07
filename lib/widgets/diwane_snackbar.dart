import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';

/// Notifications standardisées Diwane — coins arrondis, position basse, icône par type.
class DiwaneSnackbar {
  static void success(String title, String message) => _show(
        title,
        message,
        DiwaneColors.success,
        Icons.check_circle_outline_rounded,
      );

  static void error(String title, String message) => _show(
        title,
        message,
        DiwaneColors.error,
        Icons.error_outline_rounded,
      );

  static void warning(String title, String message) => _show(
        title,
        message,
        DiwaneColors.orange,
        Icons.info_outline_rounded,
      );

  static void _show(String title, String message, Color color, IconData icon) {
    Get.snackbar(
      title,
      message,
      backgroundColor: color.withValues(alpha: 0.95),
      colorText: Colors.white,
      icon: Icon(icon, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 4),
    );
  }
}
