import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:flutter/material.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class DeleteListingController extends GetxController {
  final storage = GetStorage();

  // UI States
  RxInt selectListing = 0.obs;
  RxBool isDeleting = false.obs;

  // Property Data from navigation arguments
  RxString propertyId = ''.obs;
  RxString propertyTitle = ''.obs;
  RxString propertyAddress = ''.obs;
  RxString propertyImage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // Get property data from navigation arguments
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;

    if (args != null) {
      propertyId.value = args['propertyId'] ?? '';
      propertyTitle.value = args['propertyTitle'] ?? 'Propriété';
      propertyAddress.value =
          args['propertyAddress'] ?? 'Adresse non spécifiée';
      propertyImage.value = args['propertyImage'] ?? '';

      print('Delete Listing Controller initialized with:');
      print('Property ID: ${propertyId.value}');
      print('Property Title: ${propertyTitle.value}');
    } else {
      print('❌ No property data provided to DeleteListingController');
    }
  }

  void updateListing(int index) {
    selectListing.value = index;
  }

  /// Delete the property from API
  Future<void> deleteProperty() async {
    if (propertyId.value.isEmpty) {
      Get.snackbar(
        'Erreur',
        'ID de propriété manquant',
        backgroundColor: AppColor.negativeColor,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isDeleting.value = true;

      String? token = storage.read('authToken');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/bien-immos/${propertyId.value}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Delete Property API Response Status: ${response.statusCode}');
      print('Delete Property API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success
        Get.snackbar(
          'Succès',
          'Propriété supprimée avec succès',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Navigate back to activity view and refresh the list
        Get.offNamedUntil(
          AppRoutes.bottomBarView,
          (route) => false,
          arguments: 1, // Go to activity tab
        );

        print('✅ Property deleted successfully');
      } else {
        // Handle specific error responses
        String errorMessage = 'Erreur lors de la suppression';

        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['error']?.toString() ??
              errorData['message']?.toString() ??
              errorMessage;
        } catch (e) {
          print('Error parsing error response: $e');
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ Error deleting property: $e');

      String userMessage = 'Erreur lors de la suppression de la propriété';

      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection')) {
        userMessage = 'Erreur de connexion. Vérifiez votre connexion internet.';
      } else if (e.toString().contains('Exception:')) {
        userMessage = e.toString().replaceAll('Exception: ', '');
      }

      Get.snackbar(
        'Erreur',
        userMessage,
        backgroundColor: AppColor.negativeColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isDeleting.value = false;
    }
  }

  /// Get selected deletion reason
  String getSelectedDeletionReason() {
    if (selectListing.value >= 0 && selectListing.value < listingList.length) {
      return listingList[selectListing.value];
    }
    return listingList.first;
  }

  /// Validate deletion (ensure a reason is selected)
  bool validateDeletion() {
    return selectListing.value >= 0;
  }

  /// Deletion reasons list
  RxList<String> listingList = [
    AppString.deleteListing1,
    AppString.deleteListing2,
    AppString.deleteListing3,
    AppString.deleteListing4,
    AppString.deleteListing5,
    AppString.deleteListing6,
  ].obs;
}
