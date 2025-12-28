import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_rich_text.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/user_utils.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bottom_bar_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/drawer_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/favoris_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/messaging_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/viewed_properties_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/text_segment_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/profile/widgets/finding_us_helpful_bottom_sheet.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/profile/widgets/logout_bottom_sheet.dart';

class DrawerView extends StatelessWidget {
  DrawerView({super.key});

  final SlideDrawerController drawerController =
      Get.put(SlideDrawerController());

  @override
  Widget build(BuildContext context) {
    return buildDrawer();
  }

  Widget buildDrawer() {
    // Load user data dynamically
    final userData = loadUserData();
    final userName = userData != null
        ? '${userData['prenom'] ?? ''} ${userData['nom'] ?? ''}'.trim()
        : 'Utilisateur';
    final userRole = userData?['role']?.toString() ?? 'user';

    // Get first letter for avatar
    final firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    // Load dynamic activity counts
    _loadActivityCounts();

    return Drawer(
      backgroundColor: AppColor.whiteColor,
      width: AppSize.appSize285,
      elevation: AppSize.appSize0,
      shape: const OutlineInputBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppSize.appSize12),
          bottomRight: Radius.circular(AppSize.appSize12),
        ),
        borderSide: BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Dynamic profile avatar with first letter
              CircleAvatar(
                radius: AppSize.appSize22,
                backgroundColor: AppColor.primaryColor,
                child: Text(
                  firstLetter,
                  style: AppStyle.heading3Medium(color: AppColor.whiteColor),
                ),
              ).paddingOnly(right: AppSize.appSize14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic user name
                    Text(
                      userName,
                      style: AppStyle.heading3Medium(color: AppColor.textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Dynamic role and profile link
                    CommonRichText(
                      segments: [
                        TextSegment(
                          text: _getRoleDisplayName(userRole),
                          style: AppStyle.heading6Regular(
                              color: AppColor.descriptionColor),
                        ),
                        TextSegment(
                          text: ' | ',
                          style: AppStyle.heading6Regular(
                              color: AppColor.descriptionColor),
                        ),
                        TextSegment(
                          text: "Voir profil",
                          style: AppStyle.heading6Regular(
                              color: AppColor.primaryColor),
                          onTap: () {
                            Get.back();
                            Get.toNamed(AppRoutes.editProfileView);
                          },
                        ),
                      ],
                    ).paddingOnly(top: AppSize.appSize4),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Image.asset(
                  Assets.images.close.path,
                  width: AppSize.appSize24,
                  height: AppSize.appSize24,
                ),
              )
            ],
          ).paddingOnly(
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Divider(
            color: AppColor.descriptionColor
                .withValues(alpha: AppSize.appSizePoint3),
            height: AppSize.appSize0,
            thickness: AppSize.appSizePoint7,
          ).paddingOnly(top: AppSize.appSize26),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(
                top: AppSize.appSize36,
                bottom: AppSize.appSize10,
              ),
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: AppSize.appSize16),
                  itemCount: drawerController.drawerList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (index == AppSize.size0) {
                          Get.back();
                          Get.toNamed(AppRoutes.notificationView);
                        } else if (index == AppSize.size1) {
                          Get.back();
                          Get.toNamed(AppRoutes.searchView);
                        } else if (index == AppSize.size2) {
                          Get.back();
                          Get.toNamed(AppRoutes.postPropertyView);
                        } else if (index == AppSize.size3) {
                          Get.back();
                          BottomBarController bottomBarController =
                              Get.put(BottomBarController());
                          bottomBarController.pageController
                              .jumpToPage(AppSize.size1);
                        } else if (index == AppSize.size4) {
                          Get.back();
                          Get.toNamed(AppRoutes.responsesView);
                        }
                      },
                      child: Text(
                        drawerController.drawerList[index],
                        style:
                            AppStyle.heading5Medium(color: AppColor.textColor),
                      ).paddingOnly(bottom: AppSize.appSize26),
                    );
                  },
                ),
                Text(
                  AppString.yourPropertySearch,
                  style: AppStyle.heading6Bold(color: AppColor.primaryColor),
                ).paddingOnly(top: AppSize.appSize10, left: AppSize.appSize16),
                Divider(
                  color: AppColor.primaryColor
                      .withValues(alpha: AppSize.appSizePoint50),
                  height: AppSize.appSize0,
                  thickness: AppSize.appSizePoint7,
                ).paddingOnly(
                    top: AppSize.appSize16, bottom: AppSize.appSize16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                      top: AppSize.appSize10,
                      left: AppSize.appSize16,
                      right: AppSize.appSize16),
                  itemCount: drawerController.drawer2List.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (index == AppSize.size0) {
                          Get.back();
                          Get.toNamed(AppRoutes.recentActivityView);
                        } else if (index == AppSize.size1) {
                          Get.back();
                          Get.toNamed(AppRoutes.viewedPropertyView);
                        } else if (index == AppSize.size2) {
                          Get.back();
                          BottomBarController bottomBarController =
                              Get.put(BottomBarController());
                          bottomBarController.pageController
                              .jumpToPage(AppSize.size3);
                        } else if (index == AppSize.size3) {
                          Get.back();
                          Get.toNamed(AppRoutes.contactPropertyView);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            drawerController.drawer2List[index],
                            style: AppStyle.heading5Medium(
                                color: AppColor.textColor),
                          ),
                          Obx(() => Text(
                                _getActivityCount(index),
                                style: AppStyle.heading5Medium(
                                    color: AppColor.primaryColor),
                              ))
                        ],
                      ).paddingOnly(bottom: AppSize.appSize26),
                    );
                  },
                ),
                Divider(
                  color: AppColor.primaryColor
                      .withValues(alpha: AppSize.appSizePoint50),
                  height: AppSize.appSize0,
                  thickness: AppSize.appSizePoint7,
                ).paddingOnly(
                    top: AppSize.appSize10, bottom: AppSize.appSize36),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(left: AppSize.appSize16),
                  itemCount: drawerController.drawer3List.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (index == AppSize.size0) {
                          Get.back();
                        } else if (index == AppSize.size1) {
                          Get.back();
                          Get.toNamed(AppRoutes.agentsListView);
                        }
                      },
                      child: Text(
                        drawerController.drawer3List[index],
                        style:
                            AppStyle.heading5Medium(color: AppColor.textColor),
                      ).paddingOnly(bottom: AppSize.appSize26),
                    );
                  },
                ),
                Text(
                  AppString.exploreProperties,
                  style: AppStyle.heading6Bold(color: AppColor.primaryColor),
                ).paddingOnly(top: AppSize.appSize10, left: AppSize.appSize16),
                Divider(
                  color: AppColor.primaryColor
                      .withValues(alpha: AppSize.appSizePoint50),
                  height: AppSize.appSize0,
                  thickness: AppSize.appSizePoint7,
                ).paddingOnly(
                    top: AppSize.appSize16, bottom: AppSize.appSize20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Get.back();
                          Get.toNamed(AppRoutes.searchView);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSize.appSize16),
                          decoration: BoxDecoration(
                            color: AppColor.secondaryColor,
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize6),
                          ),
                          child: Column(
                            children: [
                              Center(
                                child: Image.asset(
                                  Assets.images.residential.path,
                                  width: AppSize.appSize20,
                                ),
                              ),
                              Center(
                                child: Text(
                                  AppString.residentialProperties,
                                  textAlign: TextAlign.center,
                                  style: AppStyle.heading5Medium(
                                      color: AppColor.textColor),
                                ),
                              ).paddingOnly(top: AppSize.appSize6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.appSize6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(AppSize.appSize16),
                        decoration: BoxDecoration(
                          color: AppColor.secondaryColor,
                          borderRadius: BorderRadius.circular(AppSize.appSize6),
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Image.asset(
                                Assets.images.buildings.path,
                                width: AppSize.appSize20,
                              ),
                            ),
                            Center(
                              child: Text(
                                AppString.commercialProperties,
                                textAlign: TextAlign.center,
                                style: AppStyle.heading5Medium(
                                    color: AppColor.textColor),
                              ),
                            ).paddingOnly(top: AppSize.appSize6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).paddingOnly(
                    left: AppSize.appSize16, right: AppSize.appSize16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: AppSize.appSize16,
                    top: AppSize.appSize36,
                  ),
                  itemCount: drawerController.drawer4List.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (index == AppSize.size0) {
                          Get.back();
                          Get.toNamed(AppRoutes.termsOfUseView);
                        } else if (index == AppSize.size1) {
                          Get.back();
                          Get.toNamed(AppRoutes.feedbackView);
                        } else if (index == AppSize.size2) {
                          Get.back();
                          findingUsHelpfulBottomSheet(context);
                        } else if (index == AppSize.size3) {
                          Get.back();
                          logoutBottomSheet(context);
                        }
                      },
                      child: Text(
                        drawerController.drawer4List[index],
                        style:
                            AppStyle.heading5Medium(color: AppColor.textColor),
                      ).paddingOnly(bottom: AppSize.appSize26),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ).paddingOnly(top: AppSize.appSize60),
    );
  }

  /// Get display name for user role in French
  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrateur';
      case 'agent':
        return 'Agent immobilier';
      case 'user':
        return 'Utilisateur';
      default:
        return 'Utilisateur';
    }
  }

  /// Load dynamic activity counts from various controllers
  void _loadActivityCounts() {
    try {
      // Get messaging controller for conversations count
      final messagingController = Get.isRegistered<MessagingController>()
          ? Get.find<MessagingController>()
          : Get.put(MessagingController());

      // Get favoris controller for saved properties count
      final favorisController = Get.isRegistered<FavorisController>()
          ? Get.find<FavorisController>()
          : Get.put(FavorisController());

      // Get viewed properties service for viewed count
      final viewedPropertiesService =
          Get.isRegistered<ViewedPropertiesService>()
              ? Get.find<ViewedPropertiesService>()
              : Get.put(ViewedPropertiesService());

      // Update counts
      drawerController.updateActivityCounts(
        recentActivity: messagingController.conversations.length,
        viewedProperties: viewedPropertiesService.getViewedPropertiesCount(),
        savedProperties: favorisController.favoris.length,
        contactedProperties: messagingController.conversations
            .where((conv) => conv.otherParticipant != null)
            .length,
      );
    } catch (e) {
      print('Error loading activity counts: $e');
    }
  }

  /// Get the dynamic count for each activity item
  String _getActivityCount(int index) {
    switch (index) {
      case 0: // Recent Activity
        return drawerController.recentActivityCount.value.toString();
      case 1: // Viewed Properties
        return drawerController.viewedPropertiesCount.value.toString();
      case 2: // Saved Properties
        return drawerController.savedPropertiesCount.value.toString();
      case 3: // Contacted Properties
        return drawerController.contactedPropertiesCount.value.toString();
      default:
        return '0';
    }
  }
}
