import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';

import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/show_property_details_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class ShowPropertyDetailsView extends StatelessWidget {
  ShowPropertyDetailsView({super.key});

  final ShowPropertyDetailsController showPropertyDetailsController =
      Get.put(ShowPropertyDetailsController());

  @override
  Widget build(BuildContext context) {
    showPropertyDetailsController.isSimilarPropertyLiked.value =
        List<bool>.generate(
            showPropertyDetailsController.searchImageList.length,
            (index) => false);
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildShowPropertyDetails(context),
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
        Padding(
          padding: const EdgeInsets.only(right: AppSize.appSize16),
          child: GestureDetector(
            onTap: () {
              // TODO: Navigate to edit property with current property ID
              Get.toNamed(AppRoutes.editPropertyView);
            },
            child: Image.asset(
              Assets.images.edit.path,
              width: AppSize.appSize24,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildShowPropertyDetails(BuildContext context) {
    return Obx(() {
      // Handle loading state
      if (showPropertyDetailsController.isLoadingProperty.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColor.primaryColor),
              SizedBox(height: AppSize.appSize16),
              Text(
                'Chargement des détails...',
                style:
                    AppStyle.heading4Regular(color: AppColor.descriptionColor),
              ),
            ],
          ),
        );
      }

      // Handle error state
      if (showPropertyDetailsController.hasError.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: AppSize.appSize60,
                color: AppColor.negativeColor,
              ),
              SizedBox(height: AppSize.appSize16),
              Text(
                'Erreur de chargement',
                style: AppStyle.heading3SemiBold(color: AppColor.textColor),
              ),
              SizedBox(height: AppSize.appSize8),
              Text(
                showPropertyDetailsController.errorMessage.value,
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor),
                textAlign: TextAlign.center,
              ).paddingSymmetric(horizontal: AppSize.appSize32),
              SizedBox(height: AppSize.appSize24),
              ElevatedButton(
                onPressed: () =>
                    showPropertyDetailsController.refreshPropertyData(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  foregroundColor: AppColor.whiteColor,
                ),
                child: Text('Réessayer'),
              ),
            ],
          ),
        );
      }

      // Handle empty property data
      if (showPropertyDetailsController.propertyData.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.home_outlined,
                size: AppSize.appSize80,
                color: AppColor.descriptionColor,
              ),
              SizedBox(height: AppSize.appSize16),
              Text(
                'Aucune donnée disponible',
                style: AppStyle.heading3SemiBold(color: AppColor.textColor),
              ),
              SizedBox(height: AppSize.appSize8),
              Text(
                'Les détails de cette propriété ne sont pas disponibles',
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      // Main content when data is loaded
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: AppSize.appSize30),
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Container(
              height: AppSize.appSize200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                color: AppColor.backgroundColor,
              ),
              child: _buildPropertyImage(),
            ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),

            // Price
            Text(
              showPropertyDetailsController.propertyPrice,
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
                    showPropertyDetailsController.propertyStatus,
                    style: AppStyle.heading6Regular(
                        color: AppColor.descriptionColor),
                  ),
                  VerticalDivider(
                    color: AppColor.descriptionColor.withOpacity(0.4),
                    thickness: 0.7,
                    width: AppSize.appSize22,
                    indent: AppSize.appSize2,
                    endIndent: AppSize.appSize2,
                  ),
                  Text(
                    showPropertyDetailsController.propertyType,
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

            // Title
            Text(
              showPropertyDetailsController.propertyTitle,
              style: AppStyle.heading5SemiBold(color: AppColor.textColor),
            ).paddingOnly(
              top: AppSize.appSize8,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),

            // Address
            Text(
              showPropertyDetailsController.propertyAddress,
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ).paddingOnly(
              top: AppSize.appSize4,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),

            // Divider
            Divider(
              color: AppColor.descriptionColor.withOpacity(0.4),
              thickness: 0.7,
              height: AppSize.appSize0,
            ).paddingOnly(
              top: AppSize.appSize16,
              bottom: AppSize.appSize16,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),

            // Property Features (rooms, etc.)
            _buildPropertyFeatures()
                .paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),

            // Key Highlights
            _buildKeyHighlights(),

            // Property Details Section
            _buildPropertyDetailsSection(),

            // Description Section
            _buildDescriptionSection(),

            // Gallery Section
            _buildGallerySection(context),

            // Contact Owner Section
            _buildContactOwnerSection(),

            // Map Section
            _buildMapSection(),

            // Similar Properties Section
            _buildSimilarPropertiesSection(),

            // Interesting Reads Section
            _buildInterestingReadsSection(),
          ],
        ).paddingOnly(top: AppSize.appSize10),
      );
    });
  }

  Widget _buildPropertyImage() {
    final imageUrl = showPropertyDetailsController.primaryImage;

    if (imageUrl.startsWith('http') || imageUrl.startsWith('https')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: AppSize.appSize200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildImagePlaceholder();
          },
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        child: Image.asset(
          imageUrl,
          width: double.infinity,
          height: AppSize.appSize200,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  Widget _buildFallbackImage() {
    return Container(
      width: double.infinity,
      height: AppSize.appSize200,
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
      ),
      child: Icon(
        Icons.home_outlined,
        size: AppSize.appSize60,
        color: AppColor.descriptionColor,
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: AppSize.appSize200,
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
      ),
      child: Center(
        child: CircularProgressIndicator(color: AppColor.primaryColor),
      ),
    );
  }

  Widget _buildPropertyFeatures() {
    final surfaces = showPropertyDetailsController.surfaces;
    final pieces = showPropertyDetailsController.pieces;

    List<Widget> features = [];

    // Add number of rooms
    if (showPropertyDetailsController.numberOfRooms > 0) {
      features.add(_buildFeatureChip(
        Assets.images.bed.path,
        '${showPropertyDetailsController.numberOfRooms}P',
      ));
    }

    // Add surface area
    if (surfaces['habitable'] != null) {
      features.add(_buildFeatureChip(
        Assets.images.plot.path,
        '${surfaces['habitable'].toInt()} m²',
      ));
    }

    // Add number of bedrooms from pieces
    int bedrooms = pieces.where((piece) => piece['type'] == 'chambre').length;
    if (bedrooms > 0) {
      features.add(_buildFeatureChip(
        Assets.images.bed.path,
        '$bedrooms Ch.',
      ));
    }

    if (features.isEmpty) {
      return SizedBox.shrink();
    }

    return Row(
      children: features
          .take(3)
          .map((feature) => Padding(
                padding: const EdgeInsets.only(right: AppSize.appSize16),
                child: feature,
              ))
          .toList(),
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
          width: 0.5,
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

  Widget _buildKeyHighlights() {
    final characteristics = showPropertyDetailsController.characteristics;
    List<String> highlights = [];

    // Add characteristics that are true
    characteristics.forEach((key, value) {
      if (value == true) {
        String displayName = _getCharacteristicDisplayName(key);
        highlights.add(displayName);
      }
    });

    // Add default highlights if none from characteristics
    if (highlights.isEmpty) {
      highlights = showPropertyDetailsController.keyHighlightsTitleList;
    }

    return Container(
      width: double.infinity,
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
            children: highlights.take(6).map((highlight) {
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
                      style:
                          AppStyle.heading5Regular(color: AppColor.whiteColor),
                    ).paddingOnly(left: AppSize.appSize10),
                  ),
                ],
              ).paddingOnly(top: AppSize.appSize10);
            }).toList(),
          ).paddingOnly(top: AppSize.appSize6),
        ],
      ),
    );
  }

  String _getCharacteristicDisplayName(String key) {
    switch (key) {
      case 'jardin':
        return 'Jardin disponible';
      case 'terrasse':
        return 'Terrasse disponible';
      case 'balcon':
        return 'Balcon disponible';
      case 'piscine':
        return 'Piscine disponible';
      case 'ascenseur':
        return 'Ascenseur disponible';
      case 'parkingOuvert':
        return 'Parking disponible';
      case 'box':
        return 'Garage/Box disponible';
      case 'cave':
        return 'Cave disponible';
      case 'grenier':
        return 'Grenier disponible';
      default:
        return key;
    }
  }

  Widget _buildPropertyDetailsSection() {
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
            AppString.propertyDetails,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),
          Column(
            children: [
              // Basic Information
              _buildDetailRow(
                  "Type de bien", showPropertyDetailsController.propertyType),
              _buildDetailRow("Nombre de pièces",
                  "${showPropertyDetailsController.numberOfRooms}"),
              _buildDetailRow(
                  "Statut", showPropertyDetailsController.propertyStatus),

              // Location
              _buildDetailRow(
                  "Adresse", showPropertyDetailsController.propertyAddress),

              // Surfaces
              ..._buildSurfaceDetails(),

              // Pieces details
              ..._buildPiecesDetails(),

              // Building details
              ..._buildBuildingDetails(),

              // Characteristics
              ..._buildCharacteristicsDetails(),

              // Energy details
              ..._buildEnergyDetails(),

              // Pricing
              _buildDetailRow(
                  "Prix", showPropertyDetailsController.propertyPrice),
            ],
          ).paddingOnly(top: AppSize.appSize16),
        ],
      ).paddingOnly(
        left: AppSize.appSize16,
        right: AppSize.appSize16,
        top: AppSize.appSize16,
        bottom: AppSize.appSize16,
      ),
    );
  }

  List<Widget> _buildSurfaceDetails() {
    final surfaces = showPropertyDetailsController.surfaces;
    List<Widget> details = [];

    if (surfaces['habitable'] != null) {
      details.add(_buildDetailRow(
          "Surface habitable", "${surfaces['habitable'].toInt()} m²"));
    }
    if (surfaces['terrain'] != null) {
      details.add(_buildDetailRow(
          "Surface terrain", "${surfaces['terrain'].toInt()} m²"));
    }
    if (surfaces['habitableCarrez'] != null) {
      details.add(_buildDetailRow(
          "Surface loi Carrez", "${surfaces['habitableCarrez'].toInt()} m²"));
    }
    if (surfaces['garage'] != null) {
      details.add(_buildDetailRow(
          "Surface garage", "${surfaces['garage'].toInt()} m²"));
    }

    return details;
  }

  List<Widget> _buildPiecesDetails() {
    final pieces = showPropertyDetailsController.pieces;
    List<Widget> details = [];

    // Count different types of rooms
    Map<String, int> roomCounts = {};
    for (var piece in pieces) {
      String type = piece['type'] ?? '';
      roomCounts[type] = (roomCounts[type] ?? 0) + 1;
    }

    roomCounts.forEach((type, count) {
      String displayName = _getRoomDisplayName(type);
      details.add(_buildDetailRow(displayName, count.toString()));
    });

    return details;
  }

  String _getRoomDisplayName(String type) {
    switch (type) {
      case 'chambre':
        return 'Chambres';
      case 'salon':
        return 'Salon';
      case 'cuisine':
        return 'Cuisine';
      case 'salle_de_bain':
        return 'Salle de bain';
      case 'salle_d_eau':
        return 'Salle d\'eau';
      case 'wc':
        return 'WC';
      case 'bureau':
        return 'Bureau';
      case 'dressing':
        return 'Dressing';
      default:
        return type;
    }
  }

  List<Widget> _buildBuildingDetails() {
    final building = showPropertyDetailsController.building;
    List<Widget> details = [];

    if (building['anneeConstruction'] != null) {
      details.add(_buildDetailRow(
          "Année construction", building['anneeConstruction'].toString()));
    }
    if (building['copropriete'] != null) {
      details.add(_buildDetailRow(
          "Copropriété", building['copropriete'] ? 'Oui' : 'Non'));
    }

    return details;
  }

  List<Widget> _buildCharacteristicsDetails() {
    final characteristics = showPropertyDetailsController.characteristics;
    List<Widget> details = [];

    characteristics.forEach((key, value) {
      if (value == true) {
        String displayName = _getCharacteristicDisplayName(key);
        details.add(_buildDetailRow(displayName, 'Oui'));
      }
    });

    return details;
  }

  List<Widget> _buildEnergyDetails() {
    final energyDiagnostics = showPropertyDetailsController.energyDiagnostics;
    List<Widget> details = [];

    if (energyDiagnostics['dpe'] != null) {
      details.add(_buildDetailRow("DPE", energyDiagnostics['dpe'].toString()));
    }
    if (energyDiagnostics['ges'] != null) {
      details.add(_buildDetailRow("GES", energyDiagnostics['ges'].toString()));
    }

    return details;
  }

  Widget _buildDetailRow(String title, String value) {
    if (value.isEmpty || value == 'null') {
      return SizedBox.shrink();
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor),
              ).paddingOnly(right: AppSize.appSize10),
            ),
            Expanded(
              child: Text(
                value,
                style: AppStyle.heading5Regular(color: AppColor.textColor),
              ),
            ),
          ],
        ),
        Divider(
          color: AppColor.descriptionColor.withOpacity(0.4),
          thickness: 0.7,
          height: AppSize.appSize0,
        ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize16),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.aboutProperty,
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize36,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        Container(
          padding: const EdgeInsets.all(AppSize.appSize16),
          margin: const EdgeInsets.only(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColor.descriptionColor.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(AppSize.appSize12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                showPropertyDetailsController.propertyTitle,
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
                      showPropertyDetailsController.propertyAddress,
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
          color: AppColor.descriptionColor.withOpacity(0.4),
          thickness: 0.7,
          height: AppSize.appSize0,
        ).paddingOnly(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
          top: AppSize.appSize16,
          bottom: AppSize.appSize16,
        ),
        Text(
          showPropertyDetailsController.propertyDescription,
          style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
        ).paddingOnly(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      ],
    );
  }

  Widget _buildGallerySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    colors: [Colors.transparent, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    AppString.hall,
                    style: AppStyle.heading3Medium(color: AppColor.whiteColor),
                  ),
                ).paddingOnly(
                    left: AppSize.appSize16, bottom: AppSize.appSize16),
              ),
            ),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
        ),
      ],
    );
  }

  Widget _buildContactOwnerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                Assets.images.francisProfile.path,
                width: AppSize.appSize64,
                height: AppSize.appSize64,
              ).paddingOnly(right: AppSize.appSize12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppString.francisZieme,
                      style: AppStyle.heading4Medium(color: AppColor.textColor),
                    ).paddingOnly(bottom: AppSize.appSize4),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Text(
                            AppString.owner,
                            style: AppStyle.heading5Medium(
                                color: AppColor.descriptionColor),
                          ),
                          VerticalDivider(
                            color: AppColor.descriptionColor.withOpacity(0.4),
                            thickness: 0.7,
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
      ],
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildSimilarPropertiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.similarHomesForYou,
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ).paddingOnly(
          top: AppSize.appSize36,
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
            itemCount: showPropertyDetailsController.searchImageList.length,
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
                          showPropertyDetailsController.searchImageList[index],
                          height: AppSize.appSize200,
                        ),
                        Positioned(
                          right: AppSize.appSize6,
                          top: AppSize.appSize6,
                          child: GestureDetector(
                            onTap: () {
                              showPropertyDetailsController
                                      .isSimilarPropertyLiked[index] =
                                  !showPropertyDetailsController
                                      .isSimilarPropertyLiked[index];
                            },
                            child: Container(
                              width: AppSize.appSize32,
                              height: AppSize.appSize32,
                              decoration: BoxDecoration(
                                color: AppColor.whiteColor.withOpacity(0.5),
                                borderRadius:
                                    BorderRadius.circular(AppSize.appSize6),
                              ),
                              child: Center(
                                child: Obx(() => Image.asset(
                                      showPropertyDetailsController
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
                          showPropertyDetailsController.searchTitleList[index],
                          style: AppStyle.heading5SemiBold(
                              color: AppColor.textColor),
                        ),
                        Text(
                          showPropertyDetailsController
                              .searchAddressList[index],
                          style: AppStyle.heading5Regular(
                              color: AppColor.descriptionColor),
                        ).paddingOnly(top: AppSize.appSize6),
                      ],
                    ).paddingOnly(top: AppSize.appSize8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          showPropertyDetailsController.searchRupeesList[index],
                          style: AppStyle.heading5Medium(
                              color: AppColor.primaryColor),
                        ),
                        Row(
                          children: [
                            Text(
                              showPropertyDetailsController
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
                  ],
                ),
              );
            },
          ),
        ).paddingOnly(top: AppSize.appSize16),
      ],
    );
  }

  Widget _buildInterestingReadsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            itemCount:
                showPropertyDetailsController.interestingImageList.length,
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
                      showPropertyDetailsController.interestingImageList[index],
                    ).paddingOnly(right: AppSize.appSize16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            showPropertyDetailsController
                                .interestingTitleList[index],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyle.heading5Medium(
                                color: AppColor.textColor),
                          ),
                          Text(
                            showPropertyDetailsController
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
    );
  }
}
