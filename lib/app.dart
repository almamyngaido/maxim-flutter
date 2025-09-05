import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/splash/splash_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppString.appName,
      defaultTransition: Transition.fadeIn,
      debugShowCheckedModeBanner: false,
      home: SplashView(),
      getPages: AppRoutes.pages,

      // ADD THIS: Connect the InitialBinding to register services
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

// Move InitialBinding class here from main.dart
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // This will be called when the app starts
    print('Registering PropertyDataManager service...');

    // Register PropertyDataManager as a service (singleton)
    Get.put<PropertyDataManager>(PropertyDataManager(), permanent: true);

    print('PropertyDataManager registered successfully');
  }
}
