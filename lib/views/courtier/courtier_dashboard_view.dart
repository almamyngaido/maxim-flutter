import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/utilisateur_diwane_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/bien_diwane_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/badge_widget.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/bien_card.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/disponibilite_menu.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/diwane_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_diwane_model.dart';

class CourtierDashboardView extends StatefulWidget {
  const CourtierDashboardView({super.key});

  @override
  State<CourtierDashboardView> createState() => _CourtierDashboardViewState();
}

class _CourtierDashboardViewState extends State<CourtierDashboardView> {
  final _auth = Get.find<DiwaneAuthController>();
  final _service = Get.find<BienDiwaneService>();

  final RxList<BienDiwane> _annonces = <BienDiwane>[].obs;
  final RxBool _loading = false.obs;
  final RxString _error = ''.obs;

  // Stats agrégées depuis les annonces
  final RxInt _nbActives = 0.obs;
  final RxInt _nbVues = 0.obs;
  final RxInt _nbContacts = 0.obs;

  // Note fake déterministe (3.5–5.0) basée sur l'user ID
  double get _fakeNote {
    final uid = _auth.user.value?.id ?? '';
    if (uid.isEmpty) return 4.2;
    final seed = uid.codeUnits.fold(0, (a, b) => a + b);
    return 3.5 + (Random(seed).nextInt(16) / 10.0);
  }

  @override
  void initState() {
    super.initState();
    _chargerAnnonces();
  }

  Future<void> _chargerAnnonces() async {
    final token = _auth.token.value;
    if (token.isEmpty) return;
    _loading.value = true;
    _error.value = '';
    try {
      final result = await _service.mesAnnonces(token);
      _annonces.assignAll(result);
      _nbActives.value = result.where((b) => b.statut == 'publie').length;
      _nbVues.value    = result.fold(0, (sum, b) => sum + b.nbVues);
      _nbContacts.value = result.fold(0, (sum, b) => sum + b.nbContacts);
    } catch (e) {
      _error.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      _loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiwaneColors.background,
      bottomNavigationBar: _DashboardBottomNav(),
      body: RefreshIndicator(
        color: DiwaneColors.navy,
        onRefresh: _chargerAnnonces,
        child: CustomScrollView(
          slivers: [
            // Header courtier
            SliverToBoxAdapter(
              child: Obx(() => _CourtierHeader(
                    user: _auth.user.value,
                    onLogout: _auth.logout,
                    nbAnnonces: _nbActives.value,
                    nbVues: _nbVues.value,
                    nbContacts: _nbContacts.value,
                    note: _fakeNote,
                  )),
            ),

            // Bandeau quota plan gratuit
            SliverToBoxAdapter(
              child: Obx(() {
                final user = _auth.user.value;
                if (user == null || user.isPremium) return const SizedBox.shrink();
                final nb = user.nbAnnoncesActives;
                if (nb < 4) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: DiwaneColors.orangeLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: DiwaneColors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: DiwaneColors.orange, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          nb >= 5
                              ? 'Limite atteinte (5/5). Passez en Premium pour publier plus.'
                              : 'Il vous reste ${5 - nb} annonce(s) gratuite(s).',
                          style: const TextStyle(
                            fontFamily: AppFont.interRegular,
                            fontSize: 12,
                            color: DiwaneColors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            // Bouton publier
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: DiwaneButton(
                  label: '+ Publier un bien',
                  onPressed: () => Get.toNamed(AppRoutes.publierBienView),
                  variant: DiwaneButtonVariant.secondary,
                  leading: const Icon(Icons.add_home_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),

            // Titre section
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Mes annonces',
                  style: TextStyle(
                    fontFamily: AppFont.interSemiBold,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DiwaneColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Liste annonces
            Obx(() {
              if (_loading.value) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: DiwaneColors.navy),
                  ),
                );
              }
              if (_error.value.isNotEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              color: DiwaneColors.textMuted, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            _error.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: AppFont.interRegular,
                              fontSize: 14,
                              color: DiwaneColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _chargerAnnonces,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (_annonces.isEmpty) {
                return const SliverFillRemaining(
                  child: _EmptyAnnonces(),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => BienCard(
                    bien: _annonces[i],
                    onTap: () => Get.toNamed('/diwane/bien/${_annonces[i].id}'),
                    onDisponibiliteTap: () => afficherMenuDisponibilite(
                      context,
                      _annonces[i],
                      _chargerAnnonces,
                    ),
                  ),
                  childCount: _annonces.length,
                ),
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ── Header courtier ──────────────────────────────────────────────

class _CourtierHeader extends StatelessWidget {
  final UtilisateurDiwane? user;
  final VoidCallback onLogout;
  final int nbAnnonces;
  final int nbVues;
  final int nbContacts;
  final double note;

  const _CourtierHeader({
    required this.user,
    required this.onLogout,
    required this.nbAnnonces,
    required this.nbVues,
    required this.nbContacts,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    if (user == null) return const SizedBox.shrink();

    return Container(
      color: DiwaneColors.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      child: Column(
        children: [
          // Ligne avatar + logout
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: DiwaneColors.orange,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user!.initiales,
                  style: const TextStyle(
                    fontFamily: AppFont.interBold,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user!.nomComplet,
                            style: const TextStyle(
                              fontFamily: AppFont.interBold,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _planBadge(user!.plan),
                      ],
                    ),
                    if (user!.nomAgence != null)
                      Text(
                        user!.nomAgence!,
                        style: TextStyle(
                          fontFamily: AppFont.interRegular,
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.white54, size: 22),
                tooltip: 'Déconnexion',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _StatItem(label: 'Annonces', value: '$nbAnnonces'),
                _divider(),
                _StatItem(label: 'Vues', value: _formatK(nbVues)),
                _divider(),
                _StatItem(label: 'Contacts', value: '$nbContacts'),
                _divider(),
                _StatItem(label: 'Note', value: '${note.toStringAsFixed(1)} ⭐'),
              ],
            ),
          ),

          // Accès agence (Pro uniquement)
          if (user!.isPro) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.agenceProView),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_outline,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        user!.nomAgence?.isNotEmpty == true
                            ? user!.nomAgence!
                            : 'Mon Agence',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: AppFont.interRegular,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Colors.white54, size: 18),
                  ],
                ),
              ),
            ),
          ],

          // Badge vérifié
          if (user!.verifie) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                BadgeWidget.verifie(),
                if (!user!.isPremium) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () {}, // TODO: upgrade
                    child: const Text(
                      'Passer Premium →',
                      style: TextStyle(
                        fontFamily: AppFont.interMedium,
                        fontSize: 12,
                        color: DiwaneColors.orange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _planBadge(String plan) {
    return switch (plan) {
      'premium' => BadgeWidget.premium(),
      'pro'     => BadgeWidget.pro(),
      _         => BadgeWidget.gratuit(),
    };
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: Colors.white.withValues(alpha: 0.15),
      );

  String _formatK(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
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

class _EmptyAnnonces extends StatelessWidget {
  const _EmptyAnnonces();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: DiwaneColors.navyLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.add_home_rounded,
                color: DiwaneColors.navy, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune annonce publiée',
            style: TextStyle(
              fontFamily: AppFont.interSemiBold,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DiwaneColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Publiez votre premier bien pour commencer',
            style: TextStyle(
              fontFamily: AppFont.interRegular,
              fontSize: 13,
              color: DiwaneColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Navigation courtier ────────────────────────────────────────────────

class _DashboardBottomNav extends StatelessWidget {
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
              const _NavItem(
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                isActive: true,
              ),
              _NavItem(
                icon: Icons.search_rounded,
                label: 'Recherche',
                onTap: () => Get.toNamed(AppRoutes.searchDiwaneView),
              ),
              _NavItem(
                icon: Icons.add_circle_outline_rounded,
                label: 'Publier',
                onTap: () => Get.toNamed(AppRoutes.publierBienView),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                onTap: () => Get.toNamed(AppRoutes.conversationsListView),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                onTap: () => Get.toNamed(AppRoutes.profilDiwaneView),
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
