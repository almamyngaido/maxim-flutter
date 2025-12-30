import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_service.dart';

class EditPropertyController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  RxList<String> editPropertyTitleList = [
    AppString.basicDetails,
    AppString.propertyDetails,
    AppString.priceDetails,
    AppString.amenities,
  ].obs;

  RxList<String> editPropertySubtitleList = [
    AppString.basicDetailsString,
    AppString.propertyDetailsString,
    AppString.priceDetailsString,
    AppString.amenitiesString,
  ].obs;

  // Property data
  String? propertyId;
  RxMap<String, dynamic> propertyData = <String, dynamic>{}.obs;
  RxBool isLoadingProperty = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Get property ID from navigation arguments
    final String? id = Get.arguments as String?;

    if (id != null && id.isNotEmpty) {
      propertyId = id;
      loadPropertyData(id);
    } else {
      print('⚠️ No property ID provided to EditPropertyController');
    }
  }

  /// Load property data from API
  Future<void> loadPropertyData(String id) async {
    try {
      isLoadingProperty.value = true;
      print('🔍 Loading property data for editing: $id');

      final data = await _apiService.getBienImmo(id);

      if (data != null) {
        propertyData.value = data;
        print('✅ Property data loaded for editing');
        print('   Type: ${data['typeBien']}');
        print('   Price: ${data['prix']?['hai']}');
      }
    } catch (e) {
      print('❌ Error loading property for editing: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les données du bien',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingProperty.value = false;
    }
  }
}