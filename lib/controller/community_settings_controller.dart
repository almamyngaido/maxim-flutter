import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';

class CommunitySettingsController extends GetxController {
  RxBool isSwitch1 = false.obs;
  RxBool isSwitch2 = false.obs;

  RxList<String> communitySettingsList = [
    AppString.receivePromotional,
    AppString.receivePushNotification,
  ].obs;
}