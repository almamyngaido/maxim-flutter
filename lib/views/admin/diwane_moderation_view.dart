import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/bien_diwane_service.dart';

class DiwaneModerationView extends StatefulWidget {
  const DiwaneModerationView({super.key});

  @override
  State<DiwaneModerationView> createState() => _DiwaneModerationViewState();
}

class _DiwaneModerationViewState extends State<DiwaneModerationView> {
  final _auth = Get.find<DiwaneAuthController>();
  final _service = Get.find<BienDiwaneService>();

  final RxList<BienDiwane> _biens = <BienDiwane>[].obs;
  final RxBool _loading = false.obs;
  final RxString _error = ''.obs;
  final RxString _filtre = 'en_attente'.obs;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    _loading.value = true;
    _error.value = '';
    try {
      final result = await _service.biensAdmin(
        _auth.token.value,
        statut: _filtre.value,
      );
      _biens.assignAll(result);
    } catch (e) {
      _error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      _loading.value = false;
    }
  }

  Future<void> _changerStatut(BienDiwane bien, String statut) async {
    if (bien.id == null) return;
    try {
      await _service.changerStatut(bien.id!, statut, _auth.token.value);
      _biens.removeWhere((b) => b.id == bien.id);
      Get.snackbar(
        statut == 'publie' ? 'Approuvé' : 'Rejeté',
        '« ${bien.titre} » est maintenant ${statut == 'publie' ? 'publié' : 'rejeté'}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: statut == 'publie' ? Colors.green : Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiwaneColors.background,
      appBar: AppBar(
        backgroundColor: DiwaneColors.navy,
        foregroundColor: Colors.white,
        title: const Text(
          'Modération biens',
          style: TextStyle(
            fontFamily: AppFont.interBold,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _charger,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: _auth.logout,
            icon: const Icon(Icons.logout_rounded, size: 20),
            tooltip: 'Déconnexion',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(() => _FiltreBar(
                selected: _filtre.value,
                onSelect: (v) {
                  _filtre.value = v;
                  _charger();
                },
              )),
        ),
      ),
      body: Obx(() {
        if (_loading.value) {
          return const Center(
            child: CircularProgressIndicator(color: DiwaneColors.navy),
          );
        }
        if (_error.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: DiwaneColors.textMuted, size: 48),
                  const SizedBox(height: 12),
                  Text(_error.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: DiwaneColors.textMuted, fontSize: 14)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: _charger, child: const Text('Réessayer')),
                ],
              ),
            ),
          );
        }
        if (_biens.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: DiwaneColors.navy, size: 56),
                const SizedBox(height: 12),
                Text(
                  _filtre.value == 'en_attente'
                      ? 'Aucun bien en attente'
                      : 'Aucun bien trouvé',
                  style: const TextStyle(
                    fontFamily: AppFont.interSemiBold,
                    fontSize: 16,
                    color: DiwaneColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _biens.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _BienModerationCard(
            bien: _biens[i],
            onApprove: _filtre.value == 'en_attente'
                ? () => _changerStatut(_biens[i], 'publie')
                : null,
            onReject: _filtre.value == 'en_attente'
                ? () => _changerStatut(_biens[i], 'rejete')
                : null,
          ),
        );
      }),
    );
  }
}

class _FiltreBar extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const _FiltreBar({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const filtres = [
      ('en_attente', 'En attente'),
      ('publie', 'Publiés'),
      ('rejete', 'Rejetés'),
      ('tous', 'Tous'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filtres.map((f) {
          final isActive = selected == f.$1;
          return GestureDetector(
            onTap: () => onSelect(f.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? DiwaneColors.orange : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                f.$2,
                style: TextStyle(
                  fontFamily: AppFont.interMedium,
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BienModerationCard extends StatelessWidget {
  final BienDiwane bien;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _BienModerationCard({
    required this.bien,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiwaneColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre + badge statut
          Row(
            children: [
              Expanded(
                child: Text(
                  bien.titre,
                  style: const TextStyle(
                    fontFamily: AppFont.interSemiBold,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: DiwaneColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatutBadge(statut: bien.statut),
            ],
          ),
          const SizedBox(height: 6),
          // Courtier
          Text(
            '${bien.courtierPrenom ?? ''} ${bien.courtierNom ?? ''}'.trim(),
            style: const TextStyle(
              fontFamily: AppFont.interRegular,
              fontSize: 13,
              color: DiwaneColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          // Lieu + type
          Text(
            '${bien.ville} · ${bien.quartier} · ${bien.typeBien} · ${bien.typeTransaction}',
            style: const TextStyle(
              fontFamily: AppFont.interRegular,
              fontSize: 12,
              color: DiwaneColors.textMuted,
            ),
          ),
          // Prix
          if (bien.prix != null || bien.loyer != null) ...[
            const SizedBox(height: 4),
            Text(
              bien.loyer != null
                  ? '${bien.loyer!.toInt()} FCFA / mois'
                  : '${bien.prix!.toInt()} FCFA',
              style: const TextStyle(
                fontFamily: AppFont.interSemiBold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DiwaneColors.navy,
              ),
            ),
          ],
          // Actions
          if (onApprove != null || onReject != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onApprove != null)
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Approuver'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                          fontFamily: AppFont.interSemiBold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                if (onApprove != null && onReject != null)
                  const SizedBox(width: 8),
                if (onReject != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Rejeter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                          fontFamily: AppFont.interSemiBold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatutBadge extends StatelessWidget {
  final String statut;
  const _StatutBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (statut) {
      'publie'     => ('Publié', Colors.green),
      'en_attente' => ('En attente', Colors.orange),
      'rejete'     => ('Rejeté', Colors.red),
      'brouillon'  => ('Brouillon', Colors.grey),
      'archive'    => ('Archivé', Colors.blueGrey),
      _            => (statut, Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppFont.interSemiBold,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
