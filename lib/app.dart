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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_storage/get_storage.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/alerte_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/splash/splash_diwane_view.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Initialisation OneSignal — uniquement mobile (iOS / Android)
/// Sur web : OneSignal n'a pas d'implémentation Flutter, on skip.
/// Clé GetStorage pour persister le OneSignal subscription ID
const kOneSignalSubIdKey = 'onesignal_subscription_id';

Future<void> initOneSignal() async {
  if (kIsWeb) return; // Pas de plugin web pour OneSignal

  // App ID OneSignal — OneSignal Dashboard → Settings → Keys & IDs
  const appId = String.fromEnvironment(
    'ONESIGNAL_APP_ID',
    defaultValue: '5c0e5b85-6504-41a5-804c-cba57ddcf5bb',
  );
  // ignore: avoid_print
  print('[OneSignal] Initialisation avec App ID: $appId');
  OneSignal.initialize(appId);

  // Observer : dès que le subscription ID est disponible, on le persiste
  OneSignal.User.pushSubscription.addObserver((state) {
    final id = state.current.id ?? '';
    // ignore: avoid_print
    print('[OneSignal] Subscription update — id: "$id" optedIn: ${state.current.optedIn}');
    if (id.isNotEmpty) {
      GetStorage().write(kOneSignalSubIdKey, id);
    }
  });

  // Lire l'ID immédiatement au cas où il est déjà disponible (relance de l'app)
  final immediateId = OneSignal.User.pushSubscription.id ?? '';
  if (immediateId.isNotEmpty) {
    GetStorage().write(kOneSignalSubIdKey, immediateId);
    // ignore: avoid_print
    print('[OneSignal] Subscription ID immédiat: $immediateId');
  }

  if (!OneSignal.Notifications.permission) {
    await OneSignal.Notifications.requestPermission(true);
  }

  // Handler : tap sur notification → ouvrir le bien correspondant
  OneSignal.Notifications.addClickListener((event) {
    final data = event.notification.additionalData;
    if (data != null && data['type'] == 'nouveau_bien') {
      final bienId = data['bien_id']?.toString() ?? '';
      if (bienId.isNotEmpty) {
        Get.toNamed(
          '/diwane/bien/$bienId',
          parameters: {'id': bienId},
        );
      }
    }
  });
}

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
    Get.put<AlerteService>(AlerteService(), permanent: true);

    // ── Contrôleurs Diwane ───────────────────────────────────
    Get.put<DiwaneAuthController>(DiwaneAuthController(), permanent: true);
    Get.lazyPut<BiensController>(() => BiensController(), fenix: true);
    Get.lazyPut<DiwaneSearchController>(() => DiwaneSearchController(), fenix: true);
  }
}
