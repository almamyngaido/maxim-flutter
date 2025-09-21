import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';

import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
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
              final String? propertyId = Get.arguments as String?;
              if (propertyId != null && propertyId.isNotEmpty) {
                Get.toNamed(
                  AppRoutes.editPropertyView,
                  arguments: propertyId,
                );
              } else {
                Get.snackbar(
                  'Erreur',
                  'Impossible d\'éditer cette propriété',
                  backgroundColor: AppColor.negativeColor,
                  colorText: AppColor.whiteColor,
                );
              }
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
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSize.appSize16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Images with "Voir les X photos" overlay
            _buildPropertyImagesSection(),

            SizedBox(height: AppSize.appSize20),

            // Price and Calculate Button
            _buildPriceSection(),

            SizedBox(height: AppSize.appSize16),

            // Property Basic Info
            _buildBasicInfoSection(),

            SizedBox(height: AppSize.appSize24),

            // Energy Diagnostics Section
            _buildEnergyDiagnosticsSection(),

            SizedBox(height: AppSize.appSize24),

            // Key Information Section
            _buildKeyInformationSection(),

            SizedBox(height: AppSize.appSize24),

            // Description Section
            _buildDescriptionSection(),

            SizedBox(height: AppSize.appSize24),

            // Contact Owner Section
            _buildContactOwnerSection(),

            SizedBox(height: AppSize.appSize24),

            // Map Section
            _buildMapSection(),

            SizedBox(height: AppSize.appSize24),

            // Similar Properties Section
            _buildSimilarPropertiesSection(),
          ],
        ),
      );
    });
  }

  Widget _buildPropertyImagesSection() {
    final images = showPropertyDetailsController.propertyImages;

    return Container(
      height: AppSize.appSize250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        color: AppColor.backgroundColor,
      ),
      child: Stack(
        children: [
          if (images.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              child: PageView.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final imageUrl = images[index];

                  if (imageUrl.startsWith('http') ||
                      imageUrl.startsWith('https')) {
                    return Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: AppSize.appSize250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFallbackImage();
                      },
                    );
                  } else {
                    return Image.asset(
                      imageUrl,
                      width: double.infinity,
                      height: AppSize.appSize250,
                      fit: BoxFit.cover,
                    );
                  }
                },
              ),
            )
          else
            _buildFallbackImage(),

          // "Voir les X photos" overlay
          if (images.length > 1)
            Positioned(
              top: AppSize.appSize12,
              right: AppSize.appSize12,
              child: GestureDetector(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.galleryView,
                    arguments: {
                      'images': images,
                      'initialIndex': 0,
                    },
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.appSize12,
                    vertical: AppSize.appSize6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.whiteColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(AppSize.appSize20),
                    border: Border.all(color: AppColor.borderColor),
                  ),
                  child: Text(
                    'Voir les ${images.length} photos',
                    style: AppStyle.heading6Medium(color: AppColor.textColor),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      width: double.infinity,
      height: AppSize.appSize250,
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

  Widget _buildPriceSection() {
    final price = showPropertyDetailsController.propertyPrice;
    final surfaces = showPropertyDetailsController.surfaces;
    double? surfaceHabitable = surfaces['habitable']?.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              price,
              style: AppStyle.heading2(color: AppColor.textColor),
            ),
            if (surfaceHabitable != null && surfaceHabitable > 0)
              Text(
                ' ${_calculatePricePerSqm(price, surfaceHabitable)}',
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor),
              ),
          ],
        ),
        SizedBox(height: AppSize.appSize12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(AppSize.appSize12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.primaryColor),
            borderRadius: BorderRadius.circular(AppSize.appSize8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calculate_outlined,
                color: AppColor.primaryColor,
                size: AppSize.appSize18,
              ),
              SizedBox(width: AppSize.appSize8),
              Text(
                'Calculer mes mensualités',
                style: AppStyle.heading5Medium(color: AppColor.primaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _calculatePricePerSqm(String priceString, double surface) {
    try {
      // Extract numeric value from price string
      String numericPart = priceString.replaceAll(RegExp(r'[^\d]'), '');
      if (numericPart.isNotEmpty) {
        double price = double.parse(numericPart);
        double pricePerSqm = price / surface;
        return '${pricePerSqm.toStringAsFixed(0)} €/m²';
      }
    } catch (e) {
      // Handle parsing errors
    }
    return '';
  }

  Widget _buildBasicInfoSection() {
    final numberOfRooms = showPropertyDetailsController.numberOfRooms;
    final surfaces = showPropertyDetailsController.surfaces;
    final address = showPropertyDetailsController.propertyAddress;
    final title = showPropertyDetailsController.propertyTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property summary line
        Text(
          '${numberOfRooms > 0 ? '$numberOfRooms Pièces' : ''}'
          '${surfaces['habitable'] != null ? ' • ${surfaces['habitable'].toInt()} m²' : ''}'
          '${address.isNotEmpty ? ' • $address' : ''}',
          style: AppStyle.heading5Regular(color: AppColor.textColor),
        ),
        SizedBox(height: AppSize.appSize8),

        // Property title
        Text(
          title,
          style: AppStyle.heading4SemiBold(color: AppColor.textColor),
        ),
        SizedBox(height: AppSize.appSize4),

        // Date and status
        Row(
          children: [
            Text(
              DateTime.now().toString().substring(0, 16).replaceAll('-', '/'),
              style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
            ),
            SizedBox(width: AppSize.appSize16),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.appSize8,
                vertical: AppSize.appSize2,
              ),
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize4),
              ),
              child: Text(
                showPropertyDetailsController.propertyStatus,
                style: AppStyle.heading6Medium(color: AppColor.primaryColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnergyDiagnosticsSection() {
    final energyDiagnostics = showPropertyDetailsController.energyDiagnostics;

    return Container(
      padding: EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(color: AppColor.borderColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diagnostics',
            style: AppStyle.heading4SemiBold(color: AppColor.textColor),
          ),
          SizedBox(height: AppSize.appSize16),

          // DPE (Energy Class)
          _buildEnergyRating(
            'Classe énergie',
            energyDiagnostics['dpe']?.toString() ?? 'N/A',
            Icons.energy_savings_leaf_outlined,
          ),
          SizedBox(height: AppSize.appSize12),

          // GES (Greenhouse Gas)
          _buildEnergyRating(
            'GES',
            energyDiagnostics['ges']?.toString() ?? 'N/A',
            Icons.co2_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyRating(String label, String rating, IconData icon) {
    List<String> grades = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
    List<Color> colors = [
      Color(0xFF00A650), // A - Green
      Color(0xFF5CB85C), // B - Light Green
      Color(0xFFF0AD4E), // C - Yellow
      Color(0xFFFF9500), // D - Orange
      Color(0xFFFF6B35), // E - Red Orange
      Color(0xFFE74C3C), // F - Red
      Color(0xFFC0392B), // G - Dark Red
    ];

    return Row(
      children: [
        Icon(icon, size: AppSize.appSize18, color: AppColor.descriptionColor),
        SizedBox(width: AppSize.appSize8),
        Text(
          label,
          style: AppStyle.heading5Regular(color: AppColor.textColor),
        ),
        SizedBox(width: AppSize.appSize8),
        Icon(Icons.info_outline,
            size: AppSize.appSize16, color: AppColor.descriptionColor),
        Spacer(),
        Row(
          children: grades.map((grade) {
            int index = grades.indexOf(grade);
            bool isSelected = grade == rating.toUpperCase();

            return Container(
              margin: EdgeInsets.only(left: AppSize.appSize2),
              width: AppSize.appSize24,
              height: AppSize.appSize20,
              decoration: BoxDecoration(
                color:
                    isSelected ? colors[index] : colors[index].withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppSize.appSize2),
              ),
              child: Center(
                child: Text(
                  grade,
                  style: TextStyle(
                    color:
                        isSelected ? AppColor.whiteColor : AppColor.textColor,
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildKeyInformationSection() {
    return Container(
      padding: EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(color: AppColor.borderColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Les informations clés',
            style: AppStyle.heading4SemiBold(color: AppColor.textColor),
          ),
          SizedBox(height: AppSize.appSize16),
          _buildKeyInfoGrid(),
          SizedBox(height: AppSize.appSize12),
          GestureDetector(
            onTap: () {
              // Navigate to full details
            },
            child: Text(
              'Voir les critères supplémentaires',
              style: AppStyle.heading5Medium(color: AppColor.primaryColor)
                  .copyWith(
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInfoGrid() {
    final propertyType = showPropertyDetailsController.propertyType;
    final surfaces = showPropertyDetailsController.surfaces;
    final numberOfRooms = showPropertyDetailsController.numberOfRooms;
    final pieces = showPropertyDetailsController.pieces;
    final characteristics = showPropertyDetailsController.characteristics;
    final heating = showPropertyDetailsController.heating;

    List<Widget> infoItems = [];

    // Type de bien
    if (propertyType.isNotEmpty && propertyType != 'Non spécifié') {
      infoItems.add(_buildKeyInfoItem(
        Icons.home_outlined,
        'Type de bien',
        propertyType,
      ));
    }

    // Surface habitable
    if (surfaces['habitable'] != null) {
      infoItems.add(_buildKeyInfoItem(
        Icons.square_foot_outlined,
        'Surface habitable',
        '${surfaces['habitable'].toInt()} m²',
      ));
    }

    // Surface totale du terrain
    if (surfaces['terrain'] != null) {
      infoItems.add(_buildKeyInfoItem(
        Icons.landscape_outlined,
        'Surface totale du terrain',
        '${surfaces['terrain'].toInt()} m²',
      ));
    }

    // Nombre de pièces
    if (numberOfRooms > 0) {
      infoItems.add(_buildKeyInfoItem(
        Icons.meeting_room_outlined,
        'Nombre de pièces',
        numberOfRooms.toString(),
      ));
    }

    // Nombre de chambres
    int bedrooms = pieces.where((piece) => piece['type'] == 'chambre').length;
    if (bedrooms > 0) {
      infoItems.add(_buildKeyInfoItem(
        Icons.bed_outlined,
        'Nombre de chambres',
        '$bedrooms ch.',
      ));
    }

    // Nombre de salles de bain
    int bathrooms = pieces
        .where((piece) =>
            piece['type'] == 'salle_de_bain' || piece['type'] == 'salle_d_eau')
        .length;
    if (bathrooms > 0) {
      infoItems.add(_buildKeyInfoItem(
        Icons.bathtub_outlined,
        'Nombre de salles de bain',
        bathrooms.toString(),
      ));
    }

    // Caractéristiques (garage, parking, etc.)
    List<String> features = [];
    if (characteristics['box'] == true) features.add('garage');
    if (characteristics['parkingOuvert'] == true) features.add('parking');
    if (characteristics['terrasse'] == true) features.add('terrasse');
    if (characteristics['balcon'] == true) features.add('balcon');

    if (features.isNotEmpty) {
      infoItems.add(_buildKeyInfoItem(
        Icons.local_parking_outlined,
        'Caractéristiques',
        'Avec ${features.join(', ')}...',
      ));
    }

    // Type de chauffage
    String heatingType = heating['type']?.toString() ?? '';
    if (heatingType.isNotEmpty) {
      infoItems.add(_buildKeyInfoItem(
        Icons.thermostat_outlined,
        'Type de chauffage',
        heatingType,
      ));
    }

    return Column(
      children: infoItems
          .map((item) => Padding(
                padding: EdgeInsets.only(bottom: AppSize.appSize12),
                child: item,
              ))
          .toList(),
    );
  }

  Widget _buildKeyInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: AppSize.appSize18, color: AppColor.descriptionColor),
        SizedBox(width: AppSize.appSize12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            value,
            style: AppStyle.heading5Medium(color: AppColor.textColor),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(color: AppColor.borderColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: AppStyle.heading4SemiBold(color: AppColor.textColor),
          ),
          SizedBox(height: AppSize.appSize12),
          Text(
            showPropertyDetailsController.propertyDescription,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildContactOwnerSection() {
    return Container(
      padding: EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(color: AppColor.borderColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: AppSize.appSize50,
                height: AppSize.appSize50,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize25),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColor.whiteColor,
                  size: AppSize.appSize24,
                ),
              ),
              SizedBox(width: AppSize.appSize12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Propriétaire',
                      style:
                          AppStyle.heading5SemiBold(color: AppColor.textColor),
                    ),
                    Text(
                      'Contactez pour plus d\'informations',
                      style: AppStyle.heading6Regular(
                          color: AppColor.descriptionColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.appSize16),
          CommonButton(
            onPressed: () {
              Get.toNamed(AppRoutes.contactOwnerView);
            },
            backgroundColor: AppColor.primaryColor,
            child: Text(
              'Voir le numéro de téléphone',
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      padding: EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(color: AppColor.borderColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Localisation',
            style: AppStyle.heading4SemiBold(color: AppColor.textColor),
          ),
          SizedBox(height: AppSize.appSize12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSize.appSize8),
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
                    markerId: MarkerId('property_location'),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarPropertiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Biens similaires',
          style: AppStyle.heading4SemiBold(color: AppColor.textColor),
        ),
        SizedBox(height: AppSize.appSize16),
        SizedBox(
          height: AppSize.appSize300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: showPropertyDetailsController.searchImageList.length,
            itemBuilder: (context, index) {
              return Container(
                width: AppSize.appSize250,
                margin: EdgeInsets.only(right: AppSize.appSize16),
                decoration: BoxDecoration(
                  color: AppColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  border:
                      Border.all(color: AppColor.borderColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(AppSize.appSize12),
                        ),
                        child: Image.asset(
                          showPropertyDetailsController.searchImageList[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(AppSize.appSize12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            showPropertyDetailsController
                                .searchRupeesList[index],
                            style: AppStyle.heading5SemiBold(
                                color: AppColor.primaryColor),
                          ),
                          SizedBox(height: AppSize.appSize4),
                          Text(
                            showPropertyDetailsController
                                .searchTitleList[index],
                            style: AppStyle.heading6Medium(
                                color: AppColor.textColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            showPropertyDetailsController
                                .searchAddressList[index],
                            style: AppStyle.heading6Regular(
                                color: AppColor.descriptionColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
