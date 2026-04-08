import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/alerte_recherche_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/alerte_service.dart';

class MesAlertesView extends StatefulWidget {
  const MesAlertesView({super.key});

  @override
  State<MesAlertesView> createState() => _MesAlertesViewState();
}

class _MesAlertesViewState extends State<MesAlertesView> {
  List<AlerteRecherche> _alertes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    final token = DiwaneAuthController.to.token.value;
    try {
      final service = Get.find<AlerteService>();
      final alertes = await service.mesAlertes(token);
      if (mounted) setState(() { _alertes = alertes; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _toggleActif(AlerteRecherche alerte) async {
    final token = DiwaneAuthController.to.token.value;
    try {
      final service = Get.find<AlerteService>();
      await service.mettreAJour(
        token: token,
        alerteId: alerte.id,
        active: !alerte.active,
      );
      await _charger();
    } catch (e) {
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: DiwaneColors.error, colorText: Colors.white);
    }
  }

  Future<void> _supprimer(AlerteRecherche alerte) async {
    final confirm = await Get.dialog<bool>(AlertDialog(
      title: const Text('Supprimer l\'alerte ?'),
      content: Text(
          'Vous ne recevrez plus de notifications pour "${alerte.label ?? alerte.criteres.labelAuto}"'),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler')),
        TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Supprimer',
                style: TextStyle(color: DiwaneColors.error))),
      ],
    ));
    if (confirm != true) return;

    final token = DiwaneAuthController.to.token.value;
    try {
      final service = Get.find<AlerteService>();
      await service.supprimer(token: token, alerteId: alerte.id);
      await _charger();
    } catch (e) {
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: DiwaneColors.error, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiwaneColors.background,
      appBar: AppBar(
        backgroundColor: DiwaneColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Mes alertes'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: DiwaneColors.navy))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style:
                          const TextStyle(color: DiwaneColors.textMuted)))
              : _alertes.isEmpty
                  ? _vide()
                  : RefreshIndicator(
                      onRefresh: _charger,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _alertes.length,
                        itemBuilder: (_, i) =>
                            _CarteAlerte(
                          alerte: _alertes[i],
                          onToggle: () => _toggleActif(_alertes[i]),
                          onSupprimer: () => _supprimer(_alertes[i]),
                        ),
                      ),
                    ),
    );
  }

  Widget _vide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.notifications_none,
                size: 64, color: DiwaneColors.textMuted),
            const SizedBox(height: 16),
            const Text(
              'Aucune alerte active',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DiwaneColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Créez une alerte depuis la recherche pour être\nnotifié des nouveaux biens.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 13, color: DiwaneColors.textMuted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarteAlerte extends StatelessWidget {
  final AlerteRecherche alerte;
  final VoidCallback onToggle;
  final VoidCallback onSupprimer;

  const _CarteAlerte({
    required this.alerte,
    required this.onToggle,
    required this.onSupprimer,
  });

  @override
  Widget build(BuildContext context) {
    final label = alerte.label?.isNotEmpty == true
        ? alerte.label!
        : alerte.criteres.labelAuto;
    final displayLabel = label.isNotEmpty ? label : 'Alerte sans critères';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiwaneColors.cardBorder),
      ),
      child: Row(
        children: [
          // Icône état
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: alerte.active
                  ? DiwaneColors.navy.withOpacity(0.1)
                  : Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              alerte.active
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              size: 20,
              color:
                  alerte.active ? DiwaneColors.navy : Colors.grey[400],
            ),
          ),
          const SizedBox(width: 12),

          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayLabel,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: alerte.active
                        ? DiwaneColors.textPrimary
                        : DiwaneColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${alerte.nbNotificationsEnvoyees} notification${alerte.nbNotificationsEnvoyees != 1 ? 's' : ''} envoyée${alerte.nbNotificationsEnvoyees != 1 ? 's' : ''}',
                  style: const TextStyle(
                      fontSize: 11, color: DiwaneColors.textMuted),
                ),
              ],
            ),
          ),

          // Switch activer/désactiver
          Switch(
            value: alerte.active,
            onChanged: (_) => onToggle(),
            activeColor: DiwaneColors.navy,
          ),

          // Supprimer
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: DiwaneColors.textMuted,
            onPressed: onSupprimer,
          ),
        ],
      ),
    );
  }
}
