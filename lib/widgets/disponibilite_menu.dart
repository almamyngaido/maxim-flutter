import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/bien_diwane_service.dart';

/// Ouvre un bottom sheet pour mettre à jour la disponibilité d'un bien.
/// [onMisAJour] est appelé après succès pour rafraîchir la liste.
void afficherMenuDisponibilite(
  BuildContext context,
  BienDiwane bien,
  VoidCallback onMisAJour,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _MenuDisponibilite(bien: bien, onMisAJour: onMisAJour),
  );
}

class _MenuDisponibilite extends StatefulWidget {
  final BienDiwane bien;
  final VoidCallback onMisAJour;
  const _MenuDisponibilite({required this.bien, required this.onMisAJour});

  @override
  State<_MenuDisponibilite> createState() => _MenuDisponibiliteState();
}

class _MenuDisponibiliteState extends State<_MenuDisponibilite> {
  bool _loading = false;

  Future<void> _changer(String valeur) async {
    if (_loading) return;
    setState(() => _loading = true);
    Navigator.pop(context);
    try {
      final token = DiwaneAuthController.to.token.value;
      await Get.find<BienDiwaneService>()
          .mettreAJourDisponibilite(widget.bien.id!, valeur, token);
      widget.onMisAJour();
      Get.snackbar(
        'Statut mis à jour',
        _label(valeur),
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _label(String v) => switch (v) {
        'disponible' => 'Bien marqué disponible',
        'visite_en_cours' => 'Visite en cours enregistrée',
        'loue' => 'Bien marqué loué — annonce archivée',
        'vendu' => 'Bien marqué vendu — annonce archivée',
        _ => 'Statut mis à jour',
      };

  @override
  Widget build(BuildContext context) {
    final isLocation = widget.bien.typeTransaction == 'location';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Statut de disponibilité',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: AppFont.interSemiBold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.bien.titre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 12, color: DiwaneColors.textMuted),
          ),
          const SizedBox(height: 16),
          _Option(
            label: 'Disponible',
            sublabel: 'Le bien est visible et accessible',
            color: const Color(0xFF2E7D32),
            isSelected: widget.bien.disponibilite == 'disponible',
            onTap: () => _changer('disponible'),
          ),
          _Option(
            label: 'Visite en cours',
            sublabel: 'Une visite est planifiée',
            color: const Color(0xFFE65100),
            isSelected: widget.bien.disponibilite == 'visite_en_cours',
            onTap: () => _changer('visite_en_cours'),
          ),
          _Option(
            label: isLocation ? 'Loué' : 'Vendu',
            sublabel: 'Transaction finalisée — annonce archivée',
            color: const Color(0xFFC62828),
            isSelected: widget.bien.disponibilite == 'loue' ||
                widget.bien.disponibilite == 'vendu',
            onTap: () => _changer(isLocation ? 'loue' : 'vendu'),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _Option({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? color : DiwaneColors.textPrimary,
                      )),
                  Text(sublabel,
                      style: const TextStyle(
                          fontSize: 11, color: DiwaneColors.textMuted)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}
