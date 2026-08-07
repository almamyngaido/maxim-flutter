import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/alerte_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:get_storage/get_storage.dart';
import 'package:luxury_real_estate_flutter_ui_kit/app.dart' show kOneSignalSubIdKey;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/diwane_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/diwane_snackbar.dart';

/// Panneau de création d'alerte — remonte depuis le bas de l'écran recherche,
/// pré-rempli avec les filtres courants. Reste sur place, pas de changement de page.
Future<void> showCreerAlerteBottomSheet(
  BuildContext context, {
  required Map<String, dynamic> criteres,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CreerAlerteSheet(criteres: criteres),
  );
}

class _CreerAlerteSheet extends StatefulWidget {
  final Map<String, dynamic> criteres;

  const _CreerAlerteSheet({required this.criteres});

  @override
  State<_CreerAlerteSheet> createState() => _CreerAlerteSheetState();
}

class _CreerAlerteSheetState extends State<_CreerAlerteSheet> {
  final _labelCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    final authCtrl = DiwaneAuthController.to;
    final token = authCtrl.token.value;
    if (token.isEmpty) {
      DiwaneSnackbar.error('Connexion requise', 'Connectez-vous pour créer une alerte');
      return;
    }

    setState(() => _loading = true);

    try {
      // OneSignal n'est pas disponible sur web
      if (kIsWeb) {
        DiwaneSnackbar.warning(
          'Non disponible sur web',
          'Les alertes push nécessitent l\'application mobile',
        );
        return;
      }

      // Récupérer le subscription ID — live d'abord, sinon depuis le storage persisté
      String subscriptionId = OneSignal.User.pushSubscription.id ?? '';
      if (subscriptionId.isEmpty) {
        subscriptionId = GetStorage().read<String>(kOneSignalSubIdKey) ?? '';
      }

      debugPrint('[Alerte] OneSignal permission: ${OneSignal.Notifications.permission}');
      debugPrint('[Alerte] OneSignal subscription ID live: "${OneSignal.User.pushSubscription.id}"');
      debugPrint('[Alerte] OneSignal subscription ID storage: "${GetStorage().read<String>(kOneSignalSubIdKey)}"');
      debugPrint('[Alerte] Subscription ID utilisé: "$subscriptionId"');

      if (subscriptionId.isEmpty) {
        DiwaneSnackbar.warning(
          'Notifications non prêtes',
          'Veuillez patienter quelques secondes puis réessayer',
        );
        return;
      }

      final service = Get.find<AlerteService>();
      await service.creerAlerte(
        token: token,
        subscriptionId: subscriptionId,
        label: _labelCtrl.text.isNotEmpty ? _labelCtrl.text : null,
        criteres: widget.criteres,
      );

      if (!mounted) return;
      Get.back(result: true);
      DiwaneSnackbar.success(
        'Alerte créée',
        'Vous serez notifié des nouveaux biens correspondants',
      );
    } catch (e) {
      await DiwaneSnackbar.apiError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Remonte le panneau au-dessus du clavier quand le champ nom est focus
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: DiwaneColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poignée visuelle du panneau
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: DiwaneColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Illustration / intro
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DiwaneColors.navyLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DiwaneColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: DiwaneColors.navy.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_active,
                            color: DiwaneColors.navy, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Recevez une notification dès qu\'un bien correspond à vos critères.',
                          style: TextStyle(
                              fontSize: 13,
                              color: DiwaneColors.textPrimary,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Résumé des critères (repris tels quels de l'écran recherche)
                const Text('Critères',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DiwaneColors.textPrimary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: DiwaneColors.cardBorder),
                  ),
                  child: widget.criteres.isEmpty
                      ? const Text(
                          'Aucun critère spécifié — tous les nouveaux biens correspondront.',
                          style: TextStyle(
                              fontSize: 12,
                              color: DiwaneColors.textMuted,
                              fontStyle: FontStyle.italic),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.criteres.entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      size: 14, color: DiwaneColors.navy),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _labelCritere(e.key, e.value),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: DiwaneColors.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),

                const SizedBox(height: 20),

                // Nom de l'alerte (optionnel)
                const Text('Nom de l\'alerte (optionnel)',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: DiwaneColors.textPrimary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _labelCtrl,
                  maxLength: 60,
                  decoration: InputDecoration(
                    hintText: 'Ex : Location Dakar ≤ 150 000 FCFA',
                    hintStyle: const TextStyle(color: DiwaneColors.textMuted),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: DiwaneColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: DiwaneColors.cardBorder),
                    ),
                    counterText: '',
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),

                const SizedBox(height: 20),

                // Bouton activer
                DiwaneButton(
                  label: _loading ? 'Enregistrement…' : 'Activer l\'alerte',
                  onPressed: _loading ? null : _enregistrer,
                  isLoading: _loading,
                  variant: DiwaneButtonVariant.secondary,
                  leading: _loading
                      ? null
                      : const Icon(Icons.notifications_active, size: 18, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _labelCritere(String key, dynamic value) {
    switch (key) {
      case 'type_transaction':
        return 'Transaction : $value';
      case 'type_bien':
        return 'Type : ${(value as List).join(', ')}';
      case 'villes':
        return 'Villes : ${(value as List).join(', ')}';
      case 'quartier':
        return 'Quartier : $value';
      case 'loyer_max_fcfa':
        return 'Loyer max : ${value.toStringAsFixed(0)} FCFA';
      case 'prix_max_fcfa':
        return 'Prix max : ${value.toStringAsFixed(0)} FCFA';
      case 'nb_chambres_min':
        return 'Chambres min : $value';
      default:
        return '$key : $value';
    }
  }
}
