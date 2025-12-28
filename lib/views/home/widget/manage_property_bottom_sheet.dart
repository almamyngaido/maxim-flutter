import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/cached_network_image_widget.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

managePropertyBottomSheet(
  BuildContext context, {
  Map<String, dynamic>? property,
}) {
  print('🚀 DEBUG: managePropertyBottomSheet called');
  print('🔍 DEBUG: Property parameter is null: ${property == null}');

  if (property != null) {
    print('🔍 DEBUG: Property data keys: ${property.keys}');
    print('🔍 DEBUG: Full property data: $property');
  } else {
    print('❌ DEBUG: No property data provided to bottom sheet!');
  }

  // Extract property information with debugging
  String propertyId = property != null ? _getPropertyId(property) : '';
  String propertyTitle =
      property != null ? _getPropertyTitle(property) : AppString.sellFlat;
  String propertyAddress = property != null
      ? _getPropertyAddress(property)
      : AppString.northBombaySociety;
  String propertyImage = property != null ? _getPropertyImage(property) : '';
  String propertyPrice =
      property != null ? _getPropertyPrice(property) : AppString.rupees50Lakh;

  print('📋 DEBUG: Extracted values:');
  print('   Property ID: "$propertyId"');
  print('   Property Title: "$propertyTitle"');
  print('   Property Address: "$propertyAddress"');
  print('   Property Price: "$propertyPrice"');

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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
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
        child: SingleChildScrollView(
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
                    child: PropertyImageWidget(
                      imageUrl: propertyImage,
                      width: AppSize.appSize70,
                      height: AppSize.appSize70,
                      borderRadius: BorderRadius.circular(AppSize.appSize6),
                    ),
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
                  // Preview Button with Enhanced Debugging
                  GestureDetector(
                    onTap: () {
                      print('🔍 DEBUG: Preview button tapped');
                      print('🔍 DEBUG: Property ID value: "$propertyId"');
                      print(
                          '🔍 DEBUG: Property ID is empty: ${propertyId.isEmpty}');

                      Get.back();

                      if (propertyId.isNotEmpty) {
                        print(
                            '✅ DEBUG: Navigating to property details with ID: "$propertyId"');
                        Get.toNamed(
                          AppRoutes.showPropertyDetailsView,
                          arguments: propertyId,
                        );
                      } else {
                        print(
                            '❌ DEBUG: Cannot navigate - property ID is empty');
                        print('🔍 DEBUG: Showing error message to user');

                        Get.snackbar(
                          'Erreur',
                          'ID de propriété manquant. Données reçues: ${property?.keys}',
                          backgroundColor: AppColor.negativeColor,
                          colorText: AppColor.whiteColor,
                          duration: Duration(seconds: 5),
                        );
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

                  // Edit Details Button with Enhanced Debugging
                  GestureDetector(
                    onTap: () {
                      print('🔍 DEBUG: Edit button tapped');
                      print('🔍 DEBUG: Property ID value: "$propertyId"');

                      Get.back();

                      if (propertyId.isNotEmpty) {
                        print(
                            '✅ DEBUG: Navigating to edit property with ID: "$propertyId"');
                        Get.toNamed(
                          AppRoutes.editPropertyView,
                          arguments: propertyId,
                        );
                      } else {
                        print(
                            '❌ DEBUG: Cannot navigate to edit - property ID is empty');
                        Get.snackbar(
                          'Erreur',
                          'ID de propriété manquant pour l\'édition',
                          backgroundColor: AppColor.negativeColor,
                          colorText: AppColor.whiteColor,
                        );
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

                  // Delete Property Button with Enhanced Debugging
                  GestureDetector(
                    onTap: () {
                      print('🔍 DEBUG: Delete button tapped');
                      print('🔍 DEBUG: Property ID value: "$propertyId"');

                      Get.back();

                      if (propertyId.isNotEmpty) {
                        print(
                            '✅ DEBUG: Navigating to delete listing with property data');
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
                        print(
                            '❌ DEBUG: Cannot navigate to delete - property ID is empty');
                        Get.snackbar(
                          'Erreur',
                          'ID de propriété manquant pour la suppression',
                          backgroundColor: AppColor.negativeColor,
                          colorText: AppColor.whiteColor,
                        );
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
        ),
      ).paddingOnly(bottom: MediaQuery.of(context).viewInsets.bottom);
    },
  );
}

String _getPropertyId(Map<String, dynamic> property) {
  try {
    print('🔍 DEBUG: _getPropertyId called');
    print('🔍 DEBUG: Property parameter keys: ${property.keys}');
    print('🔍 DEBUG: Property _id field type: ${property['_id']?.runtimeType}');
    print('🔍 DEBUG: Property _id value: ${property['_id']}');

    String propertyId = '';

    // Handle MongoDB ObjectId format: { "$oid": "..." }
    if (property['_id'] is Map) {
      print('🔍 DEBUG: _id is Map type');
      Map<String, dynamic> idMap = property['_id'] as Map<String, dynamic>;
      print('🔍 DEBUG: _id Map contents: $idMap');
      print('🔍 DEBUG: _id Map keys: ${idMap.keys}');

      if (idMap['\$oid'] != null) {
        propertyId = idMap['\$oid'].toString();
        print('✅ DEBUG: Found MongoDB ObjectId: "$propertyId"');
      } else {
        print('❌ DEBUG: _id is Map but no \$oid field found');
        print('🔍 DEBUG: Available keys in _id Map: ${idMap.keys}');
      }
    }
    // Handle direct string format
    else if (property['_id'] != null) {
      propertyId = property['_id'].toString();
      print('✅ DEBUG: Found direct _id: "$propertyId"');
    }
    // Fallback to 'id' field
    else if (property['id'] != null) {
      propertyId = property['id'].toString();
      print('✅ DEBUG: Found id field: "$propertyId"');
    } else {
      print('❌ DEBUG: No ID field found in property data');
      print('🔍 DEBUG: All available fields:');
      property.forEach((key, value) {
        print('   "$key": ${value.runtimeType} = $value');
      });
    }

    print('📤 DEBUG: _getPropertyId returning: "$propertyId"');
    return propertyId;
  } catch (e) {
    print('❌ DEBUG: Exception in _getPropertyId: $e');
    print('❌ DEBUG: Property data that caused error: $property');
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
    // Check if property has images
    if (property['listeImages'] != null &&
        property['listeImages'] is List &&
        (property['listeImages'] as List).isNotEmpty) {
      String imagePath = (property['listeImages'] as List).first.toString();

      print('🖼️ DEBUG: Raw image path from API: "$imagePath"');

      // If already a full URL, return as-is
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        print('✅ DEBUG: Image is already a full URL');
        return imagePath;
      }

      // Otherwise, construct full URL from relative path
      // Example: "uploads/bien-immos/123.png" -> "http://192.168.1.4:3000/uploads/bien-immos/123.png"
      String fullUrl = '${ApiConfig.baseUrl}/$imagePath';
      print('✅ DEBUG: Constructed full image URL: "$fullUrl"');
      return fullUrl;
    }

    print('⚠️ DEBUG: No images found in listeImages, will show fallback');
    // Return empty string so PropertyImageWidget shows fallback
    return '';
  } catch (e) {
    print('❌ DEBUG: Error getting property image: $e');
    return '';
  }
}

