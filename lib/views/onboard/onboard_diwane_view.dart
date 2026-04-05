import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/diwane_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/widgets/role_selector.dart';

class OnboardDiwaneView extends StatefulWidget {
  const OnboardDiwaneView({super.key});

  @override
  State<OnboardDiwaneView> createState() => _OnboardDiwaneViewState();
}

class _OnboardDiwaneViewState extends State<OnboardDiwaneView> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  UserRole? _selectedRole;

  // 3 slides + 1 page choix rôle = 4 pages
  static const int _totalSlides = 3;

  static const _slides = [
    _SlideData(
      icon: Icons.location_city_rounded,
      title: 'Des milliers de biens\nau Sénégal',
      subtitle:
          'Appartements, villas, bureaux à Dakar, Thiès et partout au Sénégal',
      isNavy: true,
    ),
    _SlideData(
      icon: Icons.search_rounded,
      title: 'Recherche\nintelligente',
      subtitle:
          'Filtrez par quartier, prix en FCFA, nombre de pièces, équipements',
      isNavy: false,
    ),
    _SlideData(
      icon: Icons.verified_user_rounded,
      title: 'Courtiers\nvérifiés',
      subtitle:
          'Chaque courtier est vérifié par notre équipe. Badges de confiance visibles',
      isNavy: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _totalSlides) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _continuer() {
    if (_selectedRole == null) return;
    GetStorage().write('diwane_onboarding_done', true);
    if (_selectedRole == UserRole.courtier) {
      // Courtier → doit créer un compte
      Get.offAllNamed(AppRoutes.registerDiwaneView, arguments: {'role': 'courtier'});
    } else {
      // Acheteur/locataire → accueil public, compte optionnel
      Get.offAllNamed(AppRoutes.homeDiwaneView);
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiwaneColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // PageView (slides + choix rôle)
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  ..._slides.map((s) => _SlideScreen(data: s)),
                  _RoleScreen(
                    selected: _selectedRole,
                    onSelect: (r) => setState(() => _selectedRole = r),
                  ),
                ],
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalSlides + 1, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 18 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? DiwaneColors.orange
                              : DiwaneColors.cardBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Bouton action
                  if (_currentPage < _totalSlides)
                    DiwaneButton(
                      label: 'Suivant',
                      onPressed: _nextPage,
                      variant: DiwaneButtonVariant.primary,
                    )
                  else
                    DiwaneButton(
                      label: _selectedRole == UserRole.courtier
                          ? 'Créer mon compte courtier'
                          : 'Commencer',
                      onPressed: _selectedRole != null ? _continuer : null,
                      variant: DiwaneButtonVariant.secondary,
                    ),

                  const SizedBox(height: 12),

                  // Liens contextuels
                  if (_currentPage < _totalSlides)
                    GestureDetector(
                      onTap: () {
                        GetStorage().write('diwane_onboarding_done', true);
                        Get.offAllNamed(AppRoutes.loginDiwaneView);
                      },
                      child: const Text(
                        'J\'ai déjà un compte',
                        style: TextStyle(
                          fontFamily: AppFont.interMedium,
                          fontSize: 14,
                          color: DiwaneColors.navy,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        GetStorage().write('diwane_onboarding_done', true);
                        Get.offAllNamed(AppRoutes.homeDiwaneView);
                      },
                      child: const Text(
                        'Parcourir sans compte',
                        style: TextStyle(
                          fontFamily: AppFont.interMedium,
                          fontSize: 14,
                          color: DiwaneColors.textMuted,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slide standard ──────────────────────────────────────────────

class _SlideData {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isNavy;

  const _SlideData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isNavy,
  });
}

class _SlideScreen extends StatelessWidget {
  final _SlideData data;

  const _SlideScreen({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.isNavy ? DiwaneColors.navyLight : DiwaneColors.orangeLight,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              data.icon,
              size: 60,
              color: data.isNavy ? DiwaneColors.navy : DiwaneColors.orange,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFont.interBold,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: DiwaneColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppFont.interRegular,
              fontSize: 15,
              color: DiwaneColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Écran choix rôle ────────────────────────────────────────────

class _RoleScreen extends StatelessWidget {
  final UserRole? selected;
  final void Function(UserRole) onSelect;

  const _RoleScreen({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qui êtes-vous ?',
            style: TextStyle(
              fontFamily: AppFont.interBold,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: DiwaneColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choisissez votre profil pour personnaliser votre expérience',
            style: TextStyle(
              fontFamily: AppFont.interRegular,
              fontSize: 15,
              color: DiwaneColors.textMuted,
            ),
          ),
          const SizedBox(height: 32),
          RoleSelector(selected: selected, onSelect: onSelect),
        ],
      ),
    );
  }
}
