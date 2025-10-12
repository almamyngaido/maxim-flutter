import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bottom_bar_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/activity/activity_view.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/admin/admin_tabs_view.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/drawer/drawer_view.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/home/home_view.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/profile/profile_view.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/saved/saved_properties_view.dart';

class BottomBarView extends StatefulWidget {
  final int initialIndex;
  const BottomBarView({super.key, this.initialIndex = 0});

  @override
  State<BottomBarView> createState() => _BottomBarViewState();
}

class _BottomBarViewState extends State<BottomBarView> {
  late final BottomBarController bottomBarController;

  @override
  void initState() {
    super.initState();
    bottomBarController = Get.put(
      BottomBarController(initialIndex: widget.initialIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      drawer: DrawerView(),
      body: buildPageView(),
      bottomNavigationBar: buildBottomNavBar(context),
    );
  }

  Widget buildPageView() {
    return Obx(() {
      final children = <Widget>[
        HomeView(),
        ActivityView(),
        Container(),
        SavedPropertiesView(),
        ProfileView(),
      ];

      // Ajouter la page admin si l'utilisateur est admin
      if (bottomBarController.isAdmin.value) {
        children.add(AdminTabsView());
      }

      return PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: bottomBarController.pageController,
        onPageChanged: (int index) {
          bottomBarController.updateIndex(index);
        },
        children: children,
      );
    });
  }

  Widget buildBottomNavBar(BuildContext context) {
    return Obx(() {
      final imageList = bottomBarController.bottomBarImageList;
      final menuList = bottomBarController.bottomBarMenuNameList;

      return Container(
        height: AppSize.appSize72,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              spreadRadius: AppSize.appSize1,
              blurRadius: AppSize.appSize3,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(imageList.length, (index) {
            final imagePath = imageList[index];

            // Bouton "Add" au milieu
            if (imagePath == '') {
              return GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.postPropertyView);
                },
                child: Image.asset(
                  Assets.images.add.path,
                  width: AppSize.appSize40,
                  height: AppSize.appSize40,
                ),
              );
            }
            // Bouton Admin spécial
            else if (imagePath == 'admin') {
              return GestureDetector(
                onTap: () {
                  bottomBarController.updateIndex(index);
                },
                child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSize.appSize8,
                        horizontal: AppSize.appSize12,
                      ),
                      decoration: BoxDecoration(
                        color: bottomBarController.selectIndex.value == index
                            ? AppColor.primaryColor
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppSize.appSize100),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            size: AppSize.appSize20,
                            color:
                                bottomBarController.selectIndex.value == index
                                    ? AppColor.whiteColor
                                    : AppColor.textColor,
                          ).paddingOnly(
                            right:
                                bottomBarController.selectIndex.value == index
                                    ? AppSize.appSize6
                                    : AppSize.appSize0,
                          ),
                          bottomBarController.selectIndex.value == index
                              ? Text(
                                  menuList[index],
                                  style: AppStyle.heading6Medium(
                                      color: AppColor.whiteColor),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    )),
              );
            }
            // Boutons normaux
            else {
              return GestureDetector(
                onTap: () {
                  bottomBarController.updateIndex(index);
                },
                child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSize.appSize8,
                        horizontal: AppSize.appSize12,
                      ),
                      decoration: BoxDecoration(
                        color: bottomBarController.selectIndex.value == index
                            ? AppColor.primaryColor
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(AppSize.appSize100),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            imagePath,
                            width: AppSize.appSize20,
                            height: AppSize.appSize20,
                            color:
                                bottomBarController.selectIndex.value == index
                                    ? AppColor.whiteColor
                                    : AppColor.textColor,
                          ).paddingOnly(
                            right:
                                bottomBarController.selectIndex.value == index
                                    ? AppSize.appSize6
                                    : AppSize.appSize0,
                          ),
                          bottomBarController.selectIndex.value == index
                              ? Text(
                                  menuList[index],
                                  style: AppStyle.heading6Medium(
                                      color: AppColor.whiteColor),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    )),
              );
            }
          }),
        ),
      );
    });
  }
}
