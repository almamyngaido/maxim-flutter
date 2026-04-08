import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';

/// Champ téléphone sénégalais avec préfixe +221 fixe et non modifiable.
/// Valide le format : +221 [37][0-9]{8}
class PhoneInput extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;

  const PhoneInput({
    super.key,
    required this.controller,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
  });

  static bool isValid(String phone) {
    // Accepte soit "7XXXXXXXX" (9 chiffres) soit "+221 7XXXXXXXX"
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 9) {
      return RegExp(r'^[37]\d{8}$').hasMatch(digits);
    }
    if (digits.length == 12) {
      return RegExp(r'^221[37]\d{8}$').hasMatch(digits);
    }
    return false;
  }

  /// Retourne le numéro complet avec préfixe : +221XXXXXXXXX
  static String fullNumber(String localPart) {
    final digits = localPart.replaceAll(RegExp(r'\D'), '');
    return '+221$digits';
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onChanged: onChanged,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      validator: validator ??
          (val) {
            if (val == null || val.isEmpty) return 'Numéro requis';
            if (!isValid(val)) return 'Format invalide (ex: 77 123 45 67)';
            return null;
          },
      style: const TextStyle(
        fontFamily: AppFont.interRegular,
        fontSize: 15,
        color: DiwaneColors.textPrimary,
        letterSpacing: 1.2,
      ),
      decoration: InputDecoration(
        labelText: 'Numéro de téléphone',
        hintText: '7X XXX XX XX',
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin: const EdgeInsets.only(right: 8),
          decoration: const BoxDecoration(
            border: Border(
              right: BorderSide(color: DiwaneColors.cardBorder),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🇸🇳',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(width: 6),
              Text(
                '+221',
                style: TextStyle(
                  fontFamily: AppFont.interSemiBold,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: DiwaneColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        filled: true,
        fillColor: DiwaneColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DiwaneColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DiwaneColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DiwaneColors.navy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DiwaneColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DiwaneColors.error, width: 1.5),
        ),
        labelStyle: const TextStyle(
          fontFamily: AppFont.interRegular,
          fontSize: 14,
          color: DiwaneColors.textMuted,
        ),
        hintStyle: const TextStyle(
          fontFamily: AppFont.interRegular,
          fontSize: 14,
          color: DiwaneColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
