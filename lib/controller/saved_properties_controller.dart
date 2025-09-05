import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:url_launcher/url_launcher.dart';

class SavedPropertiesController extends GetxController {
  RxInt selectSavedProperty = 0.obs;

  RxList<bool> isSimilarPropertyLiked = <bool>[].obs;

  void updateSavedProperty(int index) {
    selectSavedProperty.value = index;
  }

  void launchDialer() async {
    final Uri phoneNumber = Uri(scheme: 'tel', path: '9995958748');
    if (await canLaunchUrl(phoneNumber)) {
      await launchUrl(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  RxList<String> savedPropertyList = [
    AppString.properties3,
    AppString.project,
    AppString.localities,
  ].obs;

  RxList<String> searchImageList = [
    Assets.images.searchProperty1.path,
    Assets.images.savedProperty1.path,
    Assets.images.savedProperty2.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.semiModernHouse,
    AppString.vijayVRX,
    AppString.yashasviSiddhi,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.address6,
    AppString.templeSquare,
    AppString.schinnerVillage,
  ].obs;

  RxList<String> searchRupeesList = [
    AppString.rupees58Lakh,
    AppString.rupees58Lakh,
    AppString.rupee65Lakh,
  ].obs;

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
}