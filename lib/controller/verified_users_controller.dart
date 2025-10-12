import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/user_service.dart';

class VerifiedUsersController extends GetxController {
  final UserService _userService = UserService();

  RxList<Map<String, dynamic>> verifiedUsers = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVerifiedUsers();
  }

  // Récupérer tous les utilisateurs vérifiés
  Future<void> fetchVerifiedUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final users = await _userService.getVerifiedUsers();
      verifiedUsers.value = users;

      print('✅ Fetched ${users.length} verified users');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Error fetching verified users: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Désactiver un utilisateur (passer en non vérifié)
  Future<void> deactivateUser(String userId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _userService.updateUserVerification(userId, false);

      // Retirer l'utilisateur de la liste
      verifiedUsers.removeWhere((user) => user['id'] == userId);

      Get.snackbar(
        'Succès',
        'Utilisateur désactivé avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      print('✅ User deactivated: $userId');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Error deactivating user: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
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
