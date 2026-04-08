import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/utilisateur_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/agence_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/invitation_agence_model.dart';

class ProfilDiwaneView extends StatelessWidget {
  const ProfilDiwaneView({super.key});

  @override
  Widget build(BuildContext context) {
    // Init AgenceController si pas encore chargé
    if (!Get.isRegistered<AgenceController>()) {
      Get.put(AgenceController());
    }

    return Scaffold(
      backgroundColor: DiwaneColors.background,
      body: Obx(() {
        final user = DiwaneAuthController.to.user.value;
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: DiwaneColors.navy),
          );
        }

        final agenceCtrl = AgenceController.to;

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _ProfilHeader(user: user)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Abonnement (courtier uniquement)
                    if (user.isCourtier) ...[
                      _AbonnementCard(user: user),
                      const SizedBox(height: 12),
                    ],

                    // ── Invitations reçues (courtier sans agence) ────────
                    if (user.isCourtier && user.agenceId == null) ...[
                      Obx(() {
                        final invs = agenceCtrl.invitationsRecues
                            .where((i) => i.estEnAttente && !i.estExpiree)
                            .toList();
                        if (invs.isEmpty) return const SizedBox.shrink();
                        return Column(
                          children: [
                            ...invs.map((inv) => _InvitationRecueCard(
                                  inv: inv,
                                  onAccepter: () => agenceCtrl.accepterInvitation(inv),
                                  onRefuser: () => agenceCtrl.refuserInvitation(inv),
                                )),
                            const SizedBox(height: 12),
                          ],
                        );
                      }),
                    ],

                    // Mon compte
                    _SectionCard(
                      titre: 'Mon compte',
                      items: [
                        _MenuItem(
                          icon: Icons.phone_outlined,
                          label: user.telephone,
                        ),
                        _MenuItem(
                          icon: Icons.email_outlined,
                          label: user.email,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Mes annonces (courtier)
                    if (user.isCourtier) ...[
                      _SectionCard(
                        titre: 'Mes annonces',
                        items: [
                          _MenuItem(
                            icon: Icons.home_work_outlined,
                            label: 'Gérer mes annonces',
                            badge: '${user.nbAnnoncesActives}',
                            onTap: () => Get.toNamed(AppRoutes.courtierDashboardView),
                          ),
                          _MenuItem(
                            icon: Icons.add_circle_outline,
                            label: 'Publier un bien',
                            onTap: () => Get.toNamed(AppRoutes.publierBienView),
                          ),
                          _MenuItem(
                            icon: Icons.verified_user_outlined,
                            label: 'Vérification identité',
                            badge: user.verifie ? null : '!',
                            onTap: () => Get.toNamed(AppRoutes.verificationDiwaneView),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Mon Agence (Pro uniquement — propriétaire)
                    if (user.isCourtier && user.isAgenceOwner) ...[
                      _SectionCard(
                        titre: 'Mon Agence',
                        items: [
                          _MenuItem(
                            icon: Icons.people_outline,
                            label: 'Gérer mes agents',
                            badge: null,
                            onTap: () => Get.toNamed(AppRoutes.agenceProView),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Mes favoris (acheteur)
                    if (!user.isCourtier) ...[
                      _SectionCard(
                        titre: 'Mes activités',
                        items: [
                          _MenuItem(
                            icon: Icons.favorite_outline,
                            label: 'Mes favoris',
                            onTap: () => Get.toNamed(AppRoutes.favorisDiwaneView),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Bouton déconnexion
                    _BoutonDeconnexion(),

                    const SizedBox(height: 12),
                    const Text(
                      'Diwane v1.0.0',
                      style: TextStyle(fontSize: 11, color: DiwaneColors.textMuted),
                    ),
                    const SizedBox(height: 80), // espace pour la bottom nav
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

// ── Header navy ──────────────────────────────────────────────────────────────

class _ProfilHeader extends StatelessWidget {
  final UtilisateurDiwane user;
  const _ProfilHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DiwaneColors.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: DiwaneColors.orange,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Text(
                user.initiales,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFont.interBold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nomComplet,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFont.interBold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _Badge(
                      label: user.isCourtier ? 'Courtier' : 'Acheteur',
                    ),
                    if (user.isCourtier && user.isPremium) ...[
                      const SizedBox(width: 6),
                      _Badge(
                        label: user.plan == 'premium' ? 'Premium' : 'Pro',
                        isOrange: true,
                      ),
                    ],
                  ],
                ),
                if (user.isCourtier) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${user.nbAnnoncesActives} annonces · ${user.nbVuesTotal} vues',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontFamily: AppFont.interRegular,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final bool isOrange;
  const _Badge({required this.label, this.isOrange = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOrange
            ? DiwaneColors.orange.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          fontFamily: AppFont.interSemiBold,
        ),
      ),
    );
  }
}

// ── Card abonnement courtier ─────────────────────────────────────────────────

class _AbonnementCard extends StatelessWidget {
  final UtilisateurDiwane user;
  const _AbonnementCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final isGratuit = user.plan == 'gratuit';
    final annoncesRestantes = 5 - user.nbAnnoncesActives;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGratuit ? DiwaneColors.navyLight : DiwaneColors.orangeLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGratuit
              ? DiwaneColors.cardBorder
              : DiwaneColors.orange.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isGratuit ? Colors.white : DiwaneColors.orange,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DiwaneColors.cardBorder),
            ),
            child: Center(
              child: Icon(
                isGratuit ? Icons.workspace_premium_outlined : Icons.workspace_premium,
                color: isGratuit ? DiwaneColors.navy : Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan ${user.plan[0].toUpperCase()}${user.plan.substring(1)}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: AppFont.interSemiBold,
                    color: isGratuit ? DiwaneColors.navy : DiwaneColors.orange,
                  ),
                ),
                if (isGratuit) ...[
                  const SizedBox(height: 2),
                  Text(
                    annoncesRestantes > 0
                        ? '$annoncesRestantes annonce(s) restante(s)'
                        : 'Limite atteinte',
                    style: const TextStyle(
                      fontSize: 11,
                      color: DiwaneColors.textMuted,
                      fontFamily: AppFont.interRegular,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: ElevatedButton(
              onPressed: () => Get.toNamed(AppRoutes.abonnementDiwaneView),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isGratuit ? DiwaneColors.navy : DiwaneColors.orange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text(
                isGratuit ? 'Upgrader' : 'Gérer',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  fontFamily: AppFont.interSemiBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String titre;
  final List<_MenuItem> items;
  const _SectionCard({required this.titre, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            titre.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              fontFamily: AppFont.interSemiBold,
              color: DiwaneColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: DiwaneColors.cardBorder, width: 0.5),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    const Divider(
                      height: 0.5,
                      color: DiwaneColors.cardBorder,
                      indent: 48,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Menu item ─────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? badge;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: 20, color: DiwaneColors.navy),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontFamily: AppFont.interRegular,
          color: DiwaneColors.textPrimary,
        ),
      ),
      trailing: onTap != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: DiwaneColors.orangeLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: DiwaneColors.orange,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    size: 18, color: DiwaneColors.textMuted),
              ],
            )
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      minLeadingWidth: 32,
    );
  }
}

// ── Bouton déconnexion ────────────────────────────────────────────────────────

class _BoutonDeconnexion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
        onPressed: () => _confirmer(context),
        icon: const Icon(Icons.logout, size: 18, color: Colors.red),
        label: const Text(
          'Se déconnecter',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
            fontFamily: AppFont.interSemiBold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
    );
  }

  void _confirmer(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Se déconnecter ?',
          style: TextStyle(fontSize: 16, fontFamily: AppFont.interSemiBold),
        ),
        content: const Text(
          'Vous devrez vous reconnecter pour accéder à votre compte.',
          style: TextStyle(fontFamily: AppFont.interRegular, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              DiwaneAuthController.to.logout();
            },
            child: const Text(
              'Déconnecter',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: DiwaneColors.surface,
        border: Border(top: BorderSide(color: DiwaneColors.cardBorder)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              Obx(() {
                final isCourtier = DiwaneAuthController.to.isCourtier;
                return _NavItem(
                  icon: isCourtier
                      ? Icons.dashboard_outlined
                      : Icons.home_rounded,
                  label: isCourtier ? 'Dashboard' : 'Accueil',
                  onTap: () => isCourtier
                      ? Get.offAllNamed(AppRoutes.courtierDashboardView)
                      : Get.offAllNamed(AppRoutes.homeDiwaneView),
                );
              }),
              _NavItem(
                icon: Icons.search_rounded,
                label: 'Recherche',
                onTap: () => Get.toNamed(AppRoutes.searchDiwaneView),
              ),
              _NavItem(
                icon: Icons.favorite_border_rounded,
                label: 'Favoris',
                onTap: () => Get.toNamed(AppRoutes.favorisDiwaneView),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                onTap: () => Get.toNamed(AppRoutes.conversationsListView),
              ),
              const _NavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                isActive: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? DiwaneColors.orange : DiwaneColors.textMuted;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppFont.interRegular,
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card invitation reçue ─────────────────────────────────────────────────────

class _InvitationRecueCard extends StatelessWidget {
  final InvitationAgence inv;
  final VoidCallback onAccepter;
  final VoidCallback onRefuser;

  const _InvitationRecueCard({
    required this.inv,
    required this.onAccepter,
    required this.onRefuser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DiwaneColors.navy.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DiwaneColors.navy,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Invitation agence',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            inv.agenceNom,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              fontFamily: AppFont.interSemiBold,
              color: DiwaneColors.navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'De : ${inv.proprietaireNom}',
            style: const TextStyle(fontSize: 13, color: DiwaneColors.textMuted),
          ),
          const SizedBox(height: 4),
          const Text(
            'En acceptant, votre compte passera au plan Pro.',
            style: TextStyle(fontSize: 12, color: DiwaneColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRefuser,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Refuser'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccepter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DiwaneColors.navy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Rejoindre', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
