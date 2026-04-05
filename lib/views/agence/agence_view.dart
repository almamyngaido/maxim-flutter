import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/agence_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/invitation_agence_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/utilisateur_diwane_model.dart';

class AgenceView extends StatelessWidget {
  const AgenceView({super.key});

  @override
  Widget build(BuildContext context) {
    // Lazy-init du controller si pas encore chargé
    if (!Get.isRegistered<AgenceController>()) {
      Get.put(AgenceController());
    }
    final c = AgenceController.to;
    final owner = DiwaneAuthController.to.user.value!;
    const maxAgents = 7;

    return Scaffold(
      backgroundColor: DiwaneColors.background,
      appBar: AppBar(
        backgroundColor: DiwaneColors.navy,
        foregroundColor: Colors.white,
        title: const Text(
          'Mon Agence',
          style: TextStyle(fontFamily: AppFont.interSemiBold, fontSize: 17),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: c.charger,
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value && c.membres.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: DiwaneColors.navy));
        }

        final slots = maxAgents - 1 - c.membres.length; // -1 pour le propriétaire

        return CustomScrollView(
          slivers: [
            // ── Header agence ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: DiwaneColors.navy,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      owner.nomAgence?.isNotEmpty == true
                          ? owner.nomAgence!
                          : '${owner.nomComplet} — Agence',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: AppFont.interSemiBold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${c.membres.length + 1} / $maxAgents agents actifs',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (c.membres.length + 1) / maxAgents,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        c.membres.length + 1 >= maxAgents ? Colors.orange : Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ),

            // ── Moi (propriétaire) ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Propriétaire',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DiwaneColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _MembreCard(
                      user: owner,
                      isOwner: true,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'Agents',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: DiwaneColors.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        if (slots > 0)
                          Text(
                            '$slots place(s) disponible(s)',
                            style: const TextStyle(fontSize: 12, color: DiwaneColors.textMuted),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Liste agents actifs ────────────────────────────────────────
            if (c.membres.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'Aucun agent actif dans votre agence',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final membre = c.membres[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: _MembreCard(
                        user: membre,
                        isOwner: false,
                        onRetirer: () => c.retirerMembre(membre),
                      ),
                    );
                  },
                  childCount: c.membres.length,
                ),
              ),

            // ── Invitations en attente ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Obx(() {
                final invs = c.invitationsEnvoyees
                    .where((i) => i.estEnAttente && !i.estExpiree)
                    .toList();
                if (invs.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'INVITATIONS EN ATTENTE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DiwaneColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...invs.map((inv) => _InvitationEnvoyeeCard(
                            inv: inv,
                            onAnnuler: () => c.annulerInvitation(inv),
                          )),
                    ],
                  ),
                );
              }),
            ),

            // ── Bouton Ajouter ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: slots > 0
                    ? ElevatedButton.icon(
                        onPressed: () => _showInviterModal(context, c),
                        icon: const Icon(Icons.person_add_outlined),
                        label: const Text('Ajouter un agent'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DiwaneColors.navy,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DiwaneColors.orangeLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: DiwaneColors.orange.withValues(alpha: 0.3)),
                        ),
                        child: const Text(
                          'Limite atteinte : 7 agents maximum par agence Pro.',
                          style: TextStyle(color: DiwaneColors.orange, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      }),
    );
  }

  void _showInviterModal(BuildContext context, AgenceController c) {
    final prenomCtrl = TextEditingController();
    final nomCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Get.dialog(
      AlertDialog(
        title: const Text('Inviter un agent', style: TextStyle(fontFamily: AppFont.interSemiBold)),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Un email d\'invitation sera envoyé. L\'agent pourra rejoindre depuis l\'application ou le lien email.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 14),
                _Field(controller: prenomCtrl, label: 'Prénom', hint: 'Ibrahima'),
                const SizedBox(height: 12),
                _Field(controller: nomCtrl, label: 'Nom', hint: 'Diallo'),
                const SizedBox(height: 12),
                _Field(
                  controller: emailCtrl,
                  label: 'Email',
                  hint: 'agent@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requis';
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Annuler')),
          Obx(() => ElevatedButton(
                onPressed: c.isLoading.value
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        Get.back();
                        await c.inviterParEmail(
                          prenom: prenomCtrl.text.trim(),
                          nom: nomCtrl.text.trim(),
                          email: emailCtrl.text.trim().toLowerCase(),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DiwaneColors.navy,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                child: c.isLoading.value
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Envoyer l\'invitation'),
              )),
        ],
      ),
    );
  }
}

// ── Carte membre ──────────────────────────────────────────────────────────────

class _MembreCard extends StatelessWidget {
  final UtilisateurDiwane user;
  final bool isOwner;
  final VoidCallback? onRetirer;

  const _MembreCard({required this.user, required this.isOwner, this.onRetirer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiwaneColors.cardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: isOwner ? DiwaneColors.navy : DiwaneColors.navyLight,
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(
                    user.initiales,
                    style: TextStyle(
                      color: isOwner ? Colors.white : DiwaneColors.navy,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          // Infos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.nomComplet,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        fontFamily: AppFont.interSemiBold,
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DiwaneColors.navy,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Propriétaire', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(user.telephone, style: const TextStyle(fontSize: 12, color: DiwaneColors.textMuted)),
              ],
            ),
          ),
          // Action retirer
          if (!isOwner && onRetirer != null)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
              tooltip: 'Retirer',
              onPressed: onRetirer,
            ),
        ],
      ),
    );
  }
}

// ── Champ texte ───────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Requis' : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

// ── Carte invitation envoyée ──────────────────────────────────────────────────

class _InvitationEnvoyeeCard extends StatelessWidget {
  final InvitationAgence inv;
  final VoidCallback onAnnuler;

  const _InvitationEnvoyeeCard({required this.inv, required this.onAnnuler});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DiwaneColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: DiwaneColors.navyLight,
            child: Text(
              (inv.prenomInvite?.isNotEmpty == true ? inv.prenomInvite![0] : '?').toUpperCase(),
              style: const TextStyle(color: DiwaneColors.navy, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${inv.prenomInvite ?? ''} ${inv.nomInvite ?? ''}'.trim().isNotEmpty
                      ? '${inv.prenomInvite ?? ''} ${inv.nomInvite ?? ''}'.trim()
                      : inv.emailInvite,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(inv.emailInvite, style: const TextStyle(fontSize: 11, color: DiwaneColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: const Text('En attente', style: TextStyle(fontSize: 10, color: Colors.orange)),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onAnnuler,
            child: const Icon(Icons.close, size: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// Extension pour avatarUrl (pas dans le modèle actuel — on ignore silencieusement)
extension _UserAvatar on UtilisateurDiwane {
  String? get avatarUrl => null; // sera ajouté quand le modèle inclura avatar_url
}
