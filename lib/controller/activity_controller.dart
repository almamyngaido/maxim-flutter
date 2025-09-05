import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class ActivityController extends GetxController {
  TextEditingController searchListController = TextEditingController();

  RxInt selectListing = 0.obs;
  RxInt selectSorting = 0.obs;
  RxBool deleteShowing = false.obs;

  void updateListing(int index) {
    selectListing.value = index;
  }

  void updateSorting(int index) {
    selectSorting.value = index;
  }

  RxList<String> listingStatesList = [
    AppString.active,
    AppString.expired,
    AppString.deleted,
    AppString.underScreening,
  ].obs;

  RxList<String> sortListingList = [
    AppString.newestFirst,
    AppString.oldestFirst,
    AppString.expiringFirst,
    AppString.expiringLast,
  ].obs;

  RxList<String> propertyListImage = [
    Assets.images.listing1.path,
    Assets.images.listing2.path,
    Assets.images.listing3.path,
    Assets.images.listing4.path,
  ].obs;

  RxList<String> propertyListRupee = [
    AppString.rupee50Lac,
    AppString.rupee50Lac,
    AppString.rupee45Lac,
    AppString.rupee45Lac,
  ].obs;

  RxList<String> propertyListTitle = [
    AppString.sellFlat,
    AppString.sellIndependentHouse,
    AppString.successClub,
    AppString.theWriteClub,
  ].obs;

  RxList<String> propertyListAddress = [
    AppString.northBombaySociety,
    AppString.roslynWalks,
    AppString.akshyaNagar,
    AppString.rammurthyNagar,
  ].obs;

  @override
  void dispose() {
    super.dispose();
    searchListController.clear();
  }
}