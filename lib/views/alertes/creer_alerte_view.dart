import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/alerte_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:get_storage/get_storage.dart';
import 'package:luxury_real_estate_flutter_ui_kit/app.dart' show kOneSignalSubIdKey;
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Formulaire de création d'alerte — pré-rempli depuis les filtres courants
class CreerAlerteView extends StatefulWidget {
  const CreerAlerteView({super.key});

  @override
  State<CreerAlerteView> createState() => _CreerAlerteViewState();
}

class _CreerAlerteViewState extends State<CreerAlerteView> {
  final _labelCtrl = TextEditingController();
  bool _loading = false;

  // Critères modifiables
  late String? _typeTransaction;
  late List<String> _typeBien;
  late List<String> _villes;
  double? _loyerMax;
  double? _prixMax;
  int? _nbChambresMin;

  @override
  void initState() {
    super.initState();
    // Critères pré-remplis passés via Get.arguments depuis SearchDiwaneView
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final c = (args['criteres'] as Map<String, dynamic>?) ?? {};
    _typeTransaction = c['type_transaction'] as String?;
    _typeBien        = List<String>.from(c['type_bien'] ?? []);
    _villes          = List<String>.from(c['villes'] ?? []);
    _loyerMax        = (c['loyer_max_fcfa'] as num?)?.toDouble();
    _prixMax         = (c['prix_max_fcfa'] as num?)?.toDouble();
    _nbChambresMin   = (c['nb_chambres_min'] as num?)?.toInt();
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _criteres => {
    if (_typeTransaction != null) 'type_transaction': _typeTransaction,
    if (_typeBien.isNotEmpty) 'type_bien': _typeBien,
    if (_villes.isNotEmpty) 'villes': _villes,
    if (_loyerMax != null) 'loyer_max_fcfa': _loyerMax,
    if (_prixMax  != null) 'prix_max_fcfa': _prixMax,
    if (_nbChambresMin != null) 'nb_chambres_min': _nbChambresMin,
  };

  Future<void> _enregistrer() async {
    final authCtrl = DiwaneAuthController.to;
    final token = authCtrl.token.value;
    if (token.isEmpty) {
      Get.snackbar('Connexion requise', 'Connectez-vous pour créer une alerte',
          backgroundColor: DiwaneColors.error, colorText: Colors.white);
      return;
    }

    setState(() => _loading = true);

    try {
      // OneSignal n'est pas disponible sur web
      if (kIsWeb) {
        Get.snackbar(
          'Non disponible sur web',
          'Les alertes push nécessitent l\'application mobile',
          backgroundColor: DiwaneColors.orange,
          colorText: Colors.white,
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
        Get.snackbar(
          'Notifications non prêtes',
          'Veuillez patienter quelques secondes puis réessayer',
          backgroundColor: DiwaneColors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final service = Get.find<AlerteService>();
      await service.creerAlerte(
        token: token,
        subscriptionId: subscriptionId,
        label: _labelCtrl.text.isNotEmpty ? _labelCtrl.text : null,
        criteres: _criteres,
      );

      Get.back(result: true);
      Get.snackbar(
        'Alerte créée',
        'Vous serez notifié des nouveaux biens correspondants',
        backgroundColor: DiwaneColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: DiwaneColors.error, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiwaneColors.background,
      appBar: AppBar(
        backgroundColor: DiwaneColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Créer une alerte'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
                    color: DiwaneColors.navy.withOpacity(0.1),
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

          const SizedBox(height: 24),

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

          const SizedBox(height: 24),

          // Résumé des critères
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
            child: _criteres.isEmpty
                ? const Text(
                    'Aucun critère spécifié — tous les nouveaux biens correspondront.',
                    style: TextStyle(
                        fontSize: 12,
                        color: DiwaneColors.textMuted,
                        fontStyle: FontStyle.italic),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _criteres.entries.map((e) {
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

          const SizedBox(height: 32),

          // Bouton créer
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _enregistrer,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.notifications_active, size: 18),
              label: Text(_loading ? 'Enregistrement…' : 'Activer l\'alerte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DiwaneColors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ],
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
