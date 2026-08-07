import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/about_property_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class AboutPropertyView extends StatelessWidget {
  AboutPropertyView({super.key});

  final AboutPropertyController aboutPropertyController = Get.put(AboutPropertyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: buildAboutProperty(),
      bottomNavigationBar: buildButton(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: AppSize.appSize0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        child: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Image.asset(
            Assets.images.backArrow.path,
          ),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Text(
        AppString.aboutProperty,
        style: AppStyle.heading4Medium(color: DiwaneColors.textPrimary),
      ),
    );
  }

  Widget buildAboutProperty() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSize.appSize10),
            decoration: BoxDecoration(
              border: Border.all(
                color: DiwaneColors.textMuted
                    .withValues(alpha: AppSize.appSizePoint50),
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.semiModernHouse,
                  style: AppStyle.heading5SemiBold(color: DiwaneColors.textPrimary),
                ).paddingOnly(bottom: AppSize.appSize8),
                Row(
                  children: [
                    Image.asset(
                      Assets.images.locationPin.path,
                      width: AppSize.appSize18,
                    ).paddingOnly(right: AppSize.appSize6),
                    Expanded(
                      child: Text(
                        AppString.address6,
                        style: AppStyle.heading5Regular(
                            color: DiwaneColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color:
            DiwaneColors.textMuted.withValues(alpha: AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSize0,
          ).paddingOnly(
            top: AppSize.appSize16,
            bottom: AppSize.appSize16,
          ),
          Text(
            AppString.aboutPropertyString1,
            style: AppStyle.heading5Regular(color: DiwaneColors.textMuted),
          ),
          Text(
            AppString.aboutPropertyString2,
            style: AppStyle.heading5Regular(color: DiwaneColors.textMuted),
          ).paddingOnly(top: AppSize.appSize20),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16, right: AppSize.appSize16,
      ),
    );
  }

  Widget buildButton() {
    return CommonButton(
      onPressed: () {
        aboutPropertyController.launchDialer();
      },
      backgroundColor: DiwaneColors.navy,
      child: Text(
        AppString.callOwnerButton,
        style: AppStyle.heading5Medium(color: Colors.white),
      ),
    ).paddingOnly(
        left: AppSize.appSize16, right: AppSize.appSize16,
        bottom: AppSize.appSize26
    );
  }
}
