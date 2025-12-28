import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/session_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() async {
    super.onInit();

    // Wait for splash duration, then check authentication
    Future.delayed(const Duration(seconds: AppSize.size4), () {
      final sessionService = Get.find<SessionService>();

      // Check if user is already authenticated
      if (sessionService.isAuthenticated()) {
        print('✅ User is authenticated, going to home');
        // User is logged in, go directly to main app
        Get.offAllNamed(AppRoutes.bottomBarView);
      } else {
        print('🔓 User not authenticated, going to onboarding');
        // User not logged in, show onboarding
        Get.offAllNamed(AppRoutes.onboardView);
      }
    });
  }
}