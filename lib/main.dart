import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:luxury_real_estate_flutter_ui_kit/app.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/auth.service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_service.dart'; // ADD THIS IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Initialize dependencies before running the app
  DependencyInjection.init();

  runApp(const MyApp());
}

class DependencyInjection {
  static void init() {
    // Existing services
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);

    // Register PropertyDataManager here as well
    Get.put<PropertyDataManager>(PropertyDataManager(), permanent: true);

    // ADD THIS: Register ApiService
    Get.put<ApiService>(ApiService(), permanent: true);

    print('🚀 All services initialized in DependencyInjection');
  }
}
