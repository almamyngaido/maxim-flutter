import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';

class AddPhotoAndPricingController extends GetxController {
  TextEditingController expectedPriceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  RxInt selectOwnership = 0.obs;
  RxInt selectPriceDetails = 0.obs;
  RxList<XFile> images = <XFile>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImages() async {
    final List<XFile>? picked = await _picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      images.addAll(picked.take(5 - images.length));
    }
  }

  void removeImage(int index) {
    images.removeAt(index);
  }

  void updateOwnership(int index) {
    selectOwnership.value = index;
  }

  void updatePriceDetails(int index) {
    selectPriceDetails.value = index;
  }

  RxList<String> ownershipList = [
    AppString.freehold,
    AppString.coOperativeSociety,
    AppString.powerOfAttorney,
    AppString.leasehold,
  ].obs;

  RxList<String> priceDetailsList = [
    AppString.allInclusivePrice,
    AppString.priceNegotiable,
    AppString.taxAndGovtCharges,
  ].obs;

  @override
  void dispose() {
    super.dispose();
    expectedPriceController.clear();
    descriptionController.clear();
  }
}
