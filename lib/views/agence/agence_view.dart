import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/agence_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/invitation_agence_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/utilisateur_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/bien_card.dart';

class AgenceView extends StatelessWidget {
  const AgenceView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AgenceController>()) {
      Get.put(AgenceController());
    }
    final c = AgenceController.to;
    final user = DiwaneAuthController.to.user.value!;

    // Vue agent (membre d'une agence, pas propriétaire)
    if (user.agenceId != null && !user.isAgenceOwner) {
      return _AgenceMembreView(user: user, controller: c);
    }

    // Vue propriétaire
    return _AgenceProprietaireView(user: user, controller: c);
  }
}

// ── Vue propriétaire ──────────────────────────────────────────────────────────

class _AgenceProprietaireView extends StatelessWidget {
  final UtilisateurDiwane user;
  final AgenceController controller;

  const _AgenceProprietaireView({required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: c.charger),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value && c.membres.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: DiwaneColors.navy));
        }

        final slots = maxAgents - 1 - c.membres.length;

        return CustomScrollView(
          slivers: [
            // ── Header avec quota + stats ─────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                color: DiwaneColors.navy,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nomAgence?.isNotEmpty == true
                          ? user.nomAgence!
                          : '${user.nomComplet} — Agence',
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
                        c.membres.length + 1 >= maxAgents
                            ? DiwaneColors.orange
                            : Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 20),

                    // Stats consolidées agence
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _StatItem(label: 'Annonces', value: '${c.totalAnnoncesAgence}'),
                          _vDivider(),
                          _StatItem(label: 'Vues', value: _formatK(c.totalVuesAgence)),
                          _vDivider(),
                          _StatItem(label: 'Contacts', value: '${c.totalContactsAgence}'),
                          _vDivider(),
                          _StatItem(
                            label: 'Agents',
                            value: '${c.membres.length + 1}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Propriétaire ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionLabel('PROPRIÉTAIRE'),
                    const SizedBox(height: 8),
                    _MembreCard(user: user, isOwner: true),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const _SectionLabel('AGENTS'),
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

            // ── Liste agents ──────────────────────────────────────────────
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

            // ── Invitations en attente ────────────────────────────────────
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
                      const _SectionLabel('INVITATIONS EN ATTENTE'),
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

            // ── Bouton inviter ────────────────────────────────────────────
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DiwaneColors.orangeLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: DiwaneColors.orange.withValues(alpha: 0.3)),
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
        title: const Text('Inviter un agent',
            style: TextStyle(fontFamily: AppFont.interSemiBold)),
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
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Envoyer l\'invitation'),
              )),
        ],
      ),
    );
  }
}

// ── Vue membre (agent dans une agence) ───────────────────────────────────────

class _AgenceMembreView extends StatelessWidget {
  final UtilisateurDiwane user;
  final AgenceController controller;

  const _AgenceMembreView({required this.user, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: c.charger),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value && c.annoncesAgence.isEmpty) {
          return const Center(
              child: CircularProgressIndicator(color: DiwaneColors.navy));
        }
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DiwaneColors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('Pro',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.nomAgence?.isNotEmpty == true
                          ? user.nomAgence!
                          : 'Agence',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: AppFont.interBold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.greenAccent, size: 14),
                        SizedBox(width: 6),
                        Text('Vous êtes membre de cette agence',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _StatItem(
                              label: 'Agence',
                              value: '${c.annoncesAgence.length} ann.'),
                          _vDivider(),
                          _StatItem(
                              label: 'Mes annonces',
                              value: '${user.nbAnnoncesActives}'),
                          _vDivider(),
                          _StatItem(
                              label: 'Mes contacts',
                              value: '${user.nbContactsRecus}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Annonces de l'agence ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: _SectionLabel(
                    'ANNONCES DE L\'AGENCE (${c.annoncesAgence.length})'),
              ),
            ),

            if (c.annoncesAgence.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.home_work_outlined,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text('Aucune annonce publiée',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => BienCard(
                    bien: c.annoncesAgence[i],
                    onTap: () => Get.toNamed(
                        '/diwane/bien/${c.annoncesAgence[i].id}'),
                  ),
                  childCount: c.annoncesAgence.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      }),
    );
  }
}

// ── Widgets partagés ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: DiwaneColors.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: AppFont.interBold,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFont.interRegular,
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _vDivider() => Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.15),
    );

String _formatK(int n) {
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
  return '$n';
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
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                isOwner ? DiwaneColors.navy : DiwaneColors.navyLight,
            child: Text(
              user.initiales,
              style: TextStyle(
                color: isOwner ? Colors.white : DiwaneColors.navy,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.nomComplet,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          fontFamily: AppFont.interSemiBold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isOwner) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: DiwaneColors.navy,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Propriétaire',
                            style:
                                TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ],
                    if (!isOwner && user.verifie) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          color: DiwaneColors.navy, size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.nbAnnoncesActives} annonces · ${_formatK(user.nbVuesTotal)} vues',
                  style: const TextStyle(
                      fontSize: 11, color: DiwaneColors.textMuted),
                ),
              ],
            ),
          ),
          if (!isOwner && onRetirer != null)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: Colors.red, size: 20),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              (inv.prenomInvite?.isNotEmpty == true
                      ? inv.prenomInvite![0]
                      : '?')
                  .toUpperCase(),
              style: const TextStyle(
                  color: DiwaneColors.navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${inv.prenomInvite ?? ''} ${inv.nomInvite ?? ''}'
                              .trim()
                              .isNotEmpty
                      ? '${inv.prenomInvite ?? ''} ${inv.nomInvite ?? ''}'.trim()
                      : inv.emailInvite,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                Text(inv.emailInvite,
                    style: const TextStyle(
                        fontSize: 11, color: DiwaneColors.textMuted)),
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
            child:
                const Text('En attente', style: TextStyle(fontSize: 10, color: Colors.orange)),
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
