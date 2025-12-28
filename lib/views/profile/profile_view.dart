import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bottom_bar_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/profile_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/translation_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/profile/widgets/delete_account_bottom_sheet.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/profile/widgets/finding_us_helpful_bottom_sheet.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/profile/widgets/logout_bottom_sheet.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});
  
 final ProfileController profileController = Get.put(ProfileController());
 final TranslationController translationController = Get.put(TranslationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildProfile(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      scrolledUnderElevation: AppSize.appSize0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        child: GestureDetector(
          onTap: () {
            BottomBarController bottomBarController = Get.put(BottomBarController());
            bottomBarController.pageController.jumpToPage(AppSize.size0);
          },
          child: Image.asset(
            Assets.images.backArrow.path,
          ),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Obx(() => Text(
        translationController.translate(AppString.profile),
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      )),
    );
  }

  Widget buildProfile() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  Assets.images.francisProfile.path,
                  width: AppSize.appSize68,
                ).paddingOnly(right: AppSize.appSize16),
                Obx(() => Text(
                  translationController.translate('${profileController.userData?['prenom'] ?? 'GUEST'} ${profileController.userData?['nom'] ?? 'GUEST'} '),
                  style: AppStyle.heading3Medium(color: AppColor.textColor),
                )),
              ],
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.editProfileView);
              },
              child: Obx(() => Text(
                translationController.translate(AppString.editProfile),
                style: AppStyle.heading5Medium(color: AppColor.primaryColor),
              )),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: AppSize.appSize36),
          itemCount: profileController.profileOptionImageList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                if(index == AppSize.size0) {
                  Get.toNamed(AppRoutes.responsesView);
                } else if(index == AppSize.size1) {
                  Get.toNamed(AppRoutes.languagesView);
                } else if(index == AppSize.size2) {
                  Get.toNamed(AppRoutes.communitySettingsView);
                } else if(index == AppSize.size3) {
                  Get.toNamed(AppRoutes.feedbackView);
                } else if(index == AppSize.size4) {
                  findingUsHelpfulBottomSheet(context);
                } else if(index == AppSize.size5) {
                  logoutBottomSheet(context);
                } else if(index == AppSize.size6) {
                  deleteAccountBottomSheet(context);
                }
              },
              child: Column(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        profileController.profileOptionImageList[index],
                        width: AppSize.appSize20,
                      ).paddingOnly(right: AppSize.appSize12),
                      Obx(() => Text(
                        translationController.translate(profileController.profileOptionTitleList[index]),
                        style: AppStyle.heading5Regular(color: AppColor.textColor),
                      )),
                    ],
                  ),
                  if(index < profileController.profileOptionImageList.length - AppSize.size1)...[
                    Divider(
                      color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                      height: AppSize.appSize0,
                      thickness: AppSize.appSizePoint7,
                    ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize26),
                  ],
                ],
              ),
            );
          },
        ),
      ],
      ),
    ).paddingOnly(
      top: AppSize.appSize10,
      left: AppSize.appSize16, right: AppSize.appSize16,
    );
  }
}
