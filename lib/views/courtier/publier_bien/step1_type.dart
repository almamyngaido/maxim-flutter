import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/publier_bien_controller.dart';

class Step1Type extends StatelessWidget {
  const Step1Type({super.key});

  static const _types = [
    {'value': 'appartement', 'label': 'Appartement', 'icon': Icons.apartment},
    {'value': 'villa',       'label': 'Villa',        'icon': Icons.house},
    {'value': 'studio',      'label': 'Studio',       'icon': Icons.single_bed},
    {'value': 'duplex',      'label': 'Duplex',       'icon': Icons.domain},
    {'value': 'bureau',      'label': 'Bureau',       'icon': Icons.business_center},
    {'value': 'commerce',    'label': 'Commerce',     'icon': Icons.storefront},
    {'value': 'terrain',     'label': 'Terrain',      'icon': Icons.landscape},
    {'value': 'entrepot',    'label': 'Entrepôt',     'icon': Icons.warehouse},
    {'value': 'chambre',     'label': 'Chambre',      'icon': Icons.bedroom_parent},
  ];

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PublierBienController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type de bien — grille 3×3
          const Text('Quel type de bien ?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary)),
          const SizedBox(height: 12),
          Obx(() => GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: _types.map((t) {
              final selected = c.typeBien.value == t['value'];
              return _TypeCard(
                label: t['label'] as String,
                icon: t['icon'] as IconData,
                selected: selected,
                onTap: () => c.typeBien.value = t['value'] as String,
              );
            }).toList(),
          )),

          const SizedBox(height: 24),

          // Type de transaction — 2 grandes cards
          const Text('Type de transaction',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary)),
          const SizedBox(height: 12),
          Obx(() => Row(
            children: [
              Expanded(child: _TransactionCard(
                label: 'Location',
                icon: Icons.key,
                description: 'Louer votre bien',
                selected: c.typeTransaction.value == 'location',
                selectedColor: DiwaneColors.navy,
                onTap: () => c.typeTransaction.value = 'location',
              )),
              const SizedBox(width: 12),
              Expanded(child: _TransactionCard(
                label: 'Vente',
                icon: Icons.sell,
                description: 'Vendre votre bien',
                selected: c.typeTransaction.value == 'vente',
                selectedColor: DiwaneColors.orange,
                onTap: () => c.typeTransaction.value = 'vente',
              )),
            ],
          )),
        ],
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeCard({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? DiwaneColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? DiwaneColors.navy : DiwaneColors.cardBorder,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? [const BoxShadow(blurRadius: 4, color: Colors.black12)] : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: selected ? Colors.white : DiwaneColors.navy),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : DiwaneColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final String description;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TransactionCard({
    required this.label, required this.icon, required this.description,
    required this.selected, required this.selectedColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 100,
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? selectedColor : DiwaneColors.cardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: selected ? Colors.white : selectedColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold,
                color: selected ? Colors.white : DiwaneColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white70 : DiwaneColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
