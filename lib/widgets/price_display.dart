import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';

/// Formate un montant en FCFA selon le standard Diwane
/// Ex: 350000 → "350 000 FCFA/mois"  |  85000000 → "85 000 000 FCFA"
String formatPrixFcfa(double montant, {bool isLocation = false}) {
  final formatted = NumberFormat('#,###', 'fr_FR').format(montant.round());
  return isLocation ? '$formatted FCFA/mois' : '$formatted FCFA';
}

class PriceDisplay extends StatelessWidget {
  final double montant;
  final bool isLocation;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;

  const PriceDisplay({
    super.key,
    required this.montant,
    this.isLocation = false,
    this.fontSize = 16,
    this.color = DiwaneColors.navy,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: NumberFormat('#,###', 'fr_FR').format(montant.round()),
            style: TextStyle(
              fontFamily: AppFont.interBold,
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
            ),
          ),
          TextSpan(
            text: isLocation ? ' FCFA/mois' : ' FCFA',
            style: TextStyle(
              fontFamily: AppFont.interRegular,
              fontSize: fontSize - 2,
              fontWeight: FontWeight.w400,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
