import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

/// Updated manage property bottom sheet that accepts property data
managePropertyBottomSheet(
  BuildContext context, {
  Map<String, dynamic>? property,
}) {
  // Extract property information with fallbacks for backward compatibility
  String propertyId = property != null ? _getPropertyId(property) : '';
  String propertyTitle =
      property != null ? _getPropertyTitle(property) : AppString.sellFlat;
  String propertyAddress = property != null
      ? _getPropertyAddress(property)
      : AppString.northBombaySociety;
  String propertyImage = property != null
      ? _getPropertyImage(property)
      : Assets.images.property1.path;
  String propertyPrice =
      property != null ? _getPropertyPrice(property) : AppString.rupees50Lakh;

  showModalBottomSheet(
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
        height: AppSize.appSize315,
        padding: const EdgeInsets.only(
          top: AppSize.appSize26,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        decoration: const BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSize.appSize12),
            topRight: Radius.circular(AppSize.appSize12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppString.manageProperty,
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

            // Property Info Card
            Row(
              children: [
                Container(
                  width: AppSize.appSize70,
                  height: AppSize.appSize70,
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSize.appSize6),
                    color: AppColor.backgroundColor,
                  ),
                  child: _buildPropertyImageWidget(propertyImage),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        propertyTitle,
                        style: AppStyle.heading5SemiBold(
                            color: AppColor.textColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        propertyAddress,
                        style: AppStyle.heading5Regular(
                            color: AppColor.descriptionColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ).paddingOnly(top: AppSize.appSize4),
                      Text(
                        propertyPrice,
                        style: AppStyle.heading5Medium(
                            color: AppColor.primaryColor),
                      ).paddingOnly(top: AppSize.appSize2),
                    ],
                  ),
                ),
              ],
            ).paddingOnly(top: AppSize.appSize26),

            // Action Buttons
            Column(
              children: [
                // Preview Button
                GestureDetector(
                  onTap: () {
                    Get.back();
                    if (propertyId.isNotEmpty) {
                      // Navigate to property details with the property ID
                      Get.toNamed(
                        AppRoutes.showPropertyDetailsView,
                        arguments: propertyId,
                      );
                    } else {
                      // Fallback for backward compatibility
                      Get.toNamed(AppRoutes.showPropertyDetailsView);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppString.preview,
                          style: AppStyle.heading4Medium(
                              color: AppColor.textColor),
                        ),
                        Image.asset(
                          Assets.images.arrowRight.path,
                          width: AppSize.appSize20,
                        ),
                      ],
                    ),
                  ),
                ),

                Divider(
                  color: AppColor.descriptionColor
                      .withValues(alpha: AppSize.appSizePoint3),
                  height: AppSize.appSize0,
                  thickness: AppSize.appSizePoint7,
                ).paddingOnly(
                    top: AppSize.appSize15, bottom: AppSize.appSize15),

                // Edit Details Button
                GestureDetector(
                  onTap: () {
                    Get.back();
                    if (propertyId.isNotEmpty) {
                      // Navigate to edit property with property ID
                      Get.toNamed(
                        AppRoutes.editPropertyView,
                        arguments: propertyId,
                      );
                    } else {
                      // Fallback for backward compatibility
                      Get.toNamed(AppRoutes.editPropertyView);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppString.editDetails,
                          style: AppStyle.heading4Medium(
                              color: AppColor.textColor),
                        ),
                        Image.asset(
                          Assets.images.arrowRight.path,
                          width: AppSize.appSize20,
                        ),
                      ],
                    ),
                  ),
                ),

                Divider(
                  color: AppColor.descriptionColor
                      .withValues(alpha: AppSize.appSizePoint3),
                  height: AppSize.appSize0,
                  thickness: AppSize.appSizePoint7,
                ).paddingOnly(
                    top: AppSize.appSize15, bottom: AppSize.appSize15),

                // Delete Property Button
                GestureDetector(
                  onTap: () {
                    Get.back();
                    if (propertyId.isNotEmpty) {
                      // Navigate to delete listing with property data
                      Get.toNamed(
                        AppRoutes.deleteListingView,
                        arguments: {
                          'propertyId': propertyId,
                          'propertyTitle': propertyTitle,
                          'propertyAddress': propertyAddress,
                          'propertyImage': propertyImage,
                        },
                      );
                    } else {
                      // Fallback for backward compatibility
                      Get.toNamed(AppRoutes.deleteListingView);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppString.deleteProperty,
                          style: AppStyle.heading4Medium(
                              color: AppColor.negativeColor),
                        ),
                        Image.asset(
                          Assets.images.arrowRight.path,
                          width: AppSize.appSize20,
                          color: AppColor.negativeColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ).paddingOnly(top: AppSize.appSize26),
          ],
        ),
      ).paddingOnly(bottom: MediaQuery.of(context).viewInsets.bottom);
    },
  );
}

/// Helper functions to extract property data
String _getPropertyId(Map<String, dynamic> property) {
  try {
    // Handle MongoDB ObjectId format: { "$oid": "..." }
    if (property['_id'] is Map) {
      return property['_id']['\$oid']?.toString() ?? '';
    }
    // Handle direct string format
    return property['_id']?.toString() ?? property['id']?.toString() ?? '';
  } catch (e) {
    print('Error getting property ID: $e');
    return '';
  }
}

String _getPropertyTitle(Map<String, dynamic> property) {
  try {
    // Try description.titre first
    if (property['description'] != null &&
        property['description']['titre'] != null &&
        property['description']['titre'].toString().isNotEmpty) {
      return property['description']['titre'].toString();
    }

    // Fallback to type + number of rooms
    String type = property['typeBien']?.toString() ?? 'Bien immobilier';
    int rooms = property['nombrePiecesTotal']?.toInt() ?? 0;

    if (rooms > 0) {
      return '$type ${rooms}P';
    }

    return type;
  } catch (e) {
    print('Error getting property title: $e');
    return 'Bien immobilier';
  }
}

String _getPropertyAddress(Map<String, dynamic> property) {
  try {
    if (property['localisation'] == null) {
      return 'Adresse non spécifiée';
    }

    Map<String, dynamic> localisation = property['localisation'];
    List<String> addressParts = [];

    if (localisation['rue'] != null &&
        localisation['rue'].toString().isNotEmpty) {
      addressParts.add(localisation['rue'].toString());
    }

    if (localisation['ville'] != null &&
        localisation['ville'].toString().isNotEmpty) {
      addressParts.add(localisation['ville'].toString());
    }

    if (localisation['codePostal'] != null &&
        localisation['codePostal'].toString().isNotEmpty) {
      addressParts.add(localisation['codePostal'].toString());
    }

    return addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'Adresse non spécifiée';
  } catch (e) {
    print('Error getting property address: $e');
    return 'Adresse non spécifiée';
  }
}

String _getPropertyPrice(Map<String, dynamic> property) {
  try {
    if (property['prix'] != null && property['prix']['hai'] != null) {
      double price = property['prix']['hai'].toDouble();

      if (price >= 1000000) {
        return '${(price / 1000000).toStringAsFixed(1)}M €';
      } else if (price >= 1000) {
        return '${(price / 1000).toStringAsFixed(0)}K €';
      } else {
        return '${price.toStringAsFixed(0)} €';
      }
    }

    return 'Prix sur demande';
  } catch (e) {
    print('Error getting property price: $e');
    return 'Prix sur demande';
  }
}

String _getPropertyImage(Map<String, dynamic> property) {
  try {
    // If the property has images, return the first one
    if (property['listeImages'] != null &&
        property['listeImages'] is List &&
        (property['listeImages'] as List).isNotEmpty) {
      return (property['listeImages'] as List).first.toString();
    }

    // Fallback to asset images based on property type
    String type = property['typeBien']?.toString().toLowerCase() ?? '';
    switch (type) {
      case 'appartement':
        return Assets.images.listing1.path;
      case 'maison':
        return Assets.images.listing2.path;
      case 'terrain':
        return Assets.images.listing3.path;
      default:
        return Assets.images.listing4.path;
    }
  } catch (e) {
    print('Error getting property image: $e');
    return Assets.images.listing1.path;
  }
}

Widget _buildPropertyImageWidget(String imagePath) {
  // Check if it's a network image or asset
  if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSize.appSize6),
      child: Image.network(
        imagePath,
        width: AppSize.appSize70,
        height: AppSize.appSize70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImageWidget();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImagePlaceholderWidget();
        },
      ),
    );
  } else {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSize.appSize6),
      child: Image.asset(
        imagePath,
        width: AppSize.appSize70,
        height: AppSize.appSize70,
        fit: BoxFit.cover,
      ),
    );
  }
}

Widget _buildFallbackImageWidget() {
  return Container(
    width: AppSize.appSize70,
    height: AppSize.appSize70,
    decoration: BoxDecoration(
      color: AppColor.backgroundColor,
      borderRadius: BorderRadius.circular(AppSize.appSize6),
    ),
    child: Icon(
      Icons.home_outlined,
      size: AppSize.appSize30,
      color: AppColor.descriptionColor,
    ),
  );
}

Widget _buildImagePlaceholderWidget() {
  return Container(
    width: AppSize.appSize70,
    height: AppSize.appSize70,
    decoration: BoxDecoration(
      color: AppColor.backgroundColor,
      borderRadius: BorderRadius.circular(AppSize.appSize6),
    ),
    child: const Center(
      child: CircularProgressIndicator(),
    ),
  );
}
