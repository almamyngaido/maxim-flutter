import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';

class DeleteListingController extends GetxController {
  RxInt selectListing = 0.obs;

  void updateListing(int index) {
    selectListing.value = index;
  }

  RxList<String> listingList = [
    AppString.deleteListing1,
    AppString.deleteListing2,
    AppString.deleteListing3,
    AppString.deleteListing4,
    AppString.deleteListing5,
    AppString.deleteListing6,
  ].obs;
}