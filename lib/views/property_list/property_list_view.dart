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
      title: Text(
        'Propriétés',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
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
    return RefreshIndicator(
      onRefresh: propertyListController.refreshProperties,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSize.appSize10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
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
                onChanged: propertyListController.searchProperties,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                    top: AppSize.appSize16,
                    bottom: AppSize.appSize16,
                  ),
                  hintText: 'Rechercher une propriété...',
                  hintStyle: AppStyle.heading4Regular(
                      color: AppColor.descriptionColor),
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

            // Properties list
            Obx(() {
              if (propertyListController.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSize.appSize50),
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  ),
                );
              }

              if (propertyListController.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSize.appSize20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: AppSize.appSize50,
                          color: AppColor.descriptionColor,
                        ),
                        const SizedBox(height: AppSize.appSize16),
                        Text(
                          propertyListController.errorMessage.value,
                          style: AppStyle.heading5Regular(
                            color: AppColor.descriptionColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSize.appSize16),
                        ElevatedButton(
                          onPressed: propertyListController.refreshProperties,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor,
                          ),
                          child: Text(
                            'Réessayer',
                            style: AppStyle.heading5Medium(
                              color: AppColor.whiteColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (propertyListController.properties.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSize.appSize20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: AppSize.appSize50,
                          color: AppColor.descriptionColor,
                        ),
                        const SizedBox(height: AppSize.appSize16),
                        Text(
                          'Aucune propriété trouvée',
                          style: AppStyle.heading5Regular(
                            color: AppColor.descriptionColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: propertyListController.properties.length,
                itemBuilder: (context, index) {
                  final property = propertyListController.properties[index];
                  final status =
                      propertyListController.getPropertyStatus(property);
                  final features =
                      propertyListController.getPropertyFeatures(property);
                  final surfaces =
                      propertyListController.getSurfaceDetails(property);

                  return GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.propertyDetailsView,
                          arguments: property);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSize.appSize10),
                      margin: const EdgeInsets.only(bottom: AppSize.appSize16),
                      decoration: BoxDecoration(
                        color: AppColor.secondaryColor,
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            spreadRadius: AppSize.appSizePoint1,
                            blurRadius: AppSize.appSize4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Property image with like button
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppSize.appSize8),
                                child: Image.asset(
                                  propertyListController
                                      .getPropertyImage(property),
                                  width: double.infinity,
                                  height: AppSize.appSize200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: AppSize.appSize200,
                                      decoration: BoxDecoration(
                                        color: AppColor.backgroundColor,
                                        borderRadius: BorderRadius.circular(
                                            AppSize.appSize8),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.home,
                                            size: AppSize.appSize50,
                                            color: AppColor.descriptionColor,
                                          ),
                                          Text(
                                            propertyListController
                                                .getFormattedPropertyType(
                                                    property),
                                            style: AppStyle.heading6Regular(
                                              color: AppColor.descriptionColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                right: AppSize.appSize6,
                                top: AppSize.appSize6,
                                child: GestureDetector(
                                  onTap: () {
                                    propertyListController
                                        .togglePropertyLike(property.id!);
                                  },
                                  child: Container(
                                    width: AppSize.appSize32,
                                    height: AppSize.appSize32,
                                    decoration: BoxDecoration(
                                      color: AppColor.whiteColor.withValues(
                                          alpha: AppSize.appSizePoint50),
                                      borderRadius: BorderRadius.circular(
                                          AppSize.appSize16),
                                    ),
                                    child: Center(
                                      child: Obx(() => Image.asset(
                                            propertyListController
                                                    .isPropertyLiked(property.id!) 
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

                          // Property details
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status and type badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSize.appSize8,
                                      vertical: AppSize.appSize4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (status['color'] as Color)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                          AppSize.appSize4),
                                    ),
                                    child: Text(
                                      status['text'],
                                      style: AppStyle.heading6Regular(
                                          color: status['color']),
                                    ),
                                  ),
                                  const SizedBox(width: AppSize.appSize8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSize.appSize8,
                                      vertical: AppSize.appSize4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.primaryColor
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                          AppSize.appSize4),
                                    ),
                                    child: Text(
                                      propertyListController
                                          .getFormattedPropertyType(property),
                                      style: AppStyle.heading6Regular(
                                          color: AppColor.primaryColor),
                                    ),
                                  ),
                                ],
                              ),

                              // Property title
                              Text(
                                property.displayTitle,
                                style: AppStyle.heading5SemiBold(
                                    color: AppColor.textColor),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ).paddingOnly(top: AppSize.appSize8),

                              // Property address
                              Text(
                                property.displayAddress,
                                style: AppStyle.heading5Regular(
                                    color: AppColor.descriptionColor),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ).paddingOnly(top: AppSize.appSize4),
                            ],
                          ).paddingOnly(top: AppSize.appSize16),

                          // Price and rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                propertyListController
                                    .getFormattedPrice(property),
                                style: AppStyle.heading4Medium(
                                    color: AppColor.primaryColor),
                              ),
                              Row(
                                children: [
                                  Text(
                                    propertyListController.getRating(property),
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

                          // Divider
                          Divider(
                            color: AppColor.descriptionColor
                                .withValues(alpha: AppSize.appSizePoint3),
                            height: AppSize.appSize0,
                          ).paddingOnly(
                              top: AppSize.appSize16,
                              bottom: AppSize.appSize16),

                          // Property features chips
                          if (features.isNotEmpty)
                            Wrap(
                              spacing: AppSize.appSize12,
                              children: features.map((feature) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: AppSize.appSize6,
                                    horizontal: AppSize.appSize12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        AppSize.appSize12),
                                    border: Border.all(
                                      color: AppColor.primaryColor,
                                      width: AppSize.appSizePoint50,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        feature['icon'],
                                        width: AppSize.appSize18,
                                        height: AppSize.appSize18,
                                      ).paddingOnly(right: AppSize.appSize6),
                                      Text(
                                        feature['text'],
                                        style: AppStyle.heading5Medium(
                                            color: AppColor.textColor),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),

                          // Surface details
                          if (surfaces.isNotEmpty)
                            IntrinsicHeight(
                              child: Row(
                                children: [
                                  for (int i = 0; i < surfaces.length; i++) ...[
                                    if (i > 0) ...[
                                      const VerticalDivider(
                                        color: AppColor.descriptionColor,
                                        width: AppSize.appSize0,
                                        indent: AppSize.appSize2,
                                        endIndent: AppSize.appSize2,
                                      ).paddingOnly(
                                          left: AppSize.appSize8,
                                          right: AppSize.appSize8),
                                    ],
                                    CommonRichText(
                                      segments: [
                                        TextSegment(
                                          text: surfaces[i]['value']!,
                                          style: AppStyle.heading5Regular(
                                              color: AppColor.textColor),
                                        ),
                                        TextSegment(
                                          text: surfaces[i]['label']!,
                                          style: AppStyle.heading7Regular(
                                              color: AppColor.descriptionColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ).paddingOnly(top: AppSize.appSize12),
                            ),

                          // Call button
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: AppSize.appSize35,
                            child: ElevatedButton(
                              onPressed: () {
                                propertyListController.launchDialer();
                              },
                              style: ButtonStyle(
                                elevation: const WidgetStatePropertyAll(
                                    AppSize.appSize0),
                                shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppSize.appSize12),
                                    side: const BorderSide(
                                        color: AppColor.primaryColor,
                                        width: AppSize.appSizePoint7),
                                  ),
                                ),
                                backgroundColor: WidgetStateColor.transparent,
                              ),
                              child: Text(
                                'Contacter',
                                style: AppStyle.heading6Regular(
                                    color: AppColor.primaryColor),
                              ),
                            ),
                          ).paddingOnly(top: AppSize.appSize20),
                        ],
                      ),
                    ),
                  );
                },
              ).paddingOnly(top: AppSize.appSize16);
            }),
          ],
        ).paddingOnly(
          top: AppSize.appSize10,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      ),
    );
  }
}
