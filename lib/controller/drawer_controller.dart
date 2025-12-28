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

  // Dynamic counts for activity section
  RxInt recentActivityCount = 0.obs;
  RxInt viewedPropertiesCount = 0.obs;
  RxInt savedPropertiesCount = 0.obs;
  RxInt contactedPropertiesCount = 0.obs;

  RxList<String> drawer3List = [
    AppString.homeScreen,
    AppString.agentsList,
  ].obs;

  RxList<String> drawer4List = [
    AppString.termsOfUse,
    AppString.shareFeedback,
    AppString.rateOurApp,
    AppString.logout,
  ].obs;

  /// Update activity counts with real data
  void updateActivityCounts({
    int? recentActivity,
    int? viewedProperties,
    int? savedProperties,
    int? contactedProperties,
  }) {
    if (recentActivity != null) recentActivityCount.value = recentActivity;
    if (viewedProperties != null) viewedPropertiesCount.value = viewedProperties;
    if (savedProperties != null) savedPropertiesCount.value = savedProperties;
    if (contactedProperties != null) contactedPropertiesCount.value = contactedProperties;
  }
}