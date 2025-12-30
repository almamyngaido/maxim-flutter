import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_service.dart';

class EditPropertyDetailsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  RxInt selectProperty = 0.obs;
  RxBool hasPhoneNumberFocus = true.obs;
  RxBool hasPhoneNumberInput = true.obs;
  FocusNode phoneNumberFocusNode = FocusNode();
  RxInt selectPropertyLooking = 0.obs;
  RxInt selectPropertyType = 0.obs;
  RxInt selectPropertyType2 = 0.obs;

  // Text Controllers for Basic Details
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // Text Controllers for Property Details
  TextEditingController nombrePiecesTotalController = TextEditingController();
  TextEditingController nombreChambresController = TextEditingController();
  TextEditingController nombreSallesBainController = TextEditingController();
  TextEditingController surfaceHabitableController = TextEditingController();
  TextEditingController surfaceTerrainController = TextEditingController();

  // Text Controllers for Price Details
  TextEditingController priceHaiController = TextEditingController();
  TextEditingController priceNetController = TextEditingController();
  TextEditingController chargeMensuelleController = TextEditingController();

  // Text Controllers for Location
  TextEditingController rueController = TextEditingController();
  TextEditingController villeController = TextEditingController();
  TextEditingController codePostalController = TextEditingController();
  TextEditingController paysController = TextEditingController();

  // Property data
  String? propertyId;
  int? sectionIndex;
  RxMap<String, dynamic> propertyData = <String, dynamic>{}.obs;
  RxBool isLoadingProperty = false.obs;
  RxBool isSavingProperty = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Get arguments
    final args = Get.arguments;
    if (args is Map) {
      propertyId = args['propertyId'] as String?;
      sectionIndex = args['sectionIndex'] as int?;

      if (propertyId != null) {
        loadPropertyData(propertyId!);
      }

      // Set the selected tab based on section index
      if (sectionIndex != null) {
        selectProperty.value = sectionIndex!;
      }
    }

    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });
    mobileNumberController.addListener(() {
      hasPhoneNumberInput.value = mobileNumberController.text.isNotEmpty;
    });
  }

  /// Load property data from API
  Future<void> loadPropertyData(String id) async {
    try {
      isLoadingProperty.value = true;
      print('🔍 Loading property data for editing: $id');

      final data = await _apiService.getBienImmo(id);

      if (data != null) {
        propertyData.value = data;

        // Populate Basic Details
        if (data['description'] != null) {
          titleController.text = data['description']['titre']?.toString() ?? '';
          descriptionController.text = data['description']['annonce']?.toString() ?? '';
        }

        // Populate Property Details
        nombrePiecesTotalController.text = data['nombrePiecesTotal']?.toString() ?? '';
        nombreChambresController.text = data['nombreChambres']?.toString() ?? '';
        nombreSallesBainController.text = data['nombreSallesBain']?.toString() ?? '';

        if (data['surfaces'] != null) {
          surfaceHabitableController.text = data['surfaces']['habitable']?.toString() ?? '';
          surfaceTerrainController.text = data['surfaces']['terrain']?.toString() ?? '';
        }

        // Populate Price Details
        if (data['prix'] != null) {
          priceHaiController.text = data['prix']['hai']?.toString() ?? '';
          priceNetController.text = data['prix']['net']?.toString() ?? '';
          chargeMensuelleController.text = data['prix']['chargeMensuelle']?.toString() ?? '';
        }

        // Populate Location
        if (data['localisation'] != null) {
          rueController.text = data['localisation']['rue']?.toString() ?? '';
          villeController.text = data['localisation']['ville']?.toString() ?? '';
          codePostalController.text = data['localisation']['codePostal']?.toString() ?? '';
          paysController.text = data['localisation']['pays']?.toString() ?? '';
        }

        // Phone number from owner
        if (data['utilisateur'] != null && data['utilisateur']['phoneNumber'] != null) {
          mobileNumberController.text = data['utilisateur']['phoneNumber'].toString();
        }

        // Set property type selections
        final typeBien = data['typeBien']?.toString() ?? '';
        if (typeBien == 'Appartement') {
          selectPropertyType2.value = 0;
        } else if (typeBien == 'Maison') {
          selectPropertyType2.value = 1;
        }

        print('✅ Property data loaded for editing');
        print('   Type: ${data['typeBien']}');
        print('   Price: ${data['prix']?['hai']}');
        print('   Title: ${titleController.text}');
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

  /// Save property changes
  Future<void> savePropertyChanges() async {
    try {
      isSavingProperty.value = true;

      if (propertyId == null || propertyId!.isEmpty) {
        throw Exception('ID du bien manquant');
      }

      print('🔄 Saving property changes for: $propertyId');

      // Build update data with all modified fields
      final Map<String, dynamic> updateData = {};

      // Basic Details - Description
      if (titleController.text.isNotEmpty || descriptionController.text.isNotEmpty) {
        updateData['description'] = {
          if (titleController.text.isNotEmpty) 'titre': titleController.text,
          if (descriptionController.text.isNotEmpty) 'annonce': descriptionController.text,
        };
      }

      // Property Details - Numbers
      if (nombrePiecesTotalController.text.isNotEmpty) {
        updateData['nombrePiecesTotal'] = int.tryParse(nombrePiecesTotalController.text) ?? 0;
      }
      if (nombreChambresController.text.isNotEmpty) {
        updateData['nombreChambres'] = int.tryParse(nombreChambresController.text) ?? 0;
      }
      if (nombreSallesBainController.text.isNotEmpty) {
        updateData['nombreSallesBain'] = int.tryParse(nombreSallesBainController.text) ?? 0;
      }

      // Property Details - Surfaces
      if (surfaceHabitableController.text.isNotEmpty || surfaceTerrainController.text.isNotEmpty) {
        updateData['surfaces'] = {
          if (surfaceHabitableController.text.isNotEmpty)
            'habitable': double.tryParse(surfaceHabitableController.text) ?? 0,
          if (surfaceTerrainController.text.isNotEmpty)
            'terrain': double.tryParse(surfaceTerrainController.text) ?? 0,
        };
      }

      // Price Details
      if (priceHaiController.text.isNotEmpty || priceNetController.text.isNotEmpty || chargeMensuelleController.text.isNotEmpty) {
        updateData['prix'] = {
          if (priceHaiController.text.isNotEmpty)
            'hai': double.tryParse(priceHaiController.text) ?? 0,
          if (priceNetController.text.isNotEmpty)
            'net': double.tryParse(priceNetController.text) ?? 0,
          if (chargeMensuelleController.text.isNotEmpty)
            'chargeMensuelle': double.tryParse(chargeMensuelleController.text) ?? 0,
        };
      }

      // Location
      if (rueController.text.isNotEmpty || villeController.text.isNotEmpty ||
          codePostalController.text.isNotEmpty || paysController.text.isNotEmpty) {
        updateData['localisation'] = {
          if (rueController.text.isNotEmpty) 'rue': rueController.text,
          if (villeController.text.isNotEmpty) 'ville': villeController.text,
          if (codePostalController.text.isNotEmpty) 'codePostal': codePostalController.text,
          if (paysController.text.isNotEmpty) 'pays': paysController.text,
        };
      }

      if (updateData.isEmpty) {
        Get.snackbar(
          'Info',
          'Aucune modification à enregistrer',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      print('📤 Update data: $updateData');

      // Call the update API
      final response = await _apiService.updateBienImmo(propertyId!, updateData);

      print('✅ Property updated successfully');

      Get.snackbar(
        'Succès',
        'Bien immobilier mis à jour avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.primaryColor.withValues(alpha: 0.2),
        colorText: Get.theme.primaryColor,
      );

      // Go back after a short delay
      await Future.delayed(Duration(milliseconds: 500));
      Get.back();
      Get.back(); // Go back twice to return to property details view

    } catch (e) {
      print('❌ Error saving property: $e');
      Get.snackbar(
        'Erreur',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.2),
        colorText: Colors.red,
      );
    } finally {
      isSavingProperty.value = false;
    }
  }

  void updateProperty(int index) {
    selectProperty.value = index;
  }

  void updatePropertyLooking(int index) {
    selectPropertyLooking.value = index;
  }

  void updatePropertyType(int index) {
    selectPropertyType.value = index;
  }

  void updateSelectProperty2(int index) {
    selectPropertyType2.value = index;
  }

  RxList<String> propertyList = [
    AppString.basicDetails,
    AppString.propertyDetails,
    AppString.pricingAndPhotos,
    AppString.amenities,
  ].obs;

  RxList<String> propertyLookingList = [
    AppString.buy,
    AppString.pg,
  ].obs;

  RxList<String> propertyTypeList = [
    AppString.residential,
    AppString.commercial,
  ].obs;

  RxList<String> propertyTypeImageList = [
    Assets.images.flatApartment.path,
    Assets.images.independentHouse.path,
    Assets.images.builderFloor.path,
    Assets.images.builderFloor.path,
    Assets.images.plotLand.path,
    Assets.images.officeSpace.path,
    Assets.images.other.path,
  ].obs;

  RxList<String> propertyType2List = [
    AppString.flatApartment,
    AppString.independentHouse,
    AppString.builderFloor,
    AppString.residentialPlot,
    AppString.plotLand,
    AppString.officeSpace,
    AppString.other,
  ].obs;

  @override
  void dispose() {
    // Dispose focus nodes
    phoneNumberFocusNode.dispose();

    // Dispose all controllers
    mobileNumberController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    nombrePiecesTotalController.dispose();
    nombreChambresController.dispose();
    nombreSallesBainController.dispose();
    surfaceHabitableController.dispose();
    surfaceTerrainController.dispose();
    priceHaiController.dispose();
    priceNetController.dispose();
    chargeMensuelleController.dispose();
    rueController.dispose();
    villeController.dispose();
    codePostalController.dispose();
    paysController.dispose();

    super.dispose();
  }
}
