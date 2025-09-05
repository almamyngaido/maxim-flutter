import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';

class EditPropertyController extends GetxController {
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
}