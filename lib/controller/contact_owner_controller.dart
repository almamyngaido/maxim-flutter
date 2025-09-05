import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactOwnerController extends GetxController {
  RxList<bool> isSimilarPropertyLiked = <bool>[].obs;

  void launchDialer() async {
    final Uri phoneNumber = Uri(scheme: 'tel', path: '9995958748');
    if (await canLaunchUrl(phoneNumber)) {
      await launchUrl(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  RxList<String> searchImageList = [
    Assets.images.similarProperty1.path,
    Assets.images.similarProperty2.path,
  ].obs;

  RxList<String> searchTitleList = [
    AppString.gokulTulip,
    AppString.jayDhiaan,
  ].obs;

  RxList<String> searchAddressList = [
    AppString.connellStreet,
    AppString.villaCharlebourg,
  ].obs;

  RxList<String> searchPropertyImageList = [
    Assets.images.bath.path,
    Assets.images.bed.path,
    Assets.images.plot.path,
  ].obs;

  RxList<String> similarPropertyTitleList = [
    AppString.point2,
    AppString.point2,
    AppString.squareMeter2000,
  ].obs;
}