import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bottom_bar_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/home_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/login_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

/// SessionService - Centralized session management
///
/// This service handles user session initialization and cleanup.
/// It ensures proper state management across login/logout cycles
/// to prevent bugs like admin features persisting after role changes.
class SessionService extends GetxService {
  final storage = GetStorage();

  /// Logout user completely
  ///
  /// This method:
  /// 1. Clears all stored data (authToken, userData, etc.)
  /// 2. Resets all controller states
  /// 3. Deletes all GetX controller instances
  /// 4. Navigates to login screen
  Future<void> logout() async {
    try {
      print('🔄 SessionService: Starting logout process...');

      // Step 1: Reset individual controllers before deletion
      if (Get.isRegistered<BottomBarController>()) {
        print('🔄 Resetting BottomBarController...');
        try {
          Get.find<BottomBarController>().reset();
        } catch (e) {
          print('⚠️ Error resetting BottomBarController: $e');
        }
      }

      if (Get.isRegistered<HomeController>()) {
        print('🔄 Resetting HomeController...');
        try {
          Get.find<HomeController>().reset();
        } catch (e) {
          print('⚠️ Error resetting HomeController: $e');
        }
      }

      if (Get.isRegistered<LoginController>()) {
        print('🔄 Resetting LoginController...');
        try {
          Get.find<LoginController>().reset();
        } catch (e) {
          print('⚠️ Error resetting LoginController: $e');
        }
      }

      // Step 2: Clear all storage FIRST (most important)
      print('🗑️ Clearing GetStorage...');
      await storage.erase();

      // Step 3: Delete all controller instances
      print('🗑️ Deleting all controllers...');
      Get.deleteAll(force: true);

      // Extra: Explicitly delete LoginController to ensure no cached instance
      try {
        Get.delete<LoginController>(force: true);
        print('🗑️ LoginController explicitly deleted');
      } catch (e) {
        print('⚠️ LoginController already deleted or not found');
      }

      print('✅ SessionService: Logout complete');

      // Step 4: Wait a tiny bit for cleanup to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Step 5: Navigate to login screen
      Get.offAllNamed(AppRoutes.loginView);
    } catch (e) {
      print('❌ SessionService: Logout error: $e');
      // Even if there's an error, try to navigate to login
      // Clear storage anyway (most critical)
      try {
        await storage.erase();
      } catch (_) {}

      // Force delete all controllers
      try {
        Get.deleteAll(force: true);
      } catch (_) {}

      // Navigate to login
      Get.offAllNamed(AppRoutes.loginView);
    }
  }

  /// Initialize user session after login
  ///
  /// This method:
  /// 1. Stores user data and auth token
  /// 2. Forces re-check of admin/agent status in relevant controllers
  ///
  /// Call this immediately after successful login/OTP verification
  void initializeSession(Map<String, dynamic> userData, String token) {
    try {
      print('🔐 SessionService: Initializing session...');
      print('   User: ${userData['email']} | Role: ${userData['role']}');

      // Store session data
      storage.write('authToken', token);

      // Store userData as JSON string to avoid _JsonMap type errors
      storage.write('userData', jsonEncode(userData));

      // Force re-check of role-based features
      // This is critical to prevent the bug where admin features persist
      if (Get.isRegistered<BottomBarController>()) {
        print('🔄 Triggering BottomBarController role re-check...');
        Get.find<BottomBarController>().checkAdminStatus();
      }

      print('✅ SessionService: Session initialized successfully');
    } catch (e) {
      print('❌ SessionService: Error initializing session: $e');
    }
  }

  /// Get current user data from storage
  Map<String, dynamic>? getCurrentUserData() {
    try {
      final userDataString = storage.read('userData');
      if (userDataString == null) return null;

      // If it's already a Map (old format), return it
      if (userDataString is Map) {
        return Map<String, dynamic>.from(userDataString);
      }

      // If it's a String (new format), parse it
      if (userDataString is String) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print('❌ Error reading userData: $e');
      return null;
    }
  }

  /// Get current auth token
  String? getCurrentToken() {
    return storage.read('authToken');
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    final token = getCurrentToken();
    return token != null && token.isNotEmpty;
  }

  /// Get current user role
  String? getCurrentUserRole() {
    final userData = getCurrentUserData();
    return userData?['role']?.toString().toLowerCase();
  }

  /// Check if current user is admin
  bool isAdmin() {
    return getCurrentUserRole() == 'admin';
  }

  /// Check if current user is agent
  bool isAgent() {
    return getCurrentUserRole() == 'agent';
  }

  /// Check if current user is regular user
  bool isUser() {
    return getCurrentUserRole() == 'user';
  }
}
