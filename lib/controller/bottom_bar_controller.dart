import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class BottomBarController extends GetxController {
  RxInt selectIndex = 0.obs;
  late PageController pageController;

  BottomBarController({int initialIndex = 0}) {
    selectIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
  }

  void updateIndex(int index) {
    selectIndex.value = index;
    pageController.jumpToPage(index);
  }

  RxList<String> bottomBarImageList = [
    Assets.images.home.path,
    Assets.images.task.path,
    '',
    Assets.images.save.path,
    Assets.images.user.path,
  ].obs;

  RxList<String> bottomBarMenuNameList = [
    AppString.home,
    AppString.activity,
    '',
    AppString.saved,
    AppString.profile,
  ].obs;
}
