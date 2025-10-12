import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/user_service.dart';

class AdminRolesController extends GetxController {
  final UserService _userService = UserService();

  RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllUsers();
  }

  // Récupérer tous les utilisateurs
  Future<void> fetchAllUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final users = await _userService.getAllUsers();
      allUsers.value = users;

      print('✅ Fetched ${users.length} users');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Error fetching users: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour le rôle d'un utilisateur
  Future<void> updateRole(String userId, String newRole) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _userService.updateUserRole(userId, newRole);

      // Mettre à jour la liste locale
      final index = allUsers.indexWhere((user) => user['id'] == userId);
      if (index != -1) {
        allUsers[index]['role'] = newRole;
        allUsers.refresh();
      }

      Get.snackbar(
        'Succès',
        'Rôle mis à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      print('✅ User role updated: $userId -> $newRole');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Error updating role: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrer les admins
  List<Map<String, dynamic>> get adminUsers {
    return allUsers.where((user) => user['role'] == 'admin').toList();
  }

  // Filtrer les utilisateurs normaux
  List<Map<String, dynamic>> get regularUsers {
    return allUsers.where((user) => user['role'] != 'admin').toList();
  }

  @override
  void onClose() {
    _userService.dispose();
    super.onClose();
  }
}
