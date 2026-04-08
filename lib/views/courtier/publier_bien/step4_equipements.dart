import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/publier_bien_controller.dart';

// ─── Équipements disponibles selon le type de bien ───────────────────────────

const _tous = [
  {'key': 'groupe_electrogene', 'label': 'Groupe électrogène'},
  {'key': 'citerne_eau',        'label': "Citerne d'eau"},
  {'key': 'panneau_solaire',    'label': 'Panneau solaire'},
  {'key': 'climatisation',      'label': 'Climatisation'},
  {'key': 'fosse_septique',     'label': 'Fosse septique'},
  {'key': 'puits',              'label': 'Puits'},
  {'key': 'gardien',            'label': 'Gardien'},
  {'key': 'parking',            'label': 'Parking'},
  {'key': 'piscine',            'label': 'Piscine'},
  {'key': 'jardin',             'label': 'Jardin'},
  {'key': 'terrasse',           'label': 'Terrasse'},
  {'key': 'ascenseur',          'label': 'Ascenseur'},
  {'key': 'meuble',             'label': 'Meublé'},
  {'key': 'internet',           'label': 'Internet'},
  {'key': 'digicode',           'label': 'Digicode'},
];

// Clés autorisées par type
const _keysParType = {
  'terrain':   ['groupe_electrogene', 'citerne_eau', 'panneau_solaire', 'puits', 'gardien', 'parking'],
  'bureau':    ['groupe_electrogene', 'panneau_solaire', 'climatisation', 'parking', 'ascenseur', 'internet', 'digicode', 'gardien'],
  'commerce':  ['groupe_electrogene', 'panneau_solaire', 'climatisation', 'parking', 'ascenseur', 'internet', 'digicode', 'gardien'],
  'entrepot':  ['groupe_electrogene', 'panneau_solaire', 'citerne_eau', 'fosse_septique', 'puits', 'parking', 'gardien'],
};

List<Map<String, String>> _equipementsPourType(String type) {
  final keys = _keysParType[type];
  if (keys == null) return _tous.cast(); // résidentiel → tous
  return _tous.where((e) => keys.contains(e['key'])).toList().cast();
}

// ─── Step 4 ───────────────────────────────────────────────────────────────────

class Step4Equipements extends StatelessWidget {
  const Step4Equipements({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PublierBienController>();

    return Obx(() {
      final equipements = _equipementsPourType(c.typeBien.value);

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quels équipements propose votre bien ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text('Activez les équipements disponibles', style: TextStyle(fontSize: 13, color: DiwaneColors.textMuted)),
            const SizedBox(height: 16),
            for (int i = 0; i < equipements.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: _EquipTile(
                      label: equipements[i]['label']!,
                      equipKey: equipements[i]['key']!,
                      controller: c,
                    )),
                    const SizedBox(width: 8),
                    if (i + 1 < equipements.length)
                      Expanded(child: _EquipTile(
                        label: equipements[i + 1]['label']!,
                        equipKey: equipements[i + 1]['key']!,
                        controller: c,
                      ))
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _EquipTile extends StatelessWidget {
  final String label;
  final String equipKey;
  final PublierBienController controller;

  const _EquipTile({required this.label, required this.equipKey, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.equipements[equipKey] == true;
      return GestureDetector(
        onTap: () => controller.equipements[equipKey] = !active,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: active ? DiwaneColors.navyLight : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? DiwaneColors.navy : DiwaneColors.cardBorder,
              width: active ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                active ? Icons.check_box : Icons.check_box_outline_blank,
                size: 18,
                color: active ? DiwaneColors.navy : DiwaneColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: active ? DiwaneColors.navy : DiwaneColors.textPrimary,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
