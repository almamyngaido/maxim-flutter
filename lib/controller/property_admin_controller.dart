import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/property_admin_service.dart';

class PropertyAdminController extends GetxController {
  final PropertyAdminService _propertyService = PropertyAdminService();

  RxList<Map<String, dynamic>> properties = <Map<String, dynamic>>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllProperties();
  }

  // Récupérer tous les biens
  Future<void> fetchAllProperties() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final props = await _propertyService.getAllProperties();
      properties.value = props;

      print('✅ Fetched ${props.length} properties');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Error fetching properties: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Mettre à jour la disponibilité
  Future<void> updateAvailability(String propertyId, bool isAvailable) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _propertyService.updatePropertyAvailability(propertyId, isAvailable);

      // Mettre à jour la liste locale
      final index = properties.indexWhere((prop) => prop['id'] == propertyId);
      if (index != -1) {
        properties[index]['isAvailable'] = isAvailable;
        properties.refresh();
      }

      Get.snackbar(
        'Succès',
        isAvailable
            ? 'Bien marqué comme disponible'
            : 'Bien marqué comme non disponible',
        snackPosition: SnackPosition.BOTTOM,
      );

      print('✅ Property availability updated: $propertyId -> $isAvailable');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Error updating availability: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Marquer comme vendu
  Future<void> markAsSold(String propertyId, String soldBy) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _propertyService.markPropertyAsSold(propertyId, soldBy);

      // Mettre à jour la liste locale
      final index = properties.indexWhere((prop) => prop['id'] == propertyId);
      if (index != -1) {
        properties[index]['isSold'] = true;
        properties[index]['soldBy'] = soldBy;
        properties[index]['soldDate'] = DateTime.now().toIso8601String();
        properties.refresh();
      }

      Get.snackbar(
        'Succès',
        'Bien marqué comme vendu',
        snackPosition: SnackPosition.BOTTOM,
      );

      print('✅ Property marked as sold: $propertyId by $soldBy');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Error marking as sold: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Supprimer un bien
  Future<void> deleteProperty(String propertyId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _propertyService.deleteProperty(propertyId);

      // Retirer de la liste locale
      properties.removeWhere((prop) => prop['id'] == propertyId);

      Get.snackbar(
        'Succès',
        'Bien supprimé avec succès',
        snackPosition: SnackPosition.BOTTOM,
      );

      print('✅ Property deleted: $propertyId');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      print('❌ Error deleting property: $e');
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrer les biens disponibles
  List<Map<String, dynamic>> get availableProperties {
    return properties.where((prop) => prop['isAvailable'] == true).toList();
  }

  // Filtrer les biens non disponibles
  List<Map<String, dynamic>> get unavailableProperties {
    return properties.where((prop) => prop['isAvailable'] != true).toList();
  }

  // Filtrer les biens vendus
  List<Map<String, dynamic>> get soldProperties {
    return properties.where((prop) => prop['isSold'] == true).toList();
  }

  @override
  void onClose() {
    _propertyService.dispose();
    super.onClose();
  }
}
