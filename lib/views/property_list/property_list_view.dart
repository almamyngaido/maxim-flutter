import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_rich_text.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bottom_bar_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/property_list_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/text_segment_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/property_list/widget/filter_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class PropertyListView extends StatelessWidget {
  PropertyListView({super.key});

  final PropertyListController propertyListController =
      Get.put(PropertyListController());

  @override
  Widget build(BuildContext context) {
    propertyListController.isPropertyLiked.value = List<bool>.generate(
        propertyListController.searchImageList.length, (index) => false);
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildPropertyList(context),
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
            Get.back();
          },
          child: Image.asset(
            Assets.images.backArrow.path,
          ),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      actions: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
                Get.back();
                Future.delayed(
                  const Duration(milliseconds: AppSize.size400),
                  () {
                    BottomBarController bottomBarController =
                        Get.put(BottomBarController());
                    bottomBarController.pageController
                        .jumpToPage(AppSize.size3);
                  },
                );
              },
              child: Image.asset(
                Assets.images.save.path,
                width: AppSize.appSize24,
                color: AppColor.descriptionColor,
              ).paddingOnly(right: AppSize.appSize26),
            ),
            GestureDetector(
              onTap: () {
                SharePlus.instance.share(
                  ShareParams(
                    text: AppString.appName,
                  ),
                );
              },
              child: Image.asset(
                Assets.images.share.path,
                width: AppSize.appSize24,
              ),
            ),
          ],
        ).paddingOnly(right: AppSize.appSize16),
      ],
    );
  }

  Widget buildPropertyList(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              color: AppColor.whiteColor,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: AppSize.appSizePoint1,
                  blurRadius: AppSize.appSize2,
                ),
              ],
            ),
            child: TextFormField(
              controller: propertyListController.searchController,
              cursorColor: AppColor.primaryColor,
              style: AppStyle.heading4Regular(color: AppColor.textColor),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                  top: AppSize.appSize16,
                  bottom: AppSize.appSize16,
                ),
                hintText: AppString.searchPropertyText,
                hintStyle:
                    AppStyle.heading4Regular(color: AppColor.descriptionColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSize.appSize16,
                    right: AppSize.appSize16,
                  ),
                  child: Image.asset(
                    Assets.images.search.path,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  maxWidth: AppSize.appSize51,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(
                    left: AppSize.appSize16,
                    right: AppSize.appSize16,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      filterBottomSheet(context);
                    },
                    child: Image.asset(
                      Assets.images.filter.path,
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  maxWidth: AppSize.appSize51,
                ),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: propertyListController.searchImageList.length,
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
                            propertyListController.searchImageList[index],
                          ),
                          Positioned(
                            right: AppSize.appSize6,
                            top: AppSize.appSize6,
                            child: GestureDetector(
                              onTap: () {
                                propertyListController.isPropertyLiked[index] =
                                    !propertyListController
                                        .isPropertyLiked[index];
                              },
                              child: Container(
                                width: AppSize.appSize32,
                                height: AppSize.appSize32,
                                decoration: BoxDecoration(
                                  color: AppColor.whiteColor.withValues(
                                      alpha: AppSize.appSizePoint50),
                                  borderRadius:
                                      BorderRadius.circular(AppSize.appSize6),
                                ),
                                child: Center(
                                  child: Obx(() => Image.asset(
                                        propertyListController
                                                .isPropertyLiked[index]
                                            ? Assets.images.saved.path
                                            : Assets.images.save.path,
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
                            style: AppStyle.heading6Regular(
                                color: AppColor.primaryColor),
                          ),
                          Text(
                            propertyListController.searchTitleList[index],
                            style: AppStyle.heading5SemiBold(
                                color: AppColor.textColor),
                          ).paddingOnly(top: AppSize.appSize6),
                          Text(
                            propertyListController.searchAddressList[index],
                            style: AppStyle.heading5Regular(
                                color: AppColor.descriptionColor),
                          ).paddingOnly(top: AppSize.appSize6),
                        ],
                      ).paddingOnly(top: AppSize.appSize16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            propertyListController.searchRupeesList[index],
                            style: AppStyle.heading5Medium(
                                color: AppColor.primaryColor),
                          ),
                          Row(
                            children: [
                              Text(
                                propertyListController.searchRatingList[index],
                                style: AppStyle.heading5Medium(
                                    color: AppColor.primaryColor),
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
                        color: AppColor.descriptionColor
                            .withValues(alpha: AppSize.appSizePoint3),
                        height: AppSize.appSize0,
                      ).paddingOnly(
                          top: AppSize.appSize16, bottom: AppSize.appSize16),
                      Row(
                        children: List.generate(
                            propertyListController
                                .searchPropertyTitleList.length, (index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSize.appSize6,
                              horizontal: AppSize.appSize14,
                            ),
                            margin:
                                const EdgeInsets.only(right: AppSize.appSize16),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppSize.appSize12),
                              border: Border.all(
                                color: AppColor.primaryColor,
                                width: AppSize.appSizePoint50,
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  propertyListController
                                      .searchPropertyImageList[index],
                                  width: AppSize.appSize18,
                                  height: AppSize.appSize18,
                                ).paddingOnly(right: AppSize.appSize6),
                                Text(
                                  propertyListController
                                      .searchPropertyTitleList[index],
                                  style: AppStyle.heading5Medium(
                                      color: AppColor.textColor),
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
                                  text: propertyListController
                                      .searchSquareFeetList[index],
                                  style: AppStyle.heading5Regular(
                                      color: AppColor.textColor),
                                ),
                                TextSegment(
                                  text: AppString.builtUp,
                                  style: AppStyle.heading7Regular(
                                      color: AppColor.descriptionColor),
                                ),
                              ],
                            ),
                            const VerticalDivider(
                              color: AppColor.descriptionColor,
                              width: AppSize.appSize0,
                              indent: AppSize.appSize2,
                              endIndent: AppSize.appSize2,
                            ).paddingOnly(
                                left: AppSize.appSize8,
                                right: AppSize.appSize8),
                            CommonRichText(
                              segments: [
                                TextSegment(
                                  text: propertyListController
                                      .searchSquareFeet2List[index],
                                  style: AppStyle.heading5Regular(
                                      color: AppColor.textColor),
                                ),
                                TextSegment(
                                  text: AppString.builtUp,
                                  style: AppStyle.heading7Regular(
                                      color: AppColor.descriptionColor),
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
                            propertyListController.launchDialer();
                          },
                          style: ButtonStyle(
                            elevation:
                                const WidgetStatePropertyAll(AppSize.appSize0),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppSize.appSize12),
                                side: const BorderSide(
                                    color: AppColor.primaryColor,
                                    width: AppSize.appSizePoint7),
                              ),
                            ),
                            backgroundColor: WidgetStateColor.transparent,
                          ),
                          child: Text(
                            AppString.getCallbackButton,
                            style: AppStyle.heading6Regular(
                                color: AppColor.primaryColor),
                          ),
                        ),
                      ).paddingOnly(top: AppSize.appSize26),
                    ],
                  ),
                ),
              );
            },
          ).paddingOnly(top: AppSize.appSize16),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
    );
  }
}
