import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_rich_text.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bottom_bar_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/saved_properties_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/text_segment_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class SavedPropertiesView extends StatelessWidget {
  SavedPropertiesView({super.key});

  final SavedPropertiesController savedPropertiesController = Get.put(SavedPropertiesController());

  @override
  Widget build(BuildContext context) {
    savedPropertiesController.isSimilarPropertyLiked.value = List<bool>.generate(
        savedPropertiesController.searchImageList.length, (index) => false);
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildSavedPropertyList(),
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
      title: Text(
        AppString.savedProperties,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(AppSize.appSize40),
        child: SizedBox(
          height: AppSize.appSize40,
          child: Row(
            children: List.generate(savedPropertiesController.savedPropertyList.length, (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    savedPropertiesController.updateSavedProperty(index);
                  },
                  child: Obx(() => Container(
                    height: AppSize.appSize25,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: savedPropertiesController.selectSavedProperty.value == index
                              ? AppColor.primaryColor
                              : AppColor.borderColor,
                          width: AppSize.appSize1,
                        ),
                        right: BorderSide(
                          color: index == AppSize.size2
                              ? Colors.transparent
                              : AppColor.borderColor,
                          width: AppSize.appSize1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        savedPropertiesController.savedPropertyList[index],
                        style: AppStyle.heading5Medium(
                          color: savedPropertiesController.selectSavedProperty.value == index
                              ? AppColor.primaryColor
                              : AppColor.textColor,
                        ),
                      ),
                    ),
                  )),
                ),
              );
            }),
          ).paddingOnly(
            top: AppSize.appSize10,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
        ),
      ),
    );
  }

  Widget buildSavedPropertyList() {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(
        bottom: AppSize.appSize20, top: AppSize.appSize10,
      ),
      physics: const ClampingScrollPhysics(),
      itemCount: savedPropertiesController.searchImageList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Get.toNamed(AppRoutes.propertyDetailsView);
          },
          child: Container(
            padding: const EdgeInsets.all(AppSize.appSize10),
            margin: const EdgeInsets.only(bottom: AppSize.appSize16),
            decoration: BoxDecoration(
              color: AppColor.secondaryColor,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      savedPropertiesController.searchImageList[index],
                    ),
                    Positioned(
                      right: AppSize.appSize6,
                      top: AppSize.appSize6,
                      child: GestureDetector(
                        onTap: () {
                          savedPropertiesController.isSimilarPropertyLiked[index] =
                          !savedPropertiesController.isSimilarPropertyLiked[index];
                        },
                        child: Container(
                          width: AppSize.appSize32,
                          height: AppSize.appSize32,
                          decoration: BoxDecoration(
                            color: AppColor.whiteColor.withValues(alpha:AppSize.appSizePoint50),
                            borderRadius: BorderRadius.circular(AppSize.appSize6),
                          ),
                          child: Center(
                            child: Obx(() => Image.asset(
                              savedPropertiesController.isSimilarPropertyLiked[index]
                                  ? Assets.images.save.path
                                  : Assets.images.saved.path,
                              width: AppSize.appSize24,
                            )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppString.completedProjects,
                      style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                    ),
                    Text(
                      savedPropertiesController.searchTitleList[index],
                      style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                    ).paddingOnly(top: AppSize.appSize6),
                    Text(
                      savedPropertiesController.searchAddressList[index],
                      style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                    ).paddingOnly(top: AppSize.appSize6),
                  ],
                ).paddingOnly(top: AppSize.appSize16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      savedPropertiesController.searchRupeesList[index],
                      style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                    ),
                    Row(
                      children: [
                        Text(
                          AppString.rating4Point5,
                          style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                        ).paddingOnly(right: AppSize.appSize6),
                        Image.asset(
                          Assets.images.star.path,
                          width: AppSize.appSize18,
                        ),
                      ],
                    ),
                  ],
                ).paddingOnly(top: AppSize.appSize16),
                Divider(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint3),
                  height: AppSize.appSize0,
                ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize16),
                Row(
                  children: List.generate(savedPropertiesController.searchPropertyTitleList.length, (index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSize.appSize6, horizontal: AppSize.appSize14,
                      ),
                      margin: const EdgeInsets.only(right: AppSize.appSize16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: AppColor.primaryColor,
                          width: AppSize.appSizePoint50,
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            savedPropertiesController.searchPropertyImageList[index],
                            width: AppSize.appSize18,
                            height: AppSize.appSize18,
                          ).paddingOnly(right: AppSize.appSize6),
                          Text(
                            savedPropertiesController.searchPropertyTitleList[index],
                            style: AppStyle.heading5Medium(color: AppColor.textColor),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      CommonRichText(
                        segments: [
                          TextSegment(
                            text: AppString.squareFeet966,
                            style: AppStyle.heading5Regular(color: AppColor.textColor),
                          ),
                          TextSegment(
                            text: AppString.builtUp,
                            style: AppStyle.heading7Regular(color: AppColor.descriptionColor),
                          ),
                        ],
                      ),
                      const VerticalDivider(
                        color: AppColor.descriptionColor,
                        width: AppSize.appSize0,
                        indent: AppSize.appSize2,
                        endIndent: AppSize.appSize2,
                      ).paddingOnly(left: AppSize.appSize8, right: AppSize.appSize8),
                      CommonRichText(
                        segments: [
                          TextSegment(
                            text: AppString.squareFeet773,
                            style: AppStyle.heading5Regular(color: AppColor.textColor),
                          ),
                          TextSegment(
                            text: AppString.builtUp,
                            style: AppStyle.heading7Regular(color: AppColor.descriptionColor),
                          ),
                        ],
                      ),
                    ],
                  ).paddingOnly(top: AppSize.appSize10),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: AppSize.appSize35,
                  child: ElevatedButton(
                    onPressed: () {
                      savedPropertiesController.launchDialer();
                    },
                    style: ButtonStyle(
                      elevation: const WidgetStatePropertyAll(AppSize.appSize0),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSize.appSize12),
                          side: const BorderSide(
                              color: AppColor.primaryColor,
                              width: AppSize.appSizePoint7
                          ),
                        ),
                      ),
                      backgroundColor: WidgetStateColor.transparent,
                    ),
                    child: Text(
                      AppString.getCallbackButton,
                      style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                    ),
                  ),
                ).paddingOnly(top: AppSize.appSize26),
              ],
            ),
          ),
        );
      },
    ).paddingOnly(
      left: AppSize.appSize16, right: AppSize.appSize16,
    );
  }
}
