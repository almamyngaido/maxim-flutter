import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class EditPropertyDetailsController extends GetxController {
  RxInt selectProperty = 0.obs;
  RxBool hasPhoneNumberFocus = true.obs;
  RxBool hasPhoneNumberInput = true.obs;
  FocusNode phoneNumberFocusNode = FocusNode();
  RxInt selectPropertyLooking = 0.obs;
  RxInt selectPropertyType = 0.obs;
  RxInt selectPropertyType2 = 0.obs;

  TextEditingController mobileNumberController = TextEditingController(text: AppString.francisZiemeNumber);

  @override
  void onInit() {
    super.onInit();
    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });
    mobileNumberController.addListener(() {
      hasPhoneNumberInput.value = mobileNumberController.text.isNotEmpty;
    });
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
    AppString.rent,
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
    super.dispose();
    phoneNumberFocusNode.dispose();
    mobileNumberController.clear();
  }
}