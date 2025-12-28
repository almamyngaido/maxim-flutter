import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/user_service.dart';

class AdminUsersController extends GetxController {
  final UserService _userService = UserService();
  final storage = GetStorage();

  RxList<Map<String, dynamic>> unverifiedUsers = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxBool isSendingOtp = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUnverifiedUsers();
  }

  // Récupérer tous les utilisateurs non vérifiés
  Future<void> fetchUnverifiedUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final users = await _userService.getUnverifiedUsers();
      unverifiedUsers.value = users;

      print('✅ Fetched ${users.length} unverified users');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Error fetching unverified users: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour le statut de vérification d'un utilisateur
  Future<void> updateUserVerification(String userId, bool isVerified) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _userService.updateUserVerification(userId, isVerified);

      // Mettre à jour la liste locale
      final index = unverifiedUsers.indexWhere((user) => user['id'] == userId);
      if (index != -1) {
        if (isVerified) {
          // Si vérifié, on retire de la liste des non vérifiés
          unverifiedUsers.removeAt(index);
        } else {
          unverifiedUsers[index]['verified'] = isVerified;
        }
      }

      Get.snackbar(
        'Succès',
        'Statut de vérification mis à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      print('✅ User verification updated: $userId -> $isVerified');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Error updating user verification: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Récupérer les détails d'un utilisateur
  Future<Map<String, dynamic>?> getUserDetails(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userDetails = await _userService.getUserDetails(userId);

      print('✅ Fetched user details for: $userId');
      return userDetails;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Error fetching user details: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Send OTP to user (Admin approves and triggers OTP email)
  Future<void> sendOtpToUser({String? userId, String? email}) async {
    try {
      isSendingOtp.value = true;
      errorMessage.value = '';

      // Get admin token
      String? adminToken = storage.read('authToken');
      if (adminToken == null || adminToken.isEmpty) {
        throw Exception('Token d\'authentification manquant. Veuillez vous reconnecter.');
      }

      print('🔄 Sending OTP request...');
      print('📧 Email: $email');
      print('🆔 User ID: $userId');
      print('🔑 Token exists: ${adminToken.isNotEmpty}');

      // Send OTP via API
      final response = await _userService.sendOtpToUser(
        userId: userId,
        email: email,
        adminToken: adminToken,
      );

      print('✅ OTP sent successfully!');
      print('📦 Response type: ${response.runtimeType}');
      print('📦 Response data: $response');

      // Extract message safely
      String successMessage = 'Code OTP envoyé à l\'utilisateur par email !';
      if (response is Map<String, dynamic> && response.containsKey('message')) {
        successMessage = response['message'] as String? ?? successMessage;
      }

      Get.snackbar(
        'Succès',
        successMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 3),
      );

      // Refresh the unverified users list
      await fetchUnverifiedUsers();
    } catch (e, stackTrace) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Error sending OTP: $e');
      print('📍 Stack trace: $stackTrace');

      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isSendingOtp.value = false;
    }
  }

  @override
  void onClose() {
    _userService.dispose();
    super.onClose();
  }
}
