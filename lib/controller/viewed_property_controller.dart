import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/viewed_properties_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewedPropertyController extends GetxController {
  final ViewedPropertiesService _viewedPropertiesService =
      Get.put(ViewedPropertiesService());

  RxList<BienImmo> viewedProperties = <BienImmo>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadViewedProperties();
  }

  /// Load viewed properties from API
  Future<void> loadViewedProperties() async {
    try {
      isLoading.value = true;
      print('🔍 Loading viewed properties...');

      final properties = await _viewedPropertiesService.fetchViewedProperties(
        limit: 20,
      );

      viewedProperties.value = properties;

      print('✅ Loaded ${properties.length} viewed properties');
    } catch (e) {
      print('❌ Error loading viewed properties: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get the number of viewed properties
  int get viewedPropertiesCount =>
      _viewedPropertiesService.getViewedPropertiesCount();

  /// Clear all viewed properties
  Future<void> clearAllViewedProperties() async {
    await _viewedPropertiesService.clearViewedProperties();
    await loadViewedProperties();
  }

  /// Remove a specific property from viewed list
  Future<void> removeViewedProperty(String propertyId) async {
    await _viewedPropertiesService.removeViewedProperty(propertyId);
    await loadViewedProperties();
  }

  /// Launch phone dialer with property owner's phone
  void launchDialer(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Numéro de téléphone non disponible',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible d\'appeler ce numéro',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}