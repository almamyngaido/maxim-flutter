import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/user_utils.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class BottomBarController extends GetxController {
  RxInt selectIndex = 0.obs;
  late PageController pageController;
  RxBool isAdmin = false.obs;

  BottomBarController({int initialIndex = 0}) {
    selectIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
    checkAdminStatus();
  }

  void checkAdminStatus() {
    final userData = loadUserData();
    if (userData != null) {
      final role = userData['role'] ?? 'user';
      isAdmin.value = role.toLowerCase() == 'admin';
      print('🔐 User role: $role, isAdmin: ${isAdmin.value}');
    }
  }

  void updateIndex(int index) {
    selectIndex.value = index;
    pageController.jumpToPage(index);
  }

  // Méthode pour obtenir la liste des icônes selon le rôle
  List<String> get bottomBarImageList {
    if (isAdmin.value) {
      return [
        Assets.images.home.path,
        Assets.images.task.path,
        '',
        Assets.images.save.path,
        Assets.images.user.path,
        'admin', // Icône spéciale pour admin
      ];
    } else {
      return [
        Assets.images.home.path,
        Assets.images.task.path,
        '',
        Assets.images.save.path,
        Assets.images.user.path,
      ];
    }
  }

  // Méthode pour obtenir la liste des noms selon le rôle
  List<String> get bottomBarMenuNameList {
    if (isAdmin.value) {
      return [
        AppString.home,
        AppString.activity,
        '',
        AppString.saved,
        AppString.profile,
        'Admin',
      ];
    } else {
      return [
        AppString.home,
        AppString.activity,
        '',
        AppString.saved,
        AppString.profile,
      ];
    }
  }
}
