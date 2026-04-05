import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/biens_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/search_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/diwane_auth_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/core/theme/diwane_theme.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/bien_diwane_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/diwane_auth_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/diwane_favoris_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/payment_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/verification_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/favoris_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/splash/splash_diwane_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Diwane',
      defaultTransition: Transition.fadeIn,
      debugShowCheckedModeBanner: false,
      home: const SplashDiwaneView(),
      getPages: AppRoutes.pages,
      theme: DiwaneTheme.theme,

      // Connect the InitialBinding to register services
      initialBinding: InitialBinding(),

      // Add localization support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('fr', 'FR'), // French
      ],
      locale: const Locale('fr', 'FR'), // Default to French
      fallbackLocale: const Locale('en', 'US'), // Fallback to English
    );
  }
}

// Updated InitialBinding class
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<PropertyDataManager>(PropertyDataManager(), permanent: true);
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<FavorisService>(FavorisService(), permanent: true);

    // ── Services Diwane ──────────────────────────────────────
    Get.put<DiwaneAuthService>(DiwaneAuthService(), permanent: true);
    Get.put<BienDiwaneService>(BienDiwaneService(), permanent: true);
    Get.put<DiwaneFavorisService>(DiwaneFavorisService(), permanent: true);
    Get.put<PaymentService>(PaymentService(), permanent: true);
    Get.put<VerificationService>(VerificationService(), permanent: true);

    // ── Contrôleurs Diwane ───────────────────────────────────
    Get.put<DiwaneAuthController>(DiwaneAuthController(), permanent: true);
    Get.lazyPut<BiensController>(() => BiensController(), fenix: true);
    Get.lazyPut<DiwaneSearchController>(() => DiwaneSearchController(), fenix: true);
  }
}
