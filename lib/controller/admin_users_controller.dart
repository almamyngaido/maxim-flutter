import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/user_service.dart';

class AdminUsersController extends GetxController {
  final UserService _userService = UserService();

  RxList<Map<String, dynamic>> unverifiedUsers = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

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

  @override
  void onClose() {
    _userService.dispose();
    super.onClose();
  }
}
