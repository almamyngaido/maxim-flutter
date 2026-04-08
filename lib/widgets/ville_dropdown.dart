import 'package:flutter/material.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';

/// Dropdown des 16 villes sénégalaises
class VilleDropdown extends StatelessWidget {
  final String? value;
  final void Function(String?) onChanged;
  final String? Function(String?)? validator;
  final String label;
  final bool withAll; // ajoute "Toutes les villes" comme première option

  const VilleDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.validator,
    this.label = 'Ville',
    this.withAll = false,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      if (withAll)
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Toutes les villes'),
        ),
      ...villesSenegal.map(
        (v) => DropdownMenuItem<String>(
          value: v,
          child: Text(v),
        ),
      ),
    ];

    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      validator: validator ??
          (val) {
            if (!withAll && (val == null || val.isEmpty)) return 'Ville requise';
            return null;
          },
      items: items,
      style: const TextStyle(
        fontFamily: AppFont.interRegular,
        fontSize: 15,
        color: DiwaneColors.textPrimary,
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: DiwaneColors.textMuted),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.location_city_outlined, color: DiwaneColors.textMuted, size: 20),
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
        labelStyle: const TextStyle(
          fontFamily: AppFont.interRegular,
          fontSize: 14,
          color: DiwaneColors.textMuted,
        ),
      ),
      dropdownColor: DiwaneColors.surface,
    );
  }
}
