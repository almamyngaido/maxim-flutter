import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/utilisateur_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/agence_service.dart';

class AgenceController extends GetxController {
  static AgenceController get to => Get.find();

  final _service = AgenceService();

  final membres = <UtilisateurDiwane>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    charger();
  }

  String get _token => DiwaneAuthController.to.token.value;

  Future<void> charger() async {
    try {
      isLoading(true);
      membres.value = await _service.listerMembres(_token);
    } catch (e) {
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> inviter({
    required String prenom,
    required String nom,
    required String telephone,
    required String email,
  }) async {
    try {
      isLoading(true);
      final result = await _service.inviterAgent(
        token: _token,
        prenom: prenom,
        nom: nom,
        telephone: telephone,
        email: email,
      );
      await charger();

      // Afficher le mot de passe temporaire si nouveau compte
      if (result.nouveauCompte && result.motDePasseTemporaire != null) {
        Get.dialog(
          AlertDialog(
            title: const Text('Agent ajouté'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${result.agent.nomComplet} a été ajouté à votre agence.'),
                const SizedBox(height: 16),
                const Text('Mot de passe temporaire :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result.motDePasseTemporaire!,
                    style: const TextStyle(fontSize: 18, fontFamily: 'monospace', letterSpacing: 2),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Partagez ce mot de passe avec l\'agent. Il pourra le changer dans son profil.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: Get.back, child: const Text('OK')),
            ],
          ),
        );
      } else {
        Get.snackbar('Succès', '${result.agent.nomComplet} a été lié à votre agence.',
            backgroundColor: Colors.green.shade700, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> retirer(UtilisateurDiwane membre) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Retirer l\'agent ?'),
        content: Text(
          'Voulez-vous retirer ${membre.nomComplet} de votre agence ?\nSon compte passera en plan Gratuit.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Retirer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      isLoading(true);
      await _service.retirerMembre(_token, membre.id);
      membres.removeWhere((m) => m.id == membre.id);
      Get.snackbar('Succès', '${membre.nomComplet} a été retiré de l\'agence.',
          backgroundColor: Colors.green.shade700, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }
}
