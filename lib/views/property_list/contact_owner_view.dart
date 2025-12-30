import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bottom_bar_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/contact_owner_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/property_list/property_details_view.dart';
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
                Assets.images.emptyRatingStar.path,
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
          Obx(() => Container(
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
                      CircleAvatar(
                        radius: AppSize.appSize32,
                        backgroundColor: AppColor.primaryColor.withValues(alpha: 0.1),
                        child: Text(
                          contactOwnerController.ownerFullName.isNotEmpty
                              ? contactOwnerController.ownerFullName[0].toUpperCase()
                              : 'P',
                          style: AppStyle.heading3SemiBold(color: AppColor.primaryColor),
                        ),
                      ).paddingOnly(right: AppSize.appSize12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contactOwnerController.ownerFullName,
                              style: AppStyle.heading4Medium(color: AppColor.textColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              contactOwnerController.ownerRole,
                              style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => contactOwnerController.launchDialer(),
                  child: Row(
                    children: [
                      Image.asset(
                        Assets.images.call.path,
                        width: AppSize.appSize20,
                        color: AppColor.primaryColor,
                      ),
                      Expanded(
                        child: Text(
                          contactOwnerController.ownerPhone,
                          style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                        ).paddingOnly(left: AppSize.appSize10),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: AppSize.appSize16,
                        color: AppColor.primaryColor,
                      ),
                    ],
                  ).paddingOnly(top: AppSize.appSize12),
                ),
                GestureDetector(
                  onTap: () => contactOwnerController.launchEmail(),
                  child: Row(
                    children: [
                      Image.asset(
                        Assets.images.email.path,
                        width: AppSize.appSize20,
                        color: AppColor.primaryColor,
                      ),
                      Expanded(
                        child: Text(
                          contactOwnerController.ownerEmail,
                          style: AppStyle.heading5Regular(color: AppColor.primaryColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).paddingOnly(left: AppSize.appSize10),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: AppSize.appSize16,
                        color: AppColor.primaryColor,
                      ),
                    ],
                  ).paddingOnly(top: AppSize.appSize16),
                ),
              ],
            ),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16)),
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
          Obx(() {
            // Use real similar properties if available, otherwise fall back to default images
            final hasSimilarProperties = contactOwnerController.similarProperties.isNotEmpty;
            final itemCount = hasSimilarProperties
                ? contactOwnerController.similarProperties.length
                : contactOwnerController.searchImageList.length;

            if (itemCount == 0) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: AppSize.appSize372,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(left: AppSize.appSize16),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (hasSimilarProperties) {
                    // Build with real property data
                    final property = contactOwnerController.similarProperties[index];
                    return GestureDetector(
                      onTap: () => Get.off(
                        () => PropertyDetailsView(),
                        arguments: property,
                      ),
                      child: _buildSimilarPropertyCard(property, index),
                    );
                  } else {
                    // Build with default/placeholder data
                    return _buildDefaultPropertyCard(index);
                  }
                },
              ),
            ).paddingOnly(top: AppSize.appSize16);
          }),
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

  Widget _buildSimilarPropertyCard(BienImmo property, int index) {
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
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSize.appSize8),
                child: _buildPropertyImage(property),
              ),
              Positioned(
                right: AppSize.appSize6,
                top: AppSize.appSize6,
                child: GestureDetector(
                  onTap: () => contactOwnerController.toggleSimilarPropertyLike(index),
                  child: Container(
                    width: AppSize.appSize32,
                    height: AppSize.appSize32,
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor.withValues(alpha: AppSize.appSizePoint50),
                      borderRadius: BorderRadius.circular(AppSize.appSize6),
                    ),
                    child: Center(
                      child: Obx(() => Image.asset(
                        contactOwnerController.isSimilarPropertyLiked[index]
                            ? Assets.images.ratingStar.path
                            : Assets.images.emptyRatingStar.path,
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
                property.displayTitle,
                style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                property.displayAddress,
                style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).paddingOnly(top: AppSize.appSize6),
            ],
          ).paddingOnly(top: AppSize.appSize8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                property.formattedPrice,
                style: AppStyle.heading5Medium(color: AppColor.primaryColor),
              ),
              Row(
                children: [
                  Text(
                    property.calculatedRating.toStringAsFixed(1),
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
            color: AppColor.descriptionColor.withValues(alpha: AppSize.appSizePoint3),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (property.nombreChambres > 0)
                _buildFeatureChip(Assets.images.bed.path, '${property.nombreChambres}'),
              if (property.nombreSallesDeBain > 0)
                _buildFeatureChip(Assets.images.bath.path, '${property.nombreSallesDeBain}'),
              _buildFeatureChip(Assets.images.plot.path, property.formattedSurface),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultPropertyCard(int index) {
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
                  onTap: () => contactOwnerController.toggleSimilarPropertyLike(index),
                  child: Container(
                    width: AppSize.appSize32,
                    height: AppSize.appSize32,
                    decoration: BoxDecoration(
                      color: AppColor.whiteColor.withValues(alpha: AppSize.appSizePoint50),
                      borderRadius: BorderRadius.circular(AppSize.appSize6),
                    ),
                    child: Center(
                      child: Obx(() => Image.asset(
                        contactOwnerController.isSimilarPropertyLiked[index]
                            ? Assets.images.ratingStar.path
                            : Assets.images.emptyRatingStar.path,
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
            color: AppColor.descriptionColor.withValues(alpha: AppSize.appSizePoint3),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(contactOwnerController.similarPropertyTitleList.length, (featureIndex) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSize.appSize6,
                  horizontal: AppSize.appSize16,
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
                      contactOwnerController.searchPropertyImageList[featureIndex],
                      width: AppSize.appSize18,
                      height: AppSize.appSize18,
                    ).paddingOnly(right: AppSize.appSize6),
                    Text(
                      contactOwnerController.similarPropertyTitleList[featureIndex],
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
  }

  Widget _buildPropertyImage(BienImmo property) {
    if (property.listeImages.isEmpty) {
      return Container(
        height: AppSize.appSize200,
        width: double.infinity,
        color: AppColor.backgroundColor,
        child: Icon(
          Icons.home_outlined,
          size: AppSize.appSize50,
          color: AppColor.descriptionColor,
        ),
      );
    }

    final imagePath = property.listeImages.first;
    final isNetworkImage = imagePath.startsWith('uploads/') ||
        imagePath.startsWith('http://') ||
        imagePath.startsWith('https://');

    if (!isNetworkImage) {
      return Image.asset(
        imagePath,
        height: AppSize.appSize200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    final fullUrl = imagePath.startsWith('http')
        ? imagePath
        : '${ApiConfig.baseUrl}/$imagePath';

    return CachedNetworkImage(
      imageUrl: fullUrl,
      height: AppSize.appSize200,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppColor.backgroundColor,
        child: const Center(
          child: CircularProgressIndicator(color: AppColor.primaryColor),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppColor.backgroundColor,
        child: Icon(
          Icons.home_outlined,
          size: AppSize.appSize50,
          color: AppColor.descriptionColor,
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String iconPath, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSize.appSize6,
        horizontal: AppSize.appSize14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(
          color: AppColor.primaryColor,
          width: AppSize.appSizePoint50,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: AppSize.appSize18,
            height: AppSize.appSize18,
          ).paddingOnly(right: AppSize.appSize6),
          Text(
            text,
            style: AppStyle.heading5Medium(color: AppColor.textColor),
          ),
        ],
      ),
    );
  }
}
