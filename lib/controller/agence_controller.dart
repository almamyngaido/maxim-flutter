import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/invitation_agence_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/utilisateur_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/agence_service.dart';

class AgenceController extends GetxController {
  static AgenceController get to => Get.find();

  final _service = AgenceService();

  // Propriétaire agence
  final membres = <UtilisateurDiwane>[].obs;
  final invitationsEnvoyees = <InvitationAgence>[].obs;

  // Agent : invitations reçues
  final invitationsRecues = <InvitationAgence>[].obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    charger();
  }

  String get _token => DiwaneAuthController.to.token.value;
  UtilisateurDiwane? get _user => DiwaneAuthController.to.user.value;

  Future<void> charger() async {
    try {
      isLoading(true);
      final user = _user;
      if (user == null) return;

      if (user.isAgenceOwner) {
        // Propriétaire : charge membres + invitations envoyées
        final results = await Future.wait([
          _service.listerMembres(_token),
          _service.invitationsEnvoyees(_token),
        ]);
        membres.value = results[0] as List<UtilisateurDiwane>;
        invitationsEnvoyees.value = results[1] as List<InvitationAgence>;
      } else if (user.isCourtier) {
        // Agent potentiel : charge invitations reçues
        invitationsRecues.value = await _service.invitationsRecues(_token);
      }
    } catch (e) {
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  // ── Propriétaire : inviter par email ─────────────────────────────────────

  Future<void> inviterParEmail({
    required String prenom,
    required String nom,
    required String email,
  }) async {
    try {
      isLoading(true);
      final message = await _service.inviterParEmail(
        token: _token,
        prenom: prenom,
        nom: nom,
        email: email,
      );
      await charger();
      Get.snackbar('Invitation envoyée', message,
          backgroundColor: Colors.green.shade700, colorText: Colors.white,
          duration: const Duration(seconds: 4));
    } catch (e) {
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> annulerInvitation(InvitationAgence inv) async {
    final confirm = await Get.dialog<bool>(AlertDialog(
      title: const Text('Annuler l\'invitation ?'),
      content: Text('Annuler l\'invitation envoyée à ${inv.emailInvite} ?'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Non')),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Annuler l\'invitation', style: TextStyle(color: Colors.red)),
        ),
      ],
    ));
    if (confirm != true) return;
    try {
      await _service.annulerInvitation(_token, inv.id);
      invitationsEnvoyees.removeWhere((i) => i.id == inv.id);
    } catch (e) {
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: Colors.red.shade700, colorText: Colors.white);
    }
  }

  Future<void> retirerMembre(UtilisateurDiwane membre) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Retirer l\'agent ?'),
        content: Text(
          'Retirer ${membre.nomComplet} de votre agence ?\nSon compte passera en plan Gratuit.',
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

  // ── Agent : accepter / refuser invitation ────────────────────────────────

  Future<void> accepterInvitation(InvitationAgence inv) async {
    final confirm = await Get.dialog<bool>(AlertDialog(
      title: const Text('Rejoindre l\'agence ?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rejoindre l\'agence ${inv.agenceNom} de ${inv.proprietaireNom} ?'),
          const SizedBox(height: 8),
          const Text(
            'Votre compte passera au plan Pro et sera lié à cette agence.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B2A4A)),
          child: const Text('Rejoindre', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
    if (confirm != true) return;

    try {
      isLoading(true);
      final message = await _service.accepterInvitation(_token, inv.token);
      // Recharger le profil pour mettre à jour le plan
      await DiwaneAuthController.to.rechargerProfil();
      invitationsRecues.removeWhere((i) => i.id == inv.id);
      Get.snackbar('Bienvenue !', message,
          backgroundColor: Colors.green.shade700, colorText: Colors.white,
          duration: const Duration(seconds: 5));
    } catch (e) {
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: Colors.red.shade700, colorText: Colors.white);
    } finally {
      isLoading(false);
    }
  }

  Future<void> refuserInvitation(InvitationAgence inv) async {
    final confirm = await Get.dialog<bool>(AlertDialog(
      title: const Text('Refuser l\'invitation ?'),
      content: Text('Refuser l\'invitation de ${inv.agenceNom} ?'),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
        TextButton(
          onPressed: () => Get.back(result: true),
          child: const Text('Refuser', style: TextStyle(color: Colors.red)),
        ),
      ],
    ));
    if (confirm != true) return;

    try {
      await _service.refuserInvitation(_token, inv.token);
      invitationsRecues.removeWhere((i) => i.id == inv.id);
      Get.snackbar('Invitation refusée', 'L\'invitation a été refusée.',
          backgroundColor: Colors.grey.shade700, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Erreur', e.toString(),
          backgroundColor: Colors.red.shade700, colorText: Colors.white);
    }
  }
}
