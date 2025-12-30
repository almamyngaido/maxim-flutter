import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_rich_text.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_textfield.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/messaging_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/owner_country_picker_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/property_details_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/text_segment_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:share_plus/share_plus.dart';

class PropertyDetailsView extends StatelessWidget {
  PropertyDetailsView({super.key});

  final PropertyDetailsController propertyDetailsController =
      Get.put(PropertyDetailsController());
  final OwnerCountryPickerController ownerCountryPickerController =
      Get.put(OwnerCountryPickerController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final property = propertyDetailsController.currentProperty.value;

      if (property == null) {
        return Scaffold(
          backgroundColor: AppColor.whiteColor,
          appBar: AppBar(
            backgroundColor: AppColor.whiteColor,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: const Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColor.whiteColor,
        appBar: buildAppBar(),
        body: buildPropertyDetails(context),
        bottomNavigationBar: buildButton(),
      );
    });
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppColor.whiteColor,
      scrolledUnderElevation: AppSize.appSize0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Image.asset(Assets.images.backArrow.path),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Obx(() => Text(
            propertyDetailsController.propertyTitle,
            style: AppStyle.heading5Medium(color: AppColor.textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
      actions: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.searchView),
              child: Image.asset(
                Assets.images.search.path,
                width: AppSize.appSize24,
                color: AppColor.descriptionColor,
              ).paddingOnly(right: AppSize.appSize26),
            ),
            GestureDetector(
              onTap: () {
                // Handle save functionality
              },
              child: Image.asset(
                Assets.images.emptyRatingStar.path,
                width: AppSize.appSize24,
                color: AppColor.descriptionColor,
              ).paddingOnly(right: AppSize.appSize26),
            ),
            GestureDetector(
              onTap: () {
                SharePlus.instance.share(ShareParams(
                  text:
                      '${propertyDetailsController.propertyTitle} - ${propertyDetailsController.propertyPrice}',
                ));
              },
              child: Image.asset(
                Assets.images.share.path,
                width: AppSize.appSize24,
              ),
            ),
          ],
        ).paddingOnly(right: AppSize.appSize16),
      ],
      bottom: buildTabBar(),
    );
  }

  PreferredSize buildTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(AppSize.appSize50),
      child: Container(
        height: AppSize.appSize50,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            Row(
              children: List.generate(
                propertyDetailsController.propertyList.length,
                (index) {
                  return GestureDetector(
                    onTap: () =>
                        propertyDetailsController.updateProperty(index),
                    child: Obx(() => Container(
                          height: AppSize.appSize35,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: propertyDetailsController
                                            .selectProperty.value ==
                                        index
                                    ? AppColor.primaryColor
                                    : AppColor.borderColor,
                                width: AppSize.appSize2,
                              ),
                              right: BorderSide(
                                color: index ==
                                        propertyDetailsController
                                                .propertyList.length -
                                            1
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
                },
              ),
            ).paddingOnly(
              top: AppSize.appSize8,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPropertyDetails(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSize.appSize30),
      physics: const ClampingScrollPhysics(),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Main Image
              buildPropertyImage(),

              // Property Basic Info
              buildBasicInfo(),

              // Tab Content - Dynamic based on selection
              buildTabContent(context),

              // Always show these sections regardless of tab
              if (propertyDetailsController.selectProperty.value == 0) ...[
                buildFeatureChips(),
                buildKeyHighlights(context),
                buildPropertyDetailsSection(context),
                buildGallerySection(context),
              ],

              // Facilities and Equipment
              if (propertyDetailsController.selectProperty.value <= 2) ...[
                buildFacilitiesSection(),
                buildEquipmentSection(),
              ],

              // About section
              if (propertyDetailsController.selectProperty.value == 4) ...[
                buildAboutSection(),
              ],

              // Photos section
              if (propertyDetailsController.selectProperty.value == 3) ...[
                buildPhotosSection(context),
              ],

              // Contact and forms (always visible on Overview and Owner tabs)
              if (propertyDetailsController.selectProperty.value == 0 ||
                  propertyDetailsController.selectProperty.value == 5) ...[
                buildVisitTimeSection(),
                buildContactOwnerSection(),
                buildContactForm(context),
                buildMapSection(),
                buildReviewsSection(),
              ],

              // Similar properties (always at bottom)
              buildSimilarPropertiesSection(),
            ],
          )),
    );
  }

  Widget buildPropertyImage() {
    final imagePath = propertyDetailsController.propertyImage;
    final isNetworkImage = imagePath.startsWith('uploads/') ||
        imagePath.startsWith('http://') ||
        imagePath.startsWith('https://');

    return Container(
      height: AppSize.appSize200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        child: isNetworkImage
            ? _buildNetworkImage(imagePath)
            : Image.asset(
                imagePath,
                height: AppSize.appSize200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
      ),
    ).paddingOnly(
      left: AppSize.appSize16,
      right: AppSize.appSize16,
      top: AppSize.appSize10,
    );
  }

  Widget _buildNetworkImage(String imagePath) {
    final fullUrl = imagePath.startsWith('http')
        ? imagePath
        : '${ApiConfig.baseUrl}/$imagePath';

    return Image.network(
      fullUrl,
      height: AppSize.appSize200,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: AppSize.appSize200,
          width: double.infinity,
          color: AppColor.backgroundColor,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColor.primaryColor,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
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
      },
    );
  }

  Widget buildBasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price
        Text(
          propertyDetailsController.propertyPrice,
          style: AppStyle.heading4Medium(color: AppColor.primaryColor),
        ).paddingOnly(
          top: AppSize.appSize16,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),

        // Status and Type
        IntrinsicHeight(
          child: Row(
            children: [
              Text(
                propertyDetailsController.propertyStatus,
                style:
                    AppStyle.heading6Regular(color: AppColor.descriptionColor),
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
                propertyDetailsController.propertyType,
                style:
                    AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
            ],
          ),
        ).paddingOnly(
          top: AppSize.appSize16,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),

        // Title and Address
        Text(
          propertyDetailsController.propertyTitle,
          style: AppStyle.heading5SemiBold(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize8,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),

        Text(
          propertyDetailsController.propertyAddress,
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
      ],
    );
  }

  Widget buildTabContent(BuildContext context) {
    return Obx(() {
      final tabDetails = propertyDetailsController.currentTabDetails;

      if (tabDetails.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(
          top: AppSize.appSize20,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        padding: const EdgeInsets.all(AppSize.appSize16),
        decoration: BoxDecoration(
          color: AppColor.secondaryColor,
          borderRadius: BorderRadius.circular(AppSize.appSize12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              propertyDetailsController
                  .propertyList[propertyDetailsController.selectProperty.value],
              style: AppStyle.heading4Medium(color: AppColor.textColor),
            ),
            const SizedBox(height: AppSize.appSize16),
            ...tabDetails.entries.map((entry) {
              final isLast = entry == tabDetails.entries.last;
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: AppStyle.heading5Regular(
                              color: AppColor.descriptionColor),
                        ),
                      ),
                      const SizedBox(width: AppSize.appSize10),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value.toString(),
                          style: AppStyle.heading5Regular(
                              color: AppColor.textColor),
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: AppSize.appSize12),
                    Divider(
                      color: AppColor.descriptionColor
                          .withValues(alpha: AppSize.appSizePoint4),
                      thickness: AppSize.appSizePoint7,
                      height: AppSize.appSize0,
                    ),
                    const SizedBox(height: AppSize.appSize12),
                  ],
                ],
              );
            }).toList(),
          ],
        ),
      );
    });
  }

  Widget buildFeatureChips() {
    return Obx(() {
      final features = propertyDetailsController.propertyFeatures;
      final additionalFeatures = propertyDetailsController.additionalFeatures;

      return Column(
        children: [
          // Main features
          if (features.isNotEmpty)
            Wrap(
              spacing: AppSize.appSize16,
              children: features
                  .map((feature) =>
                      _buildFeatureChip(feature['icon'], feature['text']))
                  .toList(),
            ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),

          // Additional features
          if (additionalFeatures.isNotEmpty)
            Wrap(
              spacing: AppSize.appSize16,
              children: additionalFeatures
                  .map((feature) =>
                      _buildFeatureChip(feature['icon'], feature['text']))
                  .toList(),
            ).paddingOnly(
              top: AppSize.appSize10,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
        ],
      );
    });
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

  Widget buildKeyHighlights(BuildContext context) {
    return Obx(() {
      final highlights = propertyDetailsController.keyHighlights;

      if (highlights.isEmpty) return const SizedBox.shrink();

      return Container(
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
              'Points forts',
              style: AppStyle.heading4SemiBold(color: AppColor.whiteColor),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: highlights.map((highlight) {
                return Row(
                  children: [
                    Container(
                      width: AppSize.appSize5,
                      height: AppSize.appSize5,
                      margin: const EdgeInsets.only(left: AppSize.appSize10),
                      decoration: const BoxDecoration(
                        color: AppColor.whiteColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        highlight,
                        style: AppStyle.heading5Regular(
                            color: AppColor.whiteColor),
                      ).paddingOnly(left: AppSize.appSize10),
                    ),
                  ],
                ).paddingOnly(top: AppSize.appSize10);
              }).toList(),
            ).paddingOnly(top: AppSize.appSize6),
          ],
        ),
      );
    });
  }

  Widget buildPropertyDetailsSection(BuildContext context) {
    return Obx(() {
      final details = propertyDetailsController.comprehensivePropertyDetails;

      if (details.isEmpty) return const SizedBox.shrink();

      return Container(
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
              'Détails complets de la propriété',
              style: AppStyle.heading4Medium(color: AppColor.textColor),
            ),
            Column(
              children: details.take(10).map((detail) {
                // Show first 10, add "voir plus" if needed
                final isLast = detail == details.take(10).last;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            detail['title']!,
                            style: AppStyle.heading5Regular(
                                color: AppColor.descriptionColor),
                          ).paddingOnly(right: AppSize.appSize10),
                        ),
                        Expanded(
                          child: Text(
                            detail['value']!,
                            style: AppStyle.heading5Regular(
                                color: AppColor.textColor),
                          ),
                        ),
                      ],
                    ),
                    if (!isLast) ...[
                      Divider(
                        color: AppColor.descriptionColor
                            .withValues(alpha: AppSize.appSizePoint4),
                        thickness: AppSize.appSizePoint7,
                        height: AppSize.appSize0,
                      ).paddingOnly(
                          top: AppSize.appSize16, bottom: AppSize.appSize16),
                    ],
                  ],
                );
              }).toList(),
            ).paddingOnly(top: AppSize.appSize16),
            if (details.length > 10)
              TextButton(
                onPressed: () {
                  // Show full details dialog or navigate to details page
                },
                child: Text(
                  'Voir tous les détails (${details.length - 10} de plus)',
                  style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                ),
              ),
          ],
        ).paddingOnly(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
          top: AppSize.appSize16,
          bottom: AppSize.appSize16,
        ),
      );
    });
  }

  Widget buildGallerySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Galerie de la propriété',
          style: AppStyle.heading4SemiBold(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize36,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),

        // Main gallery image
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.galleryView),
          child: Container(
            height: AppSize.appSize150,
            margin: const EdgeInsets.only(top: AppSize.appSize16),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  child: _buildGalleryImage(
                      propertyDetailsController.propertyImages[0]),
                ),
                _buildImageOverlay('Vue principale'),
              ],
            ),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
        ),

        // Gallery thumbnails
        if (propertyDetailsController.propertyImages.length > 1)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.galleryView),
                  child: Container(
                    height: AppSize.appSize150,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                          child: _buildGalleryImage(
                              propertyDetailsController.propertyImages.length >
                                      1
                                  ? propertyDetailsController.propertyImages[1]
                                  : Assets.images.kitchen.path),
                        ),
                        _buildImageOverlay('Cuisine'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSize.appSize16),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.galleryView),
                  child: Container(
                    height: AppSize.appSize150,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                          child: _buildGalleryImage(
                              propertyDetailsController.propertyImages.length >
                                      2
                                  ? propertyDetailsController.propertyImages[2]
                                  : Assets.images.bedroom.path),
                        ),
                        _buildImageOverlay('Chambre'),
                      ],
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
      ],
    );
  }

  Widget _buildGalleryImage(String imagePath) {
    final isNetworkImage = imagePath.startsWith('uploads/') ||
        imagePath.startsWith('http://') ||
        imagePath.startsWith('https://');

    if (!isNetworkImage) {
      return Image.asset(
        imagePath,
        height: AppSize.appSize150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    final fullUrl = imagePath.startsWith('http')
        ? imagePath
        : '${ApiConfig.baseUrl}/$imagePath';

    return Image.network(
      fullUrl,
      height: AppSize.appSize150,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: AppSize.appSize150,
          width: double.infinity,
          color: AppColor.backgroundColor,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColor.primaryColor,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: AppSize.appSize150,
          width: double.infinity,
          color: AppColor.backgroundColor,
          child: Icon(
            Icons.image_not_supported,
            size: AppSize.appSize40,
            color: AppColor.descriptionColor,
          ),
        );
      },
    );
  }

  Widget _buildImageOverlay(String text) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: AppSize.appSize75,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(AppSize.appSize13),
            bottomRight: Radius.circular(AppSize.appSize13),
          ),
          gradient: LinearGradient(
            colors: [Colors.transparent, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Text(
            text,
            style: AppStyle.heading3Medium(color: AppColor.whiteColor),
          ),
        ).paddingOnly(left: AppSize.appSize16, bottom: AppSize.appSize16),
      ),
    );
  }

  Widget buildFacilitiesSection() {
    return Obx(() {
      final facilities = propertyDetailsController.allFacilities;

      if (facilities.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Installations et équipements',
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
              itemCount: facilities.length,
              itemBuilder: (context, index) {
                final facility = facilities[index];
                return Container(
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding: const EdgeInsets.all(AppSize.appSize16),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        facility['icon'],
                        width: AppSize.appSize40,
                      ),
                      Text(
                        facility['title'],
                        style:
                            AppStyle.heading5Regular(color: AppColor.textColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
        ],
      );
    });
  }

  Widget buildEquipmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Équipements de la propriété',
              style: AppStyle.heading4Medium(color: AppColor.textColor),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.furnishingDetailsView),
              child: Text(
                'Voir tout',
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

        // Energy and heating equipment
        Obx(() {
          final energyFacilities = propertyDetailsController.energyFacilities;
          final heatingFacilities =
              propertyDetailsController.heatingCoolingFacilities;
          final allEquipment = [...energyFacilities, ...heatingFacilities];

          if (allEquipment.isEmpty) {
            return Text(
              'Aucun équipement spécifique renseigné',
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ).paddingOnly(
              top: AppSize.appSize16,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            );
          }

          return SizedBox(
            height: AppSize.appSize85,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: allEquipment.length,
              itemBuilder: (context, index) {
                final equipment = allEquipment[index];
                return Container(
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding: const EdgeInsets.all(AppSize.appSize16),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        equipment['icon'],
                        width: AppSize.appSize24,
                      ),
                      Text(
                        equipment['title'],
                        style:
                            AppStyle.heading5Regular(color: AppColor.textColor),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16);
        }),
      ],
    );
  }

  Widget buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'À propos de la propriété',
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
                propertyDetailsController.propertyTitle,
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
                      propertyDetailsController.propertyAddress,
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
              text: propertyDetailsController.propertyDescription.length > 200
                  ? '${propertyDetailsController.propertyDescription.substring(0, 200)}...'
                  : propertyDetailsController.propertyDescription,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ),
            if (propertyDetailsController.propertyDescription.length > 200)
              TextSegment(
                text: ' Lire plus',
                onTap: () => Get.toNamed(AppRoutes.aboutPropertyView,
                    arguments: propertyDetailsController.currentProperty.value),
                style: AppStyle.heading5Regular(color: AppColor.primaryColor),
              ),
          ],
        ).paddingOnly(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      ],
    );
  }

  Widget buildPhotosSection(BuildContext context) {
    return Obx(() {
      final images = propertyDetailsController.propertyImages;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toutes les photos (${images.length})',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize20,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSize.appSize16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSize.appSize16,
              mainAxisSpacing: AppSize.appSize16,
              childAspectRatio: 1.2,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.galleryView),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  child: _buildPhotoGridImage(images[index]),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  Widget _buildPhotoGridImage(String imagePath) {
    final isNetworkImage = imagePath.startsWith('uploads/') ||
        imagePath.startsWith('http://') ||
        imagePath.startsWith('https://');

    if (!isNetworkImage) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
      );
    }

    final fullUrl = imagePath.startsWith('http')
        ? imagePath
        : '${ApiConfig.baseUrl}/$imagePath';

    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColor.backgroundColor,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColor.primaryColor,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColor.backgroundColor,
          child: Icon(
            Icons.broken_image,
            size: AppSize.appSize40,
            color: AppColor.descriptionColor,
          ),
        );
      },
    );
  }

  Widget buildVisitTimeSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Heures de visite',
              style: AppStyle.heading4Medium(color: AppColor.textColor),
            ),
            Text(
              'Ouvert maintenant',
              style: AppStyle.heading5Medium(color: AppColor.positiveColor),
            ),
          ],
        ).paddingOnly(
          top: AppSize.appSize36,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        GestureDetector(
          onTap: () => propertyDetailsController.toggleVisitExpansion(),
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
                      'Lundi',
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
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.only(
                top: propertyDetailsController.isVisitExpanded.value
                    ? AppSize.appSize16
                    : 0,
              ),
              height:
                  propertyDetailsController.isVisitExpanded.value ? null : 0,
              child: propertyDetailsController.isVisitExpanded.value
                  ? Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppSize.appSize16),
                      padding: const EdgeInsets.all(AppSize.appSize16),
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
                      child: Column(
                        children: List.generate(
                          propertyDetailsController.dayList.length,
                          (index) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          ).paddingOnly(bottom: AppSize.appSize10),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            )),
      ],
    );
  }

  Widget buildContactOwnerSection() {
    return Obx(() {
      final owner = propertyDetailsController.currentProperty.value?.utilisateur;
      final hasOwner = owner != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contacter le propriétaire',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize36,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          GestureDetector(
            onTap: () {
              final property = propertyDetailsController.currentProperty.value;
              if (property != null) {
                Get.toNamed(
                  AppRoutes.contactOwnerView,
                  arguments: {
                    'property': property,
                    'similarProperties': propertyDetailsController.similarProperties,
                  },
                );
              }
            },
            child: Container(
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
                  if (hasOwner)
                    CircleAvatar(
                      radius: AppSize.appSize32,
                      backgroundColor: AppColor.primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        owner.fullName.isNotEmpty
                            ? owner.fullName[0].toUpperCase()
                            : 'P',
                        style: AppStyle.heading3SemiBold(color: AppColor.primaryColor),
                      ),
                    ).paddingOnly(right: AppSize.appSize12)
                  else
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
                          hasOwner ? owner.fullName : 'Propriétaire',
                          style: AppStyle.heading4Medium(color: AppColor.textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ).paddingOnly(bottom: AppSize.appSize4),
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Text(
                                hasOwner ? (owner.role ?? 'Propriétaire') : 'Agent',
                                style: AppStyle.heading5Medium(
                                    color: AppColor.descriptionColor),
                              ),
                              if (hasOwner && owner.phoneNumber != null) ...[
                                VerticalDivider(
                                  color: AppColor.descriptionColor
                                      .withValues(alpha: AppSize.appSizePoint4),
                                  thickness: AppSize.appSizePoint7,
                                  width: AppSize.appSize20,
                                  indent: AppSize.appSize2,
                                  endIndent: AppSize.appSize2,
                                ),
                                Expanded(
                                  child: Text(
                                    owner.phoneNumber!,
                                    style: AppStyle.heading5Medium(
                                        color: AppColor.descriptionColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: AppSize.appSize16,
                    color: AppColor.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget buildContactForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact form fields (keeping existing implementation)
        Obx(() => CommonTextField(
              controller: propertyDetailsController.fullNameController,
              focusNode: propertyDetailsController.focusNode,
              hasFocus: propertyDetailsController.hasFullNameFocus.value,
              hasInput: propertyDetailsController.hasFullNameInput.value,
              hintText: 'Nom complet',
              labelText: 'Nom complet',
            )).paddingOnly(
          top: AppSize.appSize16,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),

        // Phone field implementation (keeping existing)
        // Email field implementation (keeping existing)
        // Agent selection (keeping existing)
        // Terms checkbox (keeping existing)

        CommonButton(
          onPressed: () {
            final property = propertyDetailsController.currentProperty.value;
            if (property != null) {
              Get.toNamed(
                AppRoutes.contactOwnerView,
                arguments: {
                  'property': property,
                  'similarProperties': propertyDetailsController.similarProperties,
                },
              );
            } else {
              Get.snackbar(
                'Erreur',
                'Informations de la propriété non disponibles',
                backgroundColor: AppColor.negativeColor,
                colorText: AppColor.whiteColor,
              );
            }
          },
          backgroundColor: AppColor.primaryColor,
          child: Text(
            'Voir le numéro de téléphone',
            style: AppStyle.heading5Medium(color: AppColor.whiteColor),
          ),
        ).paddingOnly(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
          top: AppSize.appSize26,
        ),
      ],
    );
  }

  Widget buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Localisation',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize36,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),

        // Address display with map placeholder
        Obx(() {
          final property = propertyDetailsController.currentProperty.value;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSize.appSize16),
            margin: const EdgeInsets.only(
              top: AppSize.appSize16,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              color: AppColor.secondaryColor,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: AppColor.primaryColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // Map icon
                Container(
                  width: double.infinity,
                  height: AppSize.appSize150,
                  decoration: BoxDecoration(
                    color: AppColor.backgroundColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: AppSize.appSize64,
                        color: AppColor.primaryColor,
                      ),
                      SizedBox(height: AppSize.appSize12),
                      Text(
                        'Carte interactive',
                        style: AppStyle.heading5Medium(
                            color: AppColor.descriptionColor),
                      ),
                      SizedBox(height: AppSize.appSize4),
                      Text(
                        'Bientôt disponible',
                        style: AppStyle.heading6Regular(
                            color: AppColor.descriptionColor),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSize.appSize16),

                // Address details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.place,
                      color: AppColor.primaryColor,
                      size: AppSize.appSize20,
                    ),
                    SizedBox(width: AppSize.appSize8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Adresse',
                            style: AppStyle.heading6Regular(
                                color: AppColor.descriptionColor),
                          ),
                          SizedBox(height: AppSize.appSize4),
                          Text(
                            propertyDetailsController.propertyAddress,
                            style: AppStyle.heading5Medium(
                                color: AppColor.textColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Show detailed location info if available
                if (property != null) ...[
                  SizedBox(height: AppSize.appSize12),
                  Divider(
                    color: AppColor.descriptionColor.withValues(alpha: 0.3),
                  ),
                  SizedBox(height: AppSize.appSize12),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ville',
                              style: AppStyle.heading6Regular(
                                  color: AppColor.descriptionColor),
                            ),
                            SizedBox(height: AppSize.appSize4),
                            Text(
                              property.ville,
                              style: AppStyle.heading6Medium(
                                  color: AppColor.textColor),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSize.appSize16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Code postal',
                              style: AppStyle.heading6Regular(
                                  color: AppColor.descriptionColor),
                            ),
                            SizedBox(height: AppSize.appSize4),
                            Text(
                              property.codePostal,
                              style: AppStyle.heading6Medium(
                                  color: AppColor.textColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (property.departement.isNotEmpty) ...[
                    SizedBox(height: AppSize.appSize12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Département',
                          style: AppStyle.heading6Regular(
                              color: AppColor.descriptionColor),
                        ),
                        SizedBox(height: AppSize.appSize4),
                        Text(
                          property.departement,
                          style: AppStyle.heading6Medium(
                              color: AppColor.textColor),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget buildReviewsSection() {
    final reviews = propertyDetailsController.reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Avis',
              style: AppStyle.heading3SemiBold(color: AppColor.textColor),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.addReviewsForPropertyView),
              child: Text(
                'Ajouter un avis',
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
          itemCount: reviews.length,
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Container(
              margin: const EdgeInsets.only(bottom: AppSize.appSize16),
              padding: const EdgeInsets.all(AppSize.appSize16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.appSize16),
                border: Border.all(color: AppColor.descriptionColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        review['date'],
                        style: AppStyle.heading6Regular(
                            color: AppColor.descriptionColor),
                      ),
                      Image.asset(
                        review['rating'],
                        width: AppSize.appSize122,
                        height: AppSize.appSize18,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Image.asset(
                        review['profile'],
                        width: AppSize.appSize36,
                      ),
                      Text(
                        review['name'],
                        style: AppStyle.heading5Medium(
                            color: AppColor.textColor),
                      ).paddingOnly(left: AppSize.appSize6),
                    ],
                  ).paddingOnly(top: AppSize.appSize10),
                  Text(
                    review['type'],
                    style: AppStyle.heading5Medium(
                        color: AppColor.descriptionColor),
                  ).paddingOnly(top: AppSize.appSize10),
                  Text(
                    review['description'],
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
      ],
    );
  }

  Widget buildSimilarPropertiesSection() {
    return Obx(() {
      final similarProperties = propertyDetailsController.similarProperties;

      print('🏘️ Building similar properties section, count: ${similarProperties.length}');

      if (similarProperties.isEmpty) {
        print('⚠️ No similar properties to display');
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Propriétés similaires',
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
              itemCount: similarProperties.length,
              itemBuilder: (context, index) {
                final similarProperty = similarProperties[index];
                return GestureDetector(
                  onTap: () => Get.off(() => PropertyDetailsView(),
                      arguments: similarProperty),
                  child: Container(
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
                              borderRadius:
                                  BorderRadius.circular(AppSize.appSize8),
                              child: _buildSimilarPropertyImage(similarProperty),
                            ),
                            Positioned(
                              right: AppSize.appSize6,
                              top: AppSize.appSize6,
                              child: GestureDetector(
                                onTap: () => propertyDetailsController
                                    .toggleSimilarPropertyLike(index),
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
                              similarProperty.displayTitle,
                              style: AppStyle.heading5SemiBold(
                                  color: AppColor.textColor),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              similarProperty.displayAddress,
                              style: AppStyle.heading5Regular(
                                  color: AppColor.descriptionColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).paddingOnly(top: AppSize.appSize6),
                          ],
                        ).paddingOnly(top: AppSize.appSize8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              similarProperty.formattedPrice,
                              style: AppStyle.heading5Medium(
                                  color: AppColor.primaryColor),
                            ),
                            Row(
                              children: [
                                Text(
                                  similarProperty.calculatedRating
                                      .toStringAsFixed(1),
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
                                .withValues(alpha: AppSize.appSizePoint3)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (similarProperty.nombreChambres > 0)
                              _buildFeatureChip(Assets.images.bed.path,
                                  '${similarProperty.nombreChambres}'),
                            if (similarProperty.nombreSallesDeBain > 0)
                              _buildFeatureChip(Assets.images.bath.path,
                                  '${similarProperty.nombreSallesDeBain}'),
                            _buildFeatureChip(Assets.images.plot.path,
                                similarProperty.formattedSurface),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
        ],
      );
    });
  }

  Widget buildButton() {
    return CommonButton(
      onPressed: () async {
        final property = propertyDetailsController.currentProperty.value;
        if (property?.id == null) {
          Get.snackbar(
            'Erreur',
            'Impossible de créer la conversation',
            backgroundColor: AppColor.negativeColor,
            colorText: AppColor.whiteColor,
          );
          return;
        }

        // Get or create messaging controller
        final messagingController = Get.put(MessagingController());

        // Create or get existing conversation
        final conversation = await messagingController.createConversation(
          propertyId: property!.id!,
          initialMessage: 'Bonjour, je suis intéressé par cette propriété.',
        );

        if (conversation != null) {
          // Navigate to chat view
          Get.toNamed(
            AppRoutes.chatView,
            arguments: {
              'conversationId': conversation.id,
              'propertyTitle': property.titre ?? 'Propriété',
            },
          );
        }
      },
      backgroundColor: AppColor.primaryColor,
      child: Text(
        'Contacter le propriétaire',
        style: AppStyle.heading5Medium(color: AppColor.whiteColor),
      ),
    ).paddingOnly(
      left: AppSize.appSize16,
      right: AppSize.appSize16,
      bottom: AppSize.appSize26,
      top: AppSize.appSize10,
    );
  }

  Widget _buildSimilarPropertyImage(dynamic similarProperty) {
    // Get the first image from the property
    if (similarProperty.listeImages == null ||
        similarProperty.listeImages.isEmpty) {
      // No image available
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

    String imagePath = similarProperty.listeImages.first;
    print('📸 Similar property image path: $imagePath');

    // Check if it's already a full URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      print('🌐 Loading from full URL: $imagePath');
      return Image.network(
        imagePath,
        height: AppSize.appSize200,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: AppSize.appSize200,
            width: double.infinity,
            color: AppColor.backgroundColor,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColor.primaryColor,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          print('❌ Error loading image from: $imagePath');
          print('Error: $error');
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
        },
      );
    }

    // It's a relative path from server, build the full URL
    final fullUrl = '${ApiConfig.baseUrl}/$imagePath';
    print('🔗 Loading from server: $fullUrl');

    return Image.network(
      fullUrl,
      height: AppSize.appSize200,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: AppSize.appSize200,
          width: double.infinity,
          color: AppColor.backgroundColor,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColor.primaryColor,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ Error loading image from: $fullUrl');
        print('Error: $error');
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
      },
    );
  }
}
