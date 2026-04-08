import 'package:flutter/material.dart';

class AppColor {
  // Primary Colors - Professional Blue & Black Palette
  static const Color primaryColor = Color.fromARGB(255, 14, 41, 74); // Original navy blue
  static const Color primaryDark = Color(0xFF0D47A1); // Deep blue for accents
  static const Color primaryLight = Color(0xFF1976D2); // Medium blue for highlights

  // Neutral Colors - Black and Grays
  static const Color blackColor = Color(0xFF000000); // Pure black
  static const Color textColor = Color(0xFF1A1A1A); // Near black for text
  static const Color textSecondary = Color(0xFF424242); // Dark gray for secondary text
  static const Color descriptionColor = Color(0xFF757575); // Medium gray

  // Background Colors
  static const Color backgroundColor = Color(0XFFF5F5F5); // Light gray background
  static const Color secondaryColor = Color(0XFFFAFAFA); // Off-white background
  static const Color whiteColor = Color(0XFFFFFFFF); // Pure white

  // Accent Colors
  static const Color positiveColor = Color(0XFF2E7D32); // Success green
  static const Color negativeColor = Color(0XFFC62828); // Error red

  // Border Colors
  static const Color borderColor = Color(0XFFE0E0E0); // Light gray border
  static const Color border2Color = Color(0XFFBDBDBD); // Medium gray border

  // Legacy support
  static const Color maximPrimeColor = Color(0xFF1A1A1A); // Near black
}

/// Design system Diwane — palette officielle
class DiwaneColors {
  static const Color navy        = Color(0xFF1B2E6B); // Primaire
  static const Color orange      = Color(0xFFE05A1E); // Accent / CTA
  static const Color navyLight   = Color(0xFFEEF1F9); // Fond bleu pâle
  static const Color orangeLight = Color(0xFFFFF0E8); // Fond orange pâle
  static const Color background  = Color(0xFFF5F5F5); // Fond général
  static const Color surface     = Color(0xFFFFFFFF); // Cards
  static const Color textPrimary = Color(0xFF1A1A2E); // Texte principal
  static const Color textMuted   = Color(0xFF7A7A9A); // Texte secondaire
  static const Color cardBorder  = Color(0x1F1B2E6B); // Bordure cards (12% navy)
  static const Color success     = Color(0xFF2E7D32);
  static const Color successBg   = Color(0xFFE8F5E9);
  static const Color error       = Color(0xFFC62828);
}
