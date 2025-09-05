import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class GalleryController extends GetxController {
  RxList<String> hallImageList = [
    Assets.images.hall1.path,
    Assets.images.hall2.path,
    Assets.images.hall3.path,
  ].obs;

  RxList<String> kitchenImageList = [
    Assets.images.kitchen1.path,
    Assets.images.kitchen2.path,
    Assets.images.kitchen3.path,
  ].obs;

  RxList<String> bedroomImageList = [
    Assets.images.bedroom1.path,
    Assets.images.bedroom2.path,
  ].obs;
}