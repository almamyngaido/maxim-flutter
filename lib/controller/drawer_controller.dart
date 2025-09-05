import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';

class SlideDrawerController extends GetxController {
  RxList<String> drawerList = [
    AppString.notification,
    AppString.searchProperty,
    AppString.postProperty,
    AppString.editProperty,
    AppString.viewResponses,
  ].obs;

  RxList<String> drawer2List = [
    AppString.recentActivity,
    AppString.viewedProperties,
    AppString.savedProperties,
    AppString.contactedProperties,
  ].obs;

  RxList<String> searchPropertyNumberList = [
    AppString.number35,
    AppString.number25,
    AppString.number3,
    AppString.number10,
  ].obs;

  RxList<String> drawer3List = [
    AppString.homeScreen,
    AppString.agentsList,
    AppString.interestingReads,
  ].obs;

  RxList<String> drawer4List = [
    AppString.termsOfUse,
    AppString.shareFeedback,
    AppString.rateOurApp,
    AppString.logout,
  ].obs;
}