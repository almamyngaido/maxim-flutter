import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/profile_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
findingUsHelpfulBottomSheet(BuildContext context) {
  ProfileController profileController = Get.put(ProfileController());
  return showModalBottomSheet(
    backgroundColor: Colors.transparent,
    shape: const OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSize.appSize12),
        topRight: Radius.circular(AppSize.appSize12),
      ),
      borderSide: BorderSide.none,
    ),
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (context) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: AppSize.appSize190,
        padding: const EdgeInsets.only(
          top: AppSize.appSize26, bottom: AppSize.appSize20,
          left: AppSize.appSize16, right: AppSize.appSize16,
        ),
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSize.appSize12),
            topRight: Radius.circular(AppSize.appSize12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppString.areYouFindingUsHelpful,
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Image.asset(
                    Assets.images.close.path,
                    width: AppSize.appSize24,
                  ),
                ),
              ],
            ),
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(profileController.findingUsImageList.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      profileController.updateEmoji(index);
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: profileController.selectEmoji.value == index
                              ? AppColor.primaryColor
                              : AppColor.backgroundColor,
                          radius: AppSize.appSize36,
                          child: CircleAvatar(
                            backgroundColor: profileController.selectEmoji.value == index
                                ? AppColor.primaryColor
                                : AppColor.backgroundColor,
                            backgroundImage: AssetImage(
                              profileController.findingUsImageList[index],
                            ),
                            radius: AppSize.appSize15,
                          ),
                        ),
                        Text(
                          profileController.findingUsTitleList[index],
                          style: AppStyle.heading5Regular(color: AppColor.textColor),
                        ).paddingOnly(top: AppSize.appSize6),
                      ],
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      );
    },
  );
}