import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_rich_text.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_textfield.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bottom_bar_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/owner_country_picker_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/property_details_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/text_segment_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/property_list/widget/owner_country_picker_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

class PropertyDetailsView extends StatelessWidget {
  PropertyDetailsView({super.key});

  final PropertyDetailsController propertyDetailsController =
      Get.put(PropertyDetailsController());
  final OwnerCountryPickerController ownerCountryPickerController =
      Get.put(OwnerCountryPickerController());

  @override
  Widget build(BuildContext context) {
    propertyDetailsController.isSimilarPropertyLiked.value =
        List<bool>.generate(
            propertyDetailsController.searchImageList.length, (index) => false);
    return Obx(() => Scaffold(
          backgroundColor: AppColor.whiteColor,
          appBar: buildAppBar(),
          body: buildPropertyDetails(context),
          bottomNavigationBar: buildButton(),
        ));
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
                Get.toNamed(AppRoutes.searchView);
              },
              child: Image.asset(
                Assets.images.search.path,
                width: AppSize.appSize24,
                color: AppColor.descriptionColor,
              ).paddingOnly(right: AppSize.appSize26),
            ),
            GestureDetector(
              onTap: () {
                Get.back();
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(AppSize.appSize40),
        child: SizedBox(
          height: AppSize.appSize40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Row(
                children: List.generate(
                    propertyDetailsController.propertyList.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      propertyDetailsController.updateProperty(index);
                    },
                    child: Obx(() => Container(
                          height: AppSize.appSize25,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: propertyDetailsController
                                            .selectProperty.value ==
                                        index
                                    ? AppColor.primaryColor
                                    : AppColor.borderColor,
                                width: AppSize.appSize1,
                              ),
                              right: BorderSide(
                                color: index == AppSize.size6
                                    ? Colors.transparent
                                    : AppColor.borderColor,
                                width: AppSize.appSize1,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              propertyDetailsController.propertyList[index],
                              style: AppStyle.heading5Medium(
                                color: propertyDetailsController
                                            .selectProperty.value ==
                                        index
                                    ? AppColor.primaryColor
                                    : AppColor.textColor,
                              ),
                            ),
                          ),
                        )),
                  );
                }),
              ).paddingOnly(
                top: AppSize.appSize10,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPropertyDetails(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSize.appSize30),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: AppSize.appSize200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              image: DecorationImage(
                image: AssetImage(Assets.images.modernHouse.path),
                fit: BoxFit.fill,
              ),
            ),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Text(
            AppString.rupees58Lakh,
            style: AppStyle.heading4Medium(color: AppColor.primaryColor),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Text(
                  AppString.readyToMove,
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                ),
                VerticalDivider(
                  color: AppColor.descriptionColor
                      .withValues(alpha: AppSize.appSizePoint4),
                  thickness: AppSize.appSizePoint7,
                  width: AppSize.appSize22,
                  indent: AppSize.appSize2,
                  endIndent: AppSize.appSize2,
                ),
                Text(
                  AppString.semiFurnished,
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                ),
              ],
            ),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Text(
            AppString.semiModernHouse,
            style: AppStyle.heading5SemiBold(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize8,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Text(
            AppString.address6,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ).paddingOnly(
            top: AppSize.appSize4,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Divider(
            color: AppColor.descriptionColor
                .withValues(alpha: AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSize0,
          ).paddingOnly(
            top: AppSize.appSize16,
            bottom: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Row(
            children: List.generate(
                propertyDetailsController.searchPropertyTitleList.length,
                (index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSize.appSize6,
                  horizontal: AppSize.appSize14,
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
                      propertyDetailsController.searchPropertyImageList[index],
                      width: AppSize.appSize18,
                      height: AppSize.appSize18,
                    ).paddingOnly(right: AppSize.appSize6),
                    Text(
                      propertyDetailsController.searchPropertyTitleList[index],
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ),
                  ],
                ),
              );
            }),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Row(
            children: List.generate(
                propertyDetailsController.searchProperty2TitleList.length,
                (index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSize.appSize6,
                  horizontal: AppSize.appSize14,
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
                      propertyDetailsController.searchProperty2ImageList[index],
                      width: AppSize.appSize18,
                      height: AppSize.appSize18,
                    ).paddingOnly(right: AppSize.appSize6),
                    Text(
                      propertyDetailsController.searchProperty2TitleList[index],
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ),
                  ],
                ),
              );
            }),
          ).paddingOnly(
            top: AppSize.appSize10,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.all(AppSize.appSize16),
            margin: const EdgeInsets.only(
              top: AppSize.appSize36,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              color: AppColor.primaryColor,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.keyHighlights,
                  style: AppStyle.heading4SemiBold(color: AppColor.whiteColor),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                      propertyDetailsController.keyHighlightsTitleList.length,
                      (index) {
                    return Row(
                      children: [
                        Container(
                          width: AppSize.appSize5,
                          height: AppSize.appSize5,
                          margin:
                              const EdgeInsets.only(left: AppSize.appSize10),
                          decoration: const BoxDecoration(
                            color: AppColor.whiteColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          propertyDetailsController
                              .keyHighlightsTitleList[index],
                          style: AppStyle.heading5Regular(
                              color: AppColor.whiteColor),
                        ).paddingOnly(left: AppSize.appSize10),
                      ],
                    ).paddingOnly(top: AppSize.appSize10);
                  }),
                ).paddingOnly(top: AppSize.appSize6),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              top: AppSize.appSize36,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              color: AppColor.secondaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.propertyDetails,
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ),
                Column(
                  children: List.generate(
                      propertyDetailsController.propertyDetailsTitleList.length,
                      (index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                propertyDetailsController
                                    .propertyDetailsTitleList[index],
                                style: AppStyle.heading5Regular(
                                    color: AppColor.descriptionColor),
                              ).paddingOnly(right: AppSize.appSize10),
                            ),
                            Expanded(
                              child: Text(
                                propertyDetailsController
                                    .propertyDetailsSubTitleList[index],
                                style: AppStyle.heading5Regular(
                                    color: AppColor.textColor),
                              ),
                            ),
                          ],
                        ),
                        if (index <
                            propertyDetailsController
                                    .propertyDetailsTitleList.length -
                                AppSize.size1) ...[
                          Divider(
                            color: AppColor.descriptionColor
                                .withValues(alpha: AppSize.appSizePoint4),
                            thickness: AppSize.appSizePoint7,
                            height: AppSize.appSize0,
                          ).paddingOnly(
                              top: AppSize.appSize16,
                              bottom: AppSize.appSize16),
                        ],
                      ],
                    );
                  }),
                ).paddingOnly(top: AppSize.appSize16),
              ],
            ).paddingOnly(
              left: AppSize.appSize16,
              right: AppSize.appSize16,
              top: AppSize.appSize16,
              bottom: AppSize.appSize16,
            ),
          ),
          Text(
            AppString.takeATourOfOurProperty,
            style: AppStyle.heading4SemiBold(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.galleryView);
            },
            child: Container(
              height: AppSize.appSize150,
              margin: const EdgeInsets.only(top: AppSize.appSize16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                image: DecorationImage(
                  image: AssetImage(Assets.images.hall.path),
                  fit: BoxFit.fill,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: AppSize.appSize75,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppSize.appSize13),
                      bottomRight: Radius.circular(AppSize.appSize13),
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      AppString.hall,
                      style:
                          AppStyle.heading3Medium(color: AppColor.whiteColor),
                    ),
                  ).paddingOnly(
                      left: AppSize.appSize16, bottom: AppSize.appSize16),
                ),
              ),
            ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.galleryView);
                  },
                  child: Container(
                    height: AppSize.appSize150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      image: DecorationImage(
                        image: AssetImage(Assets.images.kitchen.path),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: AppSize.appSize75,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(AppSize.appSize13),
                            bottomRight: Radius.circular(AppSize.appSize13),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            AppString.kitchen,
                            style: AppStyle.heading3Medium(
                                color: AppColor.whiteColor),
                          ),
                        ).paddingOnly(
                            left: AppSize.appSize16, bottom: AppSize.appSize16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSize.appSize16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.galleryView);
                  },
                  child: Container(
                    height: AppSize.appSize150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      image: DecorationImage(
                        image: AssetImage(Assets.images.bedroom.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: AppSize.appSize75,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(AppSize.appSize13),
                            bottomRight: Radius.circular(AppSize.appSize13),
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            AppString.bedroom,
                            style: AppStyle.heading3Medium(
                                color: AppColor.whiteColor),
                          ),
                        ).paddingOnly(
                            left: AppSize.appSize16, bottom: AppSize.appSize16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.furnishingDetails,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.furnishingDetailsView);
                },
                child: Text(
                  AppString.viewAll,
                  style:
                      AppStyle.heading5Medium(color: AppColor.descriptionColor),
                ),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          SizedBox(
            height: AppSize.appSize85,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount:
                  propertyDetailsController.furnishingDetailsImageList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding: const EdgeInsets.only(
                    left: AppSize.appSize16,
                    right: AppSize.appSize16,
                    top: AppSize.appSize16,
                    bottom: AppSize.appSize16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        propertyDetailsController
                            .furnishingDetailsImageList[index],
                        width: AppSize.appSize24,
                      ),
                      Text(
                        propertyDetailsController
                            .furnishingDetailsTitleList[index],
                        style:
                            AppStyle.heading5Regular(color: AppColor.textColor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
          Text(
            AppString.facilities,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          SizedBox(
            height: AppSize.appSize110,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: propertyDetailsController.facilitiesImageList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding: const EdgeInsets.only(
                    left: AppSize.appSize16,
                    right: AppSize.appSize16,
                    top: AppSize.appSize16,
                    bottom: AppSize.appSize16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        propertyDetailsController.facilitiesImageList[index],
                        width: AppSize.appSize40,
                      ),
                      Text(
                        propertyDetailsController.facilitiesTitleList[index],
                        style:
                            AppStyle.heading5Regular(color: AppColor.textColor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
          Text(
            AppString.aboutProperty,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Container(
            padding: const EdgeInsets.all(AppSize.appSize10),
            margin: const EdgeInsets.only(
              top: AppSize.appSize16,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColor.descriptionColor
                    .withValues(alpha: AppSize.appSizePoint50),
              ),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppString.semiModernHouse,
                  style: AppStyle.heading5SemiBold(color: AppColor.textColor),
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
                            color: AppColor.descriptionColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            color: AppColor.descriptionColor
                .withValues(alpha: AppSize.appSizePoint4),
            thickness: AppSize.appSizePoint7,
            height: AppSize.appSize0,
          ).paddingOnly(
            left: AppSize.appSize16,
            right: AppSize.appSize16,
            top: AppSize.appSize16,
            bottom: AppSize.appSize16,
          ),
          CommonRichText(
            segments: [
              TextSegment(
                text: AppString.aboutPropertyString,
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor),
              ),
              TextSegment(
                text: AppString.readMore,
                onTap: () {
                  Get.toNamed(AppRoutes.aboutPropertyView);
                },
                style: AppStyle.heading5Regular(color: AppColor.primaryColor),
              ),
            ],
          ).paddingOnly(
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.propertyVisitTime,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              Text(
                AppString.openNow,
                style: AppStyle.heading5Medium(color: AppColor.positiveColor),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          GestureDetector(
            onTap: () {
              propertyDetailsController.toggleVisitExpansion();
            },
            child: Obx(() => Container(
                  padding: const EdgeInsets.all(AppSize.appSize16),
                  margin: const EdgeInsets.only(
                    top: AppSize.appSize16,
                    left: AppSize.appSize16,
                    right: AppSize.appSize16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColor.descriptionColor
                          .withValues(alpha: AppSize.appSizePoint50),
                    ),
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppString.monday,
                        style: AppStyle.heading4Regular(
                            color: AppColor.descriptionColor),
                      ),
                      Image.asset(
                        propertyDetailsController.isVisitExpanded.value
                            ? Assets.images.dropdownExpand.path
                            : Assets.images.dropdown.path,
                        width: AppSize.appSize18,
                      ),
                    ],
                  ),
                )),
          ),
          Obx(() => AnimatedContainer(
                duration: const Duration(seconds: AppSize.size1),
                curve: Curves.fastEaseInToSlowEaseOut,
                margin: EdgeInsets.only(
                  top: propertyDetailsController.isVisitExpanded.value
                      ? AppSize.appSize16
                      : AppSize.appSize0,
                ),
                height: propertyDetailsController.isVisitExpanded.value
                    ? null
                    : AppSize.appSize0,
                child: propertyDetailsController.isVisitExpanded.value
                    ? GestureDetector(
                        onTap: () {
                          propertyDetailsController.toggleVisitExpansion();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                            left: AppSize.appSize16,
                            right: AppSize.appSize16,
                          ),
                          padding: const EdgeInsets.only(
                            left: AppSize.appSize16,
                            right: AppSize.appSize16,
                            top: AppSize.appSize16,
                            bottom: AppSize.appSize6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize12),
                            color: AppColor.whiteColor,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                spreadRadius: AppSize.appSizePoint1,
                                blurRadius: AppSize.appSize2,
                              ),
                            ],
                          ),
                          child: Column(
                            children: List.generate(
                                propertyDetailsController.dayList.length,
                                (index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    propertyDetailsController.dayList[index],
                                    style: AppStyle.heading5Regular(
                                        color: AppColor.descriptionColor),
                                  ),
                                  Text(
                                    propertyDetailsController.timingList[index],
                                    style: AppStyle.heading5Regular(
                                        color: AppColor.textColor),
                                  ),
                                ],
                              ).paddingOnly(bottom: AppSize.appSize10);
                            }),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              )),
          Text(
            AppString.contactToOwner,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Container(
            padding: const EdgeInsets.all(AppSize.appSize10),
            margin: const EdgeInsets.only(
              top: AppSize.appSize16,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              color: AppColor.secondaryColor,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            child: Row(
              children: [
                Image.asset(
                  Assets.images.response1.path,
                  width: AppSize.appSize64,
                  height: AppSize.appSize64,
                ).paddingOnly(right: AppSize.appSize12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppString.rudraProperties,
                        style:
                            AppStyle.heading4Medium(color: AppColor.textColor),
                      ).paddingOnly(bottom: AppSize.appSize4),
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            Text(
                              AppString.broker,
                              style: AppStyle.heading5Medium(
                                  color: AppColor.descriptionColor),
                            ),
                            VerticalDivider(
                              color: AppColor.descriptionColor
                                  .withValues(alpha: AppSize.appSizePoint4),
                              thickness: AppSize.appSizePoint7,
                              width: AppSize.appSize20,
                              indent: AppSize.appSize2,
                              endIndent: AppSize.appSize2,
                            ),
                            Text(
                              AppString.brokerNumber,
                              style: AppStyle.heading5Medium(
                                  color: AppColor.descriptionColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Obx(() => CommonTextField(
                controller: propertyDetailsController.fullNameController,
                focusNode: propertyDetailsController.focusNode,
                hasFocus: propertyDetailsController.hasFullNameFocus.value,
                hasInput: propertyDetailsController.hasFullNameInput.value,
                hintText: AppString.fullName,
                labelText: AppString.fullName,
              )).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Obx(() => Container(
                padding: EdgeInsets.only(
                  top: propertyDetailsController.hasPhoneNumberFocus.value ||
                          propertyDetailsController.hasPhoneNumberInput.value
                      ? AppSize.appSize6
                      : AppSize.appSize14,
                  bottom: propertyDetailsController.hasPhoneNumberFocus.value ||
                          propertyDetailsController.hasPhoneNumberInput.value
                      ? AppSize.appSize8
                      : AppSize.appSize14,
                  left: propertyDetailsController.hasPhoneNumberFocus.value
                      ? AppSize.appSize0
                      : AppSize.appSize16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  border: Border.all(
                    color: propertyDetailsController
                                .hasPhoneNumberFocus.value ||
                            propertyDetailsController.hasPhoneNumberInput.value
                        ? AppColor.primaryColor
                        : AppColor.descriptionColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    propertyDetailsController.hasPhoneNumberFocus.value ||
                            propertyDetailsController.hasPhoneNumberInput.value
                        ? Text(
                            AppString.phoneNumber,
                            style: AppStyle.heading6Regular(
                                color: AppColor.primaryColor),
                          ).paddingOnly(
                            left: propertyDetailsController
                                    .hasPhoneNumberInput.value
                                ? (propertyDetailsController
                                        .hasPhoneNumberFocus.value
                                    ? AppSize.appSize16
                                    : AppSize.appSize0)
                                : AppSize.appSize16,
                            bottom: propertyDetailsController
                                    .hasPhoneNumberInput.value
                                ? AppSize.appSize2
                                : AppSize.appSize2,
                          )
                        : const SizedBox.shrink(),
                    Row(
                      children: [
                        propertyDetailsController.hasPhoneNumberFocus.value ||
                                propertyDetailsController
                                    .hasPhoneNumberInput.value
                            ? SizedBox(
                                // width: AppSize.appSize78,
                                child: IntrinsicHeight(
                                  child: GestureDetector(
                                    onTap: () {
                                      ownerCountryPickerBottomSheet(context);
                                    },
                                    child: Row(
                                      children: [
                                        Obx(() {
                                          final selectedCountryIndex =
                                              ownerCountryPickerController
                                                  .selectedIndex.value;
                                          return Text(
                                            ownerCountryPickerController
                                                            .countries[
                                                        selectedCountryIndex]
                                                    [AppString.codeText] ??
                                                '',
                                            style: AppStyle.heading4Regular(
                                                color: AppColor.primaryColor),
                                          );
                                        }),
                                        Image.asset(
                                          Assets.images.dropdown.path,
                                          width: AppSize.appSize16,
                                        ).paddingOnly(
                                            left: AppSize.appSize8,
                                            right: AppSize.appSize3),
                                        const VerticalDivider(
                                          color: AppColor.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).paddingOnly(
                                left: propertyDetailsController
                                        .hasPhoneNumberInput.value
                                    ? (propertyDetailsController
                                            .hasPhoneNumberFocus.value
                                        ? AppSize.appSize16
                                        : AppSize.appSize0)
                                    : AppSize.appSize16,
                              )
                            : const SizedBox.shrink(),
                        Expanded(
                          child: SizedBox(
                            height: AppSize.appSize27,
                            width: double.infinity,
                            child: TextFormField(
                              focusNode: propertyDetailsController
                                  .phoneNumberFocusNode,
                              controller: propertyDetailsController
                                  .mobileNumberController,
                              cursorColor: AppColor.primaryColor,
                              keyboardType: TextInputType.phone,
                              style: AppStyle.heading4Regular(
                                  color: AppColor.textColor),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(
                                    AppSize.size10),
                              ],
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSize.appSize0,
                                  vertical: AppSize.appSize0,
                                ),
                                isDense: true,
                                hintText: propertyDetailsController
                                        .hasPhoneNumberFocus.value
                                    ? ''
                                    : AppString.phoneNumber,
                                hintStyle: AppStyle.heading4Regular(
                                    color: AppColor.descriptionColor),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSize.appSize12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSize.appSize12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSize.appSize12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Obx(() => CommonTextField(
                controller: propertyDetailsController.emailController,
                focusNode: propertyDetailsController.emailFocusNode,
                hasFocus: propertyDetailsController.hasEmailFocus.value,
                hasInput: propertyDetailsController.hasEmailInput.value,
                hintText: AppString.emailAddress,
                labelText: AppString.emailAddress,
              )).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Text(
            AppString.areYouARealEstateAgent,
            style: AppStyle.heading4Regular(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Row(
            children: List.generate(
                propertyDetailsController.realEstateList.length, (index) {
              return GestureDetector(
                onTap: () {
                  propertyDetailsController.updateAgent(index);
                },
                child: Obx(() => Container(
                      width: AppSize.appSize75,
                      margin: const EdgeInsets.only(right: AppSize.appSize16),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSize.appSize10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: propertyDetailsController.selectAgent.value ==
                                  index
                              ? AppColor.primaryColor
                              : AppColor.borderColor,
                          width: AppSize.appSize1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          propertyDetailsController.realEstateList[index],
                          style: AppStyle.heading5Medium(
                            color:
                                propertyDetailsController.selectAgent.value ==
                                        index
                                    ? AppColor.primaryColor
                                    : AppColor.descriptionColor,
                          ),
                        ),
                      ),
                    )),
              );
            }),
          ).paddingOnly(
            top: AppSize.appSize10,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  propertyDetailsController.toggleCheckbox();
                },
                child: Obx(() => Image.asset(
                      propertyDetailsController.isChecked.value
                          ? Assets.images.checkbox.path
                          : Assets.images.emptyCheckbox.path,
                      width: AppSize.appSize20,
                    )).paddingOnly(right: AppSize.appSize16),
              ),
              Expanded(
                child: CommonRichText(
                  segments: [
                    TextSegment(
                      text: AppString.terms1,
                      style: AppStyle.heading6Regular(
                          color: AppColor.descriptionColor),
                    ),
                    TextSegment(
                      text: AppString.terms2,
                      style: AppStyle.heading6Regular(
                          color: AppColor.primaryColor),
                    ),
                    TextSegment(
                      text: AppString.terms3,
                      style: AppStyle.heading6Regular(
                          color: AppColor.descriptionColor),
                    ),
                    TextSegment(
                      text: AppString.terms4,
                      style: AppStyle.heading6Regular(
                          color: AppColor.primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          CommonButton(
            onPressed: () {
              Get.toNamed(AppRoutes.contactOwnerView);
            },
            backgroundColor: AppColor.primaryColor,
            child: Text(
              AppString.viewPhoneNumberButton,
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
          ).paddingOnly(
            left: AppSize.appSize16,
            right: AppSize.appSize16,
            top: AppSize.appSize26,
          ),
          Text(
            AppString.exploreMap,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSize.appSize12),
            child: SizedBox(
              height: AppSize.appSize200,
              width: double.infinity,
              child: GoogleMap(
                onMapCreated: (ctr) {},
                mapType: MapType.normal,
                myLocationEnabled: false,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                markers: {
                  const Marker(
                    markerId: MarkerId(AppString.testing),
                    visible: true,
                    position: LatLng(AppSize.latitude, AppSize.longitude),
                  )
                },
                initialCameraPosition: const CameraPosition(
                  target: LatLng(AppSize.latitude, AppSize.longitude),
                  zoom: AppSize.appSize15,
                ),
              ),
            ),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.reviews,
                style: AppStyle.heading3SemiBold(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.addReviewsForPropertyView);
                },
                child: Text(
                  AppString.addReviews,
                  style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                ),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: propertyDetailsController.reviewRatingImageList.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: AppSize.appSize16),
                padding: const EdgeInsets.all(AppSize.appSize16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize16),
                  border: Border.all(
                    color: AppColor.descriptionColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          propertyDetailsController.reviewDateList[index],
                          style: AppStyle.heading6Regular(
                              color: AppColor.descriptionColor),
                        ),
                        Image.asset(
                          propertyDetailsController
                              .reviewRatingImageList[index],
                          width: AppSize.appSize122,
                          height: AppSize.appSize18,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Image.asset(
                          propertyDetailsController.reviewProfileList[index],
                          width: AppSize.appSize36,
                        ),
                        Text(
                          propertyDetailsController
                              .reviewProfileNameList[index],
                          style: AppStyle.heading5Medium(
                              color: AppColor.textColor),
                        ).paddingOnly(left: AppSize.appSize6),
                      ],
                    ).paddingOnly(top: AppSize.appSize10),
                    Text(
                      propertyDetailsController.reviewTypeList[index],
                      style: AppStyle.heading5Medium(
                          color: AppColor.descriptionColor),
                    ).paddingOnly(top: AppSize.appSize10),
                    Text(
                      propertyDetailsController.reviewDescriptionList[index],
                      style:
                          AppStyle.heading5Regular(color: AppColor.textColor),
                    ).paddingOnly(top: AppSize.appSize10),
                  ],
                ),
              );
            },
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Text(
            AppString.similarHomesForYou,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize20,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          SizedBox(
            height: AppSize.appSize372,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: propertyDetailsController.searchImageList.length,
              itemBuilder: (context, index) {
                return Container(
                  width: AppSize.appSize300,
                  padding: const EdgeInsets.all(AppSize.appSize10),
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
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
                            propertyDetailsController.searchImageList[index],
                            height: AppSize.appSize200,
                          ),
                          Positioned(
                            right: AppSize.appSize6,
                            top: AppSize.appSize6,
                            child: GestureDetector(
                              onTap: () {
                                propertyDetailsController
                                        .isSimilarPropertyLiked[index] =
                                    !propertyDetailsController
                                        .isSimilarPropertyLiked[index];
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
                                        propertyDetailsController
                                                .isSimilarPropertyLiked[index]
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
                            propertyDetailsController.searchTitleList[index],
                            style: AppStyle.heading5SemiBold(
                                color: AppColor.textColor),
                          ),
                          Text(
                            propertyDetailsController.searchAddressList[index],
                            style: AppStyle.heading5Regular(
                                color: AppColor.descriptionColor),
                          ).paddingOnly(top: AppSize.appSize6),
                        ],
                      ).paddingOnly(top: AppSize.appSize8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            propertyDetailsController.searchRupeesList[index],
                            style: AppStyle.heading5Medium(
                                color: AppColor.primaryColor),
                          ),
                          Row(
                            children: [
                              Text(
                                propertyDetailsController
                                    .searchRatingList[index],
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
                      ).paddingOnly(top: AppSize.appSize6),
                      Divider(
                        color: AppColor.descriptionColor
                            .withValues(alpha: AppSize.appSizePoint3),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                            propertyDetailsController
                                .searchPropertyImageList.length, (index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSize.appSize6,
                              horizontal: AppSize.appSize16,
                            ),
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
                                  propertyDetailsController
                                      .searchPropertyImageList[index],
                                  width: AppSize.appSize18,
                                  height: AppSize.appSize18,
                                ).paddingOnly(right: AppSize.appSize6),
                                Text(
                                  propertyDetailsController
                                      .similarPropertyTitleList[index],
                                  style: AppStyle.heading5Medium(
                                      color: AppColor.textColor),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
          Text(
            AppString.interestingReads,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          SizedBox(
            height: AppSize.appSize116,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: propertyDetailsController.interestingImageList.length,
              itemBuilder: (context, index) {
                return Container(
                  width: AppSize.appSize300,
                  padding: const EdgeInsets.all(AppSize.appSize16),
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        propertyDetailsController.interestingImageList[index],
                      ).paddingOnly(right: AppSize.appSize16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              propertyDetailsController
                                  .interestingTitleList[index],
                              maxLines: AppSize.size3,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyle.heading5Medium(
                                  color: AppColor.textColor),
                            ),
                            Text(
                              propertyDetailsController
                                  .interestingDateList[index],
                              style: AppStyle.heading6Regular(
                                  color: AppColor.descriptionColor),
                            ).paddingOnly(top: AppSize.appSize6),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
        ],
      ).paddingOnly(top: AppSize.appSize10),
    );
  }

  Widget buildButton() {
    return CommonButton(
      onPressed: () {},
      backgroundColor: AppColor.primaryColor,
      child: Text(
        AppString.ownerDetailsButton,
        style: AppStyle.heading5Medium(color: AppColor.whiteColor),
      ),
    ).paddingOnly(
      left: AppSize.appSize16,
      right: AppSize.appSize16,
      bottom: AppSize.appSize26,
      top: AppSize.appSize10,
    );
  }
}
