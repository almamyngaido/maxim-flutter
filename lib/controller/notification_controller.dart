import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';

class NotificationController extends GetxController {
  RxList<String> notificationTitleList = [
    AppString.title1,
    AppString.title2,
    AppString.title3,
    AppString.title4,
    AppString.title5,
    AppString.title5,
    AppString.title6,
    AppString.title7,
    AppString.title8,
  ].obs;

  RxList<String> notificationSubTitleList = [
    AppString.subtitle1,
    AppString.subtitle1,
    AppString.subtitle3,
    AppString.subtitle4,
    AppString.subtitle5,
    AppString.subtitle6,
    AppString.subtitle7,
    AppString.subtitle8,
    AppString.subtitle9,
  ].obs;

  RxList<String> notificationTimingList = [
    AppString.hours2Ago,
    AppString.hours5Ago,
    AppString.yesterdayText,
    AppString.yesterdayText,
    AppString.yesterdayText,
    AppString.days2Ago,
    AppString.days3Ago,
    AppString.days3Ago,
    AppString.days3Ago,
  ].obs;
}