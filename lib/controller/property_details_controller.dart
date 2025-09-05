import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class PropertyDetailsController extends GetxController {
  RxBool isExpanded = false.obs;
  RxInt selectAgent = 0.obs;
  RxBool isChecked = false.obs;
  RxInt selectProperty = 0.obs;
  RxBool isVisitExpanded = false.obs;
  String truncatedText = AppString.aboutPropertyString.substring(0, 200);
  RxBool hasFullNameFocus = false.obs;
  RxBool hasFullNameInput = false.obs;
  RxBool hasPhoneNumberFocus = false.obs;
  RxBool hasPhoneNumberInput = false.obs;
  RxBool hasEmailFocus = false.obs;
  RxBool hasEmailInput = false.obs;
  FocusNode focusNode = FocusNode();
  FocusNode phoneNumberFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  RxList<bool> isSimilarPropertyLiked = <bool>[].obs;

  ScrollController scrollController = ScrollController();
  RxDouble selectedOffset = 0.0.obs;
  RxBool showBottomProperty = false.obs;

  @override
  void onInit() {
    super.onInit();
    // scrollController.addListener(() {
    //   if(scrollController.offset == 700) {
    //     selectedOffset.value =  scrollController.offset;
    //   }
    // });
    focusNode.addListener(() {
      hasFullNameFocus.value = focusNode.hasFocus;
    });
    phoneNumberFocusNode.addListener(() {
      hasPhoneNumberFocus.value = phoneNumberFocusNode.hasFocus;
    });
    emailFocusNode.addListener(() {
      hasEmailFocus.value = emailFocusNode.hasFocus;
    });
    fullNameController.addListener(() {
      hasFullNameInput.value = fullNameController.text.isNotEmpty;
    });
    mobileNumberController.addListener(() {
      hasPhoneNumberInput.value = mobileNumberController.text.isNotEmpty;
    });
    emailController.addListener(() {
      hasEmailInput.value = emailController.text.isNotEmpty;
    });
  }

  void toggleVisitExpansion() {
    isVisitExpanded.value = !isVisitExpanded.value;
  }

  void updateAgent(int index) {
    selectAgent.value = index;
  }

  void toggleCheckbox() {
    isChecked.toggle();
  }

  void updateProperty(int index) {
    selectProperty.value = index;
  }

  RxList<String> searchPropertyImageList = [
    Assets.images.bath.path,
    Assets.images.bed.path,
    Assets.images.plot.path,
  ].obs;

  RxList<String> searchPropertyTitleList = [
    AppString.point2,
    AppString.point2,
    AppString.bhk2,
  ].obs;

  RxList<String> searchProperty2ImageList = [
    Assets.images.plot.path,
    Assets.images.indianRupee.path,
  ].obs;

  RxList<String> searchProperty2TitleList = [
    AppString.squareFeet966,
    AppString.rupee3252,
  ].obs;

  RxList<String> keyHighlightsTitleList = [
    AppString.parkingAvailable,
    AppString.poojaRoomAvailable,
    AppString.semiFurnishedText,
    AppString.balconies1,
  ].obs;

  RxList<String> propertyDetailsTitleList = [
    AppString.layout,
    AppString.ownerShip,
    AppString.superArea,
    AppString.overlooking,
    AppString.widthOfFacingRoad,
    AppString.flooring,
    AppString.waterSource,
    AppString.furnishing,
    AppString.facing,
    AppString.propertyId,
  ].obs;

  RxList<String> propertyDetailsSubTitleList = [
    AppString.bhk3PoojaRoom,
    AppString.freehold,
    AppString.square785,
    AppString.parkMainRoad,
    AppString.feet60,
    AppString.vitrified,
    AppString.municipalCorporation,
    AppString.semiFurnished,
    AppString.west,
    AppString.propertyIdNumber,
  ].obs;

  RxList<String> furnishingDetailsImageList = [
    Assets.images.wardrobe.path,
    Assets.images.bedSheet.path,
    Assets.images.stove.path,
    Assets.images.waterPurifier.path,
    Assets.images.fan.path,
    Assets.images.lights.path,
  ].obs;

  RxList<String> furnishingDetailsTitleList = [
    AppString.wardrobe,
    AppString.sofa,
    AppString.stove,
    AppString.waterPurifier,
    AppString.fan,
    AppString.lights,
  ].obs;

  RxList<String> facilitiesImageList = [
    Assets.images.privateGarden.path,
    Assets.images.reservedParking.path,
    Assets.images.rainWater.path,
  ].obs;

  RxList<String> facilitiesTitleList = [
    AppString.privateGarden,
    AppString.reservedParking,
    AppString.rainWaterHarvesting,
  ].obs;

  RxList<String> dayList = [
    AppString.mondayText,
    AppString.tuesdayText,
    AppString.wednesdayText,
    AppString.thursdayText,
    AppString.fridayText,
    AppString.saturdayText,
    AppString.sundayText,
  ].obs;

  RxList<String> timingList = [
    AppString.timing1012,
    AppString.timing1012,
    AppString.timing1012,
    AppString.timing1012,
    AppString.timing1012,
    AppString.timing1012,
    AppString.close,
  ].obs;

  RxList<String> realEstateList = [
    AppString.yes,
    AppString.no,
  ].obs;

  RxList<String> reviewDateList = [
    AppString.november13,
    AppString.december13,
    AppString.may22,
  ].obs;

  RxList<String> reviewRatingImageList = [
    Assets.images.rating4.path,
    Assets.images.rating3.path,
    Assets.images.rating5.path,
  ].obs;

  RxList<String> reviewProfileList = [
    Assets.images.dh.path,
    Assets.images.da.path,
    Assets.images.mm.path,
  ].obs;

  RxList<String> reviewProfileNameList = [
    AppString.dorothyHowe,
    AppString.douglasAnderson,
    AppString.mamieMonahan,
  ].obs;

  RxList<String> reviewTypeList = [
    AppString.buyer,
    AppString.seller,
    AppString.seller,
  ].obs;

  RxList<String> reviewDescriptionList = [
    AppString.dorothyHoweString,
    AppString.douglasAndersonString,
    AppString.mamieMonahanString,
  ].obs;

  RxList<String> searchImageList = [
    Assets.images.alexaneFranecki.path,
    Assets.images.searchProperty5.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.alexane,
    AppString.happinessChasers,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.baumbachLakes,
    AppString.wildermanAddress,
  ].obs;

  RxList<String> searchRupeesList = [
    AppString.rupees58Lakh,
    AppString.crore1,
  ].obs;

  RxList<String> searchRatingList = [
    AppString.rating4Point5,
    AppString.rating4Point2,
  ].obs;

  RxList<String> similarPropertyTitleList = [
    AppString.point2,
    AppString.point1,
    AppString.squareMeter256,
  ].obs;

  RxList<String> interestingImageList = [
    Assets.images.read1.path,
    Assets.images.read2.path,
  ].obs;

  RxList<String> interestingTitleList = [
    AppString.readString1,
    AppString.readString2,
  ].obs;

  RxList<String> interestingDateList = [
    AppString.november23,
    AppString.october16,
  ].obs;

  RxList<String> propertyList = [
    AppString.overview,
    AppString.highlights,
    AppString.propertyDetails,
    AppString.photos,
    AppString.about,
    AppString.owner,
    AppString.articles,
  ].obs;

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    phoneNumberFocusNode.dispose();
    emailFocusNode.dispose();
    fullNameController.clear();
    mobileNumberController.clear();
    emailController.clear();
  }
}