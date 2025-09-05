import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
changeAccountBottomSheet(BuildContext context) {
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
        height: AppSize.appSize211,
        padding: const EdgeInsets.only(
          top: AppSize.appSize26, bottom: AppSize.appSize26,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppString.changeAccountText,
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
                Text(
                  AppString.changeAccountTextString,
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ).paddingOnly(top: AppSize.appSize16),
              ],
            ),
            CommonButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.loginView);
              },
              backgroundColor: AppColor.primaryColor,
              child: Text(
                AppString.logout,
                style: AppStyle.heading5Medium(color: AppColor.whiteColor),
              ),
            ),
          ],
        ),
      );
    },
  );
}