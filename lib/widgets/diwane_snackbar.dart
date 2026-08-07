import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';

/// Messages renvoyés par le backend quand le JWT est invalide/expiré —
/// dans ce cas on tente un refresh silencieux / redirige vers le login
/// plutôt que d'afficher l'erreur brute du serveur.
const _sessionExpiredMarkers = ['Token invalide ou expiré', 'jwt expired', 'jwt malformed'];

/// Notifications standardisées Diwane — coins arrondis, position basse, icône par type.
class DiwaneSnackbar {
  /// À utiliser dans tout `catch (e)` sur un appel API : nettoie le préfixe
  /// "Exception: ", et si l'erreur signale une session expirée/invalide,
  /// déclenche la reconnexion au lieu d'afficher le message brut du serveur.
  static Future<void> apiError(Object cause, {String title = 'Erreur'}) async {
    final message = cause.toString().replaceFirst('Exception: ', '');
    if (_sessionExpiredMarkers.any(message.contains)) {
      await DiwaneAuthController.to.gererExpiration401();
      return;
    }
    error(title, message);
  }

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
