import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/publier_bien_controller.dart';

// ─── Configuration des champs selon le type de bien ──────────────────────────

class _TypeConfig {
  final bool showChambres;
  final bool showSdb;
  final bool showToilettes;
  final bool showEtage;
  final bool showAnneeConstruction;
  final bool showEtat;
  final bool showSurface;
  final String surfaceLabel;

  const _TypeConfig({
    this.showChambres = true,
    this.showSdb = true,
    this.showToilettes = true,
    this.showEtage = true,
    this.showAnneeConstruction = true,
    this.showEtat = true,
    this.showSurface = true,
    this.surfaceLabel = 'Surface (m²)',
  });
}

_TypeConfig _configPourType(String type) {
  switch (type) {
    case 'terrain':
      return const _TypeConfig(
        showChambres: false,
        showSdb: false,
        showToilettes: false,
        showEtage: false,
        showAnneeConstruction: false,
        showEtat: false,
        surfaceLabel: 'Superficie (m²)',
      );
    case 'bureau':
    case 'commerce':
    case 'entrepot':
      return const _TypeConfig(
        showChambres: false,
        showSdb: false,
        showToilettes: true,
        showEtage: true,
        showAnneeConstruction: true,
        showEtat: true,
        surfaceLabel: 'Surface (m²)',
      );
    default: // appartement, villa, studio, duplex, chambre
      return const _TypeConfig();
  }
}

// ─── Step 3 ───────────────────────────────────────────────────────────────────

class Step3Caracteristiques extends StatelessWidget {
  const Step3Caracteristiques({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PublierBienController>();

    return Obx(() {
      final cfg = _configPourType(c.typeBien.value);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Chambres ─────────────────────────────────────────────────────
            if (cfg.showChambres) ...[
              _sectionTitle('Nombre de chambres'),
              const SizedBox(height: 8),
              Obx(() => _Stepper(value: c.nbChambres.value, min: 0, max: 10, onChanged: (v) => c.nbChambres.value = v)),
              const SizedBox(height: 16),
            ],

            // ── Surface ───────────────────────────────────────────────────────
            _sectionTitle('${cfg.surfaceLabel}  — optionnel'),
            const SizedBox(height: 8),
            _NumField(
              hintText: 'Ex: 80',
              onChanged: (v) => c.surface.value = v,
              initialValue: c.surface.value,
            ),
            const SizedBox(height: 16),

            // ── Salles de bain ────────────────────────────────────────────────
            if (cfg.showSdb) ...[
              _sectionTitle('Salles de bain'),
              const SizedBox(height: 8),
              Obx(() => _Stepper(value: c.nbSdb.value, min: 0, max: 10, onChanged: (v) => c.nbSdb.value = v)),
              const SizedBox(height: 16),
            ],

            // ── Toilettes ─────────────────────────────────────────────────────
            if (cfg.showToilettes) ...[
              _sectionTitle('Toilettes'),
              const SizedBox(height: 8),
              Obx(() => _Stepper(value: c.nbToilettes.value, min: 0, max: 10, onChanged: (v) => c.nbToilettes.value = v)),
              const SizedBox(height: 16),
            ],

            // ── Étage ─────────────────────────────────────────────────────────
            if (cfg.showEtage) ...[
              _sectionTitle('Étage  — optionnel'),
              const SizedBox(height: 8),
              _NumField(hintText: 'Ex: 2 (0 = RDC)', onChanged: (v) => c.etage.value = v, initialValue: c.etage.value),
              const SizedBox(height: 16),
            ],

            // ── État ──────────────────────────────────────────────────────────
            if (cfg.showEtat) ...[
              _sectionTitle('État du bien'),
              const SizedBox(height: 8),
              Obx(() => Column(
                children: [
                  {'value': 'neuf',            'label': 'Neuf'},
                  {'value': 'bon_etat',        'label': 'Bon état'},
                  {'value': 'a_renover',       'label': 'À rénover'},
                  {'value': 'en_construction', 'label': 'En construction'},
                ].map((e) => RadioListTile<String>(
                  title: Text(e['label']!, style: const TextStyle(color: DiwaneColors.textPrimary, fontSize: 14)),
                  value: e['value']!,
                  groupValue: c.etat.value.isEmpty ? null : c.etat.value,
                  activeColor: DiwaneColors.navy,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => c.etat.value = v!,
                )).toList(),
              )),
              const SizedBox(height: 16),
            ],

            // ── Terrain : viabilisé ───────────────────────────────────────────
            if (c.typeBien.value == 'terrain') ...[
              _sectionTitle('Statut du terrain'),
              const SizedBox(height: 8),
              Obx(() => Column(
                children: [
                  {'value': 'viabilise',     'label': 'Viabilisé (eau, électricité)'},
                  {'value': 'non_viabilise', 'label': 'Non viabilisé'},
                  {'value': 'en_cours',      'label': 'Viabilisation en cours'},
                ].map((e) => RadioListTile<String>(
                  title: Text(e['label']!, style: const TextStyle(color: DiwaneColors.textPrimary, fontSize: 14)),
                  value: e['value']!,
                  groupValue: c.etat.value.isEmpty ? null : c.etat.value,
                  activeColor: DiwaneColors.navy,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => c.etat.value = v!,
                )).toList(),
              )),
              const SizedBox(height: 16),
            ],

            // ── Année de construction ─────────────────────────────────────────
            if (cfg.showAnneeConstruction) ...[
              _sectionTitle('Année de construction  — optionnel'),
              const SizedBox(height: 8),
              _NumField(
                hintText: 'Ex: 2015',
                onChanged: (v) => c.anneeConstruction.value = v,
                initialValue: c.anneeConstruction.value,
                maxLength: 4,
              ),
              const SizedBox(height: 16),
            ],

            // ── Description ───────────────────────────────────────────────────
            _sectionTitle('Description  — optionnel'),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: c.description.value,
              onChanged: (v) => c.description.value = v,
              maxLines: 4,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText: 'Décrivez votre bien : environnement, atouts, état général…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DiwaneColors.textPrimary));
  }
}

// ─── Stepper +/- ─────────────────────────────────────────────────────────────
class _Stepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _Stepper({required this.value, required this.min, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepBtn(icon: Icons.remove, onTap: value > min ? () => onChanged(value - 1) : null),
        const SizedBox(width: 16),
        SizedBox(
          width: 40,
          child: Text('$value', textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DiwaneColors.navy)),
        ),
        const SizedBox(width: 16),
        _StepBtn(icon: Icons.add, onTap: value < max ? () => onChanged(value + 1) : null),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _StepBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: onTap != null ? DiwaneColors.navyLight : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: DiwaneColors.cardBorder),
        ),
        child: Icon(icon, size: 18, color: onTap != null ? DiwaneColors.navy : Colors.grey[400]),
      ),
    );
  }
}

// ─── Champ numérique ──────────────────────────────────────────────────────────
class _NumField extends StatefulWidget {
  final String hintText;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final int? maxLength;

  const _NumField({required this.hintText, required this.initialValue, required this.onChanged, this.maxLength});

  @override
  State<_NumField> createState() => _NumFieldState();
}

class _NumFieldState extends State<_NumField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      maxLength: widget.maxLength,
      style: const TextStyle(fontSize: 15, color: DiwaneColors.textPrimary),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: DiwaneColors.textMuted),
        counterText: '',
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DiwaneColors.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DiwaneColors.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: DiwaneColors.navy, width: 1.5)),
      ),
    );
  }
}
