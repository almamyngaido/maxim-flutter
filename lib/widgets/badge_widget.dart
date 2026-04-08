import 'package:flutter/material.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';

enum BadgeType { location, vente, verifie, vedette, premium, pro, gratuit, statut }

class BadgeWidget extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double fontSize;

  const BadgeWidget({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    this.fontSize = 11,
  });

  /// Badge "Location" — fond navy
  factory BadgeWidget.location() => const BadgeWidget(
        label: 'Location',
        backgroundColor: DiwaneColors.navy,
        textColor: Colors.white,
      );

  /// Badge "Vente" — fond orange
  factory BadgeWidget.vente() => const BadgeWidget(
        label: 'Vente',
        backgroundColor: DiwaneColors.orange,
        textColor: Colors.white,
      );

  /// Badge "✓ Vérifié" — fond vert pâle
  factory BadgeWidget.verifie() => const BadgeWidget(
        label: '✓ Vérifié',
        backgroundColor: DiwaneColors.successBg,
        textColor: DiwaneColors.success,
      );

  /// Badge "🔥 En vedette"
  factory BadgeWidget.vedette() => const BadgeWidget(
        label: '🔥 En vedette',
        backgroundColor: DiwaneColors.orangeLight,
        textColor: DiwaneColors.orange,
      );

  /// Badge "Premium 💎"
  factory BadgeWidget.premium() => const BadgeWidget(
        label: 'Premium 💎',
        backgroundColor: DiwaneColors.navyLight,
        textColor: DiwaneColors.navy,
      );

  /// Badge "Pro"
  factory BadgeWidget.pro() => const BadgeWidget(
        label: 'Pro',
        backgroundColor: DiwaneColors.navy,
        textColor: Colors.white,
      );

  /// Badge "Gratuit"
  factory BadgeWidget.gratuit() => const BadgeWidget(
        label: 'Gratuit',
        backgroundColor: DiwaneColors.background,
        textColor: DiwaneColors.textMuted,
      );

  /// Badge statut personnalisé
  factory BadgeWidget.statut(String statut) {
    final (bg, fg) = switch (statut) {
      'publie'      => (DiwaneColors.successBg, DiwaneColors.success),
      'en_attente'  => (const Color(0xFFFFF8E1), const Color(0xFFF57F17)),
      'brouillon'   => (DiwaneColors.background, DiwaneColors.textMuted),
      'expire'      => (const Color(0xFFFFEBEE), DiwaneColors.error),
      _             => (DiwaneColors.background, DiwaneColors.textMuted),
    };
    final label = switch (statut) {
      'publie'     => 'Publié',
      'en_attente' => 'En attente',
      'brouillon'  => 'Brouillon',
      'expire'     => 'Expiré',
      _            => statut,
    };
    return BadgeWidget(label: label, backgroundColor: bg, textColor: fg);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFont.interSemiBold,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
