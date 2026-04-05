import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/biens_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/bien_card.dart';

class HomeDiwaneView extends StatelessWidget {
  const HomeDiwaneView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<DiwaneAuthController>();
    final biens = Get.find<BiensController>();

    return Scaffold(
      backgroundColor: DiwaneColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverToBoxAdapter(child: _HomeHeader(auth: auth, biens: biens)),
          SliverToBoxAdapter(child: _FilterPills(biens: biens)),
        ],
        body: Obx(() {
          if (biens.isLoading.value && biens.biens.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: DiwaneColors.navy),
            );
          }
          if (biens.error.value.isNotEmpty && biens.biens.isEmpty) {
            return _ErrorState(
              message: biens.error.value,
              onRetry: () => biens.fetchBiens(),
            );
          }
          if (biens.biens.isEmpty) {
            return const _EmptyState();
          }
          return RefreshIndicator(
            color: DiwaneColors.navy,
            onRefresh: () => biens.fetchBiens(),
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: biens.biens.length + (biens.hasMore.value ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == biens.biens.length) {
                  // Trigger load more
                  biens.loadMore();
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: DiwaneColors.navy),
                    ),
                  );
                }
                final bien = biens.biens[i];
                return BienCard(
                  bien: bien,
                  onTap: () => Get.toNamed('/diwane/bien/${bien.id}'),
                );
              },
            ),
          );
        }),
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

// ── Header navy ──────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  final DiwaneAuthController auth;
  final BiensController biens;

  const _HomeHeader({required this.auth, required this.biens});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DiwaneColors.navy,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      child: Column(
        children: [
          // Salutation + avatar + notif
          Row(
            children: [
              Expanded(
                child: Obx(() {
                  final user = auth.user.value;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour,',
                        style: TextStyle(
                          fontFamily: AppFont.interRegular,
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        user?.prenom ?? 'Visiteur',
                        style: const TextStyle(
                          fontFamily: AppFont.interBold,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              // Avatar ou bouton connexion
              Obx(() {
                final user = auth.user.value;
                if (user == null) {
                  return GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.loginDiwaneView),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: DiwaneColors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Connexion',
                        style: TextStyle(
                          fontFamily: AppFont.interSemiBold,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
                return GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.profilDiwaneView),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: DiwaneColors.orange,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user.initiales,
                      style: const TextStyle(
                        fontFamily: AppFont.interBold,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 16),

          // SearchBar
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.searchDiwaneView),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(Icons.search, color: DiwaneColors.textMuted, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Quartier, ville, référence…',
                      style: TextStyle(
                        fontFamily: AppFont.interRegular,
                        fontSize: 14,
                        color: DiwaneColors.textMuted.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: DiwaneColors.navy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Filtres',
                      style: TextStyle(
                        fontFamily: AppFont.interSemiBold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pills de filtre ──────────────────────────────────────────────

class _FilterPills extends StatelessWidget {
  final BiensController biens;

  const _FilterPills({required this.biens});

  static const _pills = [
    ('', 'Tous'),
    ('location', 'Location'),
    ('vente', 'Vente'),
    ('Dakar', 'Dakar'),
    ('Thiès', 'Thiès'),
    ('Mbour', 'Mbour'),
    ('Saint-Louis', 'Saint-Louis'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DiwaneColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          final activeType = biens.filterType.value;
          final activeVille = biens.filterVille.value;

          return Row(
            children: _pills.map((pill) {
              final (value, label) = pill;
              final isTypeFilter = value == 'location' || value == 'vente' || value == '';
              final isActive = isTypeFilter
                  ? activeType == value
                  : activeVille == value;

              return GestureDetector(
                onTap: () {
                  if (isTypeFilter) {
                    biens.filtrerParType(value);
                  } else {
                    biens.filtrerParVille(
                        biens.filterVille.value == value ? '' : value);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? DiwaneColors.orange : DiwaneColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive
                          ? DiwaneColors.orange
                          : DiwaneColors.cardBorder,
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: AppFont.interMedium,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isActive ? Colors.white : DiwaneColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ),
    );
  }
}

// ── États vide / erreur ──────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

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
            child: const Icon(Icons.home_work_outlined,
                color: DiwaneColors.navy, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune annonce',
            style: TextStyle(
              fontFamily: AppFont.interSemiBold,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DiwaneColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Aucun bien ne correspond à vos filtres',
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: DiwaneColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFont.interRegular,
                fontSize: 14,
                color: DiwaneColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Navigation ────────────────────────────────────────────

void _requireAuth(VoidCallback onAuthenticated) {
  final auth = Get.find<DiwaneAuthController>();
  if (auth.isLoggedIn) {
    onAuthenticated();
  } else {
    _showLoginPrompt();
  }
}

void _showLoginPrompt() {
  Get.bottomSheet(
    Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: DiwaneColors.navyLight, borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.lock_outline_rounded, color: DiwaneColors.navy, size: 28),
          ),
          const SizedBox(height: 16),
          const Text(
            'Créez un compte gratuit',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DiwaneColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connectez-vous pour sauvegarder des favoris, recevoir des alertes et contacter les courtiers.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: DiwaneColors.textMuted, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed(AppRoutes.registerDiwaneView);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DiwaneColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Créer un compte', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Get.back();
                Get.toNamed(AppRoutes.loginDiwaneView);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: DiwaneColors.navy,
                side: const BorderSide(color: DiwaneColors.navy),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Se connecter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    ),
  );
}

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
              _NavItem(icon: Icons.home_rounded, label: 'Accueil', isActive: true),
              _NavItem(
                icon: Icons.search_rounded,
                label: 'Recherche',
                onTap: () => Get.toNamed(AppRoutes.searchDiwaneView),
              ),
              _NavItem(
                icon: Icons.favorite_border_rounded,
                label: 'Favoris',
                onTap: () => _requireAuth(() => Get.toNamed(AppRoutes.favorisDiwaneView)),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                onTap: () => _requireAuth(() => Get.toNamed(AppRoutes.conversationsListView)),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                onTap: () => _requireAuth(() => Get.toNamed(AppRoutes.profilDiwaneView)),
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
