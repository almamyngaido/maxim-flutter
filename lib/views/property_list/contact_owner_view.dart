import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bottom_bar_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/contact_owner_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:share_plus/share_plus.dart';

class ContactOwnerView extends StatelessWidget {
  ContactOwnerView({super.key});

 final ContactOwnerController contactOwnerController = Get.put(ContactOwnerController());

  @override
  Widget build(BuildContext context) {
    contactOwnerController.isSimilarPropertyLiked.value = List<bool>.generate(
        contactOwnerController.searchImageList.length, (index) => false);
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildContactOwner(),
      bottomNavigationBar: buildButton(),
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
      title: Text(
        AppString.contactOwner,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
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
                Get.back();
                Future.delayed(const Duration(milliseconds: AppSize.size400), () {
                  BottomBarController bottomBarController = Get.put(BottomBarController());
                  bottomBarController.pageController.jumpToPage(AppSize.size3);
                },);
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

  Widget buildContactOwner() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSize.appSize10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint4),
                width: AppSize.appSizePoint7,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSize.appSize10),
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
                        child: Text(
                          AppString.rudraProperties,
                          style: AppStyle.heading4Medium(color: AppColor.textColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Image.asset(
                      Assets.images.user.path,
                      width: AppSize.appSize20,
                      color: AppColor.primaryColor,
                    ),
                    Text(
                      AppString.lorraineHermann,
                      style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                    ).paddingOnly(left: AppSize.appSize10),
                  ],
                ).paddingOnly(top: AppSize.appSize12),
                Row(
                  children: [
                    Image.asset(
                      Assets.images.call.path,
                      width: AppSize.appSize20,
                      color: AppColor.primaryColor,
                    ),
                    Text(
                      AppString.lorraineHermannNumber,
                      style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                    ).paddingOnly(left: AppSize.appSize10),
                  ],
                ).paddingOnly(top: AppSize.appSize16),
                Row(
                  children: [
                    Image.asset(
                      Assets.images.email.path,
                      width: AppSize.appSize20,
                      color: AppColor.primaryColor,
                    ),
                    Text(
                      AppString.rudraEmail,
                      style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                    ).paddingOnly(left: AppSize.appSize10),
                  ],
                ).paddingOnly(top: AppSize.appSize16),
              ],
            ),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Row(
            children: [
              Image.asset(
                Assets.images.checked.path,
                width: AppSize.appSize16,
              ),
              Text(
                AppString.yourRequestHasBeenSharedWithinBroker,
                style: AppStyle.heading5Regular(color: AppColor.primaryColor),
              ).paddingOnly(left: AppSize.appSize6),
            ],
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          Text(
            AppString.similarProperties,
            style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16, right: AppSize.appSize16,
          ),
          SizedBox(
            height: AppSize.appSize372,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: contactOwnerController.searchImageList.length,
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
                            contactOwnerController.searchImageList[index],
                            height: AppSize.appSize200,
                          ),
                          Positioned(
                            right: AppSize.appSize6,
                            top: AppSize.appSize6,
                            child: GestureDetector(
                              onTap: () {
                                contactOwnerController.isSimilarPropertyLiked[index] =
                                !contactOwnerController.isSimilarPropertyLiked[index];
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
                                    contactOwnerController.isSimilarPropertyLiked[index]
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
                            contactOwnerController.searchTitleList[index],
                            style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                          ),
                          Text(
                            contactOwnerController.searchAddressList[index],
                            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                          ).paddingOnly(top: AppSize.appSize6),
                        ],
                      ).paddingOnly(top: AppSize.appSize8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppString.rupees58Lakh,
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
                      ).paddingOnly(top: AppSize.appSize6),
                      Divider(
                        color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint3),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(contactOwnerController.similarPropertyTitleList.length, (index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSize.appSize6, horizontal: AppSize.appSize16,
                            ),
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
                                  contactOwnerController.searchPropertyImageList[index],
                                  width: AppSize.appSize18,
                                  height: AppSize.appSize18,
                                ).paddingOnly(right: AppSize.appSize6),
                                Text(
                                  contactOwnerController.similarPropertyTitleList[index],
                                  style: AppStyle.heading5Medium(color: AppColor.textColor),
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
        ],
      ).paddingOnly(top: AppSize.appSize10),
    );
  }

  Widget buildButton() {
    return CommonButton(
      onPressed: () {
        contactOwnerController.launchDialer();
      },
      backgroundColor: AppColor.primaryColor,
      child: Text(
        AppString.callOwnerButton,
        style: AppStyle.heading5Medium(color: AppColor.whiteColor),
      ),
    ).paddingOnly(
        left: AppSize.appSize16, right: AppSize.appSize16,
        bottom: AppSize.appSize26
    );
  }
}
