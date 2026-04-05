import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_font.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class SplashDiwaneView extends StatefulWidget {
  const SplashDiwaneView({super.key});

  @override
  State<SplashDiwaneView> createState() => _SplashDiwaneViewState();
}

class _SplashDiwaneViewState extends State<SplashDiwaneView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );
    _animCtrl.forward();

    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final storage = GetStorage();
    final onboardingDone = storage.read<bool>('diwane_onboarding_done') ?? false;

    if (!onboardingDone) {
      Get.offAllNamed(AppRoutes.onboardDiwaneView);
      return;
    }

    final auth = Get.find<DiwaneAuthController>();
    if (auth.isLoggedIn) {
      if (auth.user.value?.isAdmin == true) {
        Get.offAllNamed(AppRoutes.diwaneModerationView);
      } else if (auth.isCourtier) {
        Get.offAllNamed(AppRoutes.courtierDashboardView);
      } else {
        Get.offAllNamed(AppRoutes.homeDiwaneView);
      }
    } else {
      // Non connecté → accueil public (pas besoin de compte pour parcourir)
      Get.offAllNamed(AppRoutes.homeDiwaneView);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiwaneColors.navy,
      body: Stack(
        children: [
          // Motif de fond
          Positioned.fill(
            child: CustomPaint(painter: _SplashPatternPainter()),
          ),

          // Contenu centré
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo maison + immeuble
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.location_city_rounded,
                        color: DiwaneColors.orange,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Diwane',
                      style: TextStyle(
                        fontFamily: AppFont.interBold,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trouvez votre bien idéal au Sénégal',
                      style: TextStyle(
                        fontFamily: AppFont.interRegular,
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Dots de progression en bas
          Positioned(
            bottom: 56,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: const _ProgressDots(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i == 0;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 18 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? DiwaneColors.orange
                : Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _SplashPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    // Cercles décoratifs
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.1), 120, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), 100, paint);

    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.9), 180, paint2);
  }

  @override
  bool shouldRepaint(_) => false;
}
