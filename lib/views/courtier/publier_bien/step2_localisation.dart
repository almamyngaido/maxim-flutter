import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/publier_bien_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/ville_dropdown.dart';

class Step2Localisation extends StatelessWidget {
  const Step2Localisation({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PublierBienController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ville
          const _Label('Ville *'),
          const SizedBox(height: 8),
          Obx(() => VilleDropdown(
            value: c.ville.value.isEmpty ? null : c.ville.value,
            onChanged: (v) => c.ville.value = v ?? '',
          )),
          const SizedBox(height: 16),

          // Quartier
          const _Label('Quartier *'),
          const SizedBox(height: 8),
          Obx(() => _Champ(
            hintText: 'Ex: Almadies, Mermoz, Plateau…',
            initialValue: c.quartier.value,
            onChanged: (v) => c.quartier.value = v,
            prefixIcon: Icons.location_on_outlined,
          )),
          const SizedBox(height: 16),

          // Adresse
          const _Label('Adresse (optionnelle)'),
          const SizedBox(height: 4),
          const Text(
            'Adresse précise visible uniquement après prise de contact',
            style: TextStyle(fontSize: 12, color: DiwaneColors.textMuted),
          ),
          const SizedBox(height: 8),
          Obx(() => _Champ(
            hintText: 'Ex: Rue 10, Villa 25…',
            initialValue: c.adresse.value,
            onChanged: (v) => c.adresse.value = v,
            prefixIcon: Icons.home_outlined,
          )),
          const SizedBox(height: 16),

          // Points de repère
          const _Label('Points de repère (optionnel)'),
          const SizedBox(height: 8),
          Obx(() => _Champ(
            hintText: "Ex: Près de l'UCAD, derrière Total…",
            initialValue: c.pointsRepere.value,
            onChanged: (v) => c.pointsRepere.value = v,
            prefixIcon: Icons.place_outlined,
            maxLines: 2,
          )),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: DiwaneColors.textPrimary));
  }
}

class _Champ extends StatefulWidget {
  final String hintText;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final IconData? prefixIcon;
  final int maxLines;

  const _Champ({
    required this.hintText,
    required this.initialValue,
    required this.onChanged,
    this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  State<_Champ> createState() => _ChampState();
}

class _ChampState extends State<_Champ> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      maxLines: widget.maxLines,
      style: const TextStyle(fontSize: 15, color: DiwaneColors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: DiwaneColors.textMuted),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: DiwaneColors.textMuted, size: 20)
            : null,
        filled: true,
        fillColor: Colors.white,
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
      ),
    );
  }
}
