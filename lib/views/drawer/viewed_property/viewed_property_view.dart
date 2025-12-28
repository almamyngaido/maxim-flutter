import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/cached_network_image_widget.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/favoris_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/viewed_property_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class ViewedPropertyView extends StatelessWidget {
  ViewedPropertyView({super.key});

  final ViewedPropertyController viewedPropertyController =
      Get.put(ViewedPropertyController());

  final FavorisController favorisController = Get.put(FavorisController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: Obx(() {
        if (viewedPropertyController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColor.primaryColor,
            ),
          );
        }

        if (viewedPropertyController.viewedProperties.isEmpty) {
          return buildEmptyState();
        }

        return buildViewedPropertyList();
      }),
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
      title: Obx(() => Text(
            '${AppString.viewedProperties} (${viewedPropertyController.viewedProperties.length})',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          )),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            Assets.images.emptyRatingStar.path,
            width: AppSize.appSize80,
            height: AppSize.appSize80,
          ),
          const SizedBox(height: AppSize.appSize20),
          Text(
            'Aucun bien visité',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),
          const SizedBox(height: AppSize.appSize10),
          Text(
            'Les biens que vous consultez apparaîtront ici',
            style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
            textAlign: TextAlign.center,
          ).paddingSymmetric(horizontal: AppSize.appSize40),
        ],
      ),
    );
  }

  Widget buildViewedPropertyList() {
    return RefreshIndicator(
      onRefresh: () => viewedPropertyController.loadViewedProperties(),
      color: AppColor.primaryColor,
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.only(
          bottom: AppSize.appSize20,
          top: AppSize.appSize10,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: viewedPropertyController.viewedProperties.length,
        itemBuilder: (context, index) {
          final property = viewedPropertyController.viewedProperties[index];
          return buildPropertyCard(property);
        },
      ),
    );
  }

  Widget buildPropertyCard(BienImmo property) {
    // Get first image URL
    String? imageUrl;
    if (property.listeImages.isNotEmpty) {
      imageUrl = '${ApiConfig.baseUrl}/bien-immos/${property.id}/images/${property.listeImages[0]}';
    }

    // Format price
    final formattedPrice = '${property.prixHAI.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]} ',
        )} €';

    // Get property type display
    String propertyTypeDisplay = property.typeBien;

    // Build address string using the displayAddress helper
    String address = property.displayAddress;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.propertyDetailsView,
          arguments: property,
        );
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
          children: [
            // Property Image with Favorite Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.appSize8),
                  child: imageUrl != null
                      ? CachedNetworkImageWidget(
                          imageUrl: imageUrl,
                          height: 200,
                          width: double.infinity,
                        )
                      : Container(
                          height: 200,
                          width: double.infinity,
                          color: AppColor.descriptionColor.withValues(alpha: 0.3),
                          child: Center(
                            child: Icon(
                              Icons.home,
                              size: 60,
                              color: AppColor.descriptionColor,
                            ),
                          ),
                        ),
                ),
                Positioned(
                  right: AppSize.appSize6,
                  top: AppSize.appSize6,
                  child: GestureDetector(
                    onTap: () {
                      if (property.id != null) {
                        favorisController.toggleFavori(property.id!);
                      }
                    },
                    child: Container(
                      width: AppSize.appSize32,
                      height: AppSize.appSize32,
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor
                            .withValues(alpha: AppSize.appSizePoint50),
                        borderRadius: BorderRadius.circular(AppSize.appSize6),
                      ),
                      child: Center(
                        child: Obx(() {
                          final isFavorite =
                              favorisController.estEnFavori(property.id ?? '');
                          return Image.asset(
                            isFavorite
                                ? Assets.images.ratingStar.path
                                : Assets.images.emptyRatingStar.path,
                            width: AppSize.appSize24,
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Property Type
            if (propertyTypeDisplay.isNotEmpty)
              Text(
                propertyTypeDisplay,
                style: AppStyle.heading6Regular(color: AppColor.primaryColor),
              ).paddingOnly(top: AppSize.appSize16),

            // Property Title
            Text(
              property.titre.isNotEmpty ? property.titre : 'Sans titre',
              style: AppStyle.heading5SemiBold(color: AppColor.textColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ).paddingOnly(top: AppSize.appSize6),

            // Address
            if (address.isNotEmpty)
              Text(
                address,
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).paddingOnly(top: AppSize.appSize6),

            // Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedPrice,
                  style: AppStyle.heading5Medium(color: AppColor.primaryColor),
                ),
              ],
            ).paddingOnly(top: AppSize.appSize16),

            // Property Details (bedrooms, bathrooms, surface)
            if (property.chambres != null ||
                property.salleDeBain != null)
              Column(
                children: [
                  Divider(
                    color: AppColor.descriptionColor
                        .withValues(alpha: AppSize.appSizePoint3),
                    height: AppSize.appSize0,
                  ).paddingOnly(
                      top: AppSize.appSize16, bottom: AppSize.appSize16),
                  Row(
                    children: [
                      if (property.chambres != null && property.chambres! > 0)
                        _buildDetailChip(
                          Assets.images.bed.path,
                          '${property.chambres}',
                        ),
                      if (property.salleDeBain != null &&
                          property.salleDeBain! > 0)
                        _buildDetailChip(
                          Assets.images.bath.path,
                          '${property.salleDeBain}',
                        ).paddingOnly(
                            left: (property.chambres != null &&
                                    property.chambres! > 0)
                                ? AppSize.appSize12
                                : 0),
                      _buildDetailChip(
                        Assets.images.plot.path,
                        '${property.surfaceHabitable.toInt()} m²',
                      ).paddingOnly(
                          left: ((property.chambres != null &&
                                      property.chambres! > 0) ||
                                  (property.salleDeBain != null &&
                                      property.salleDeBain! > 0))
                              ? AppSize.appSize12
                              : 0),
                    ],
                  ),
                ],
              ),

          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String iconPath, String text) {
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
