import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';

import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/show_property_details_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

class ShowPropertyDetailsView extends StatelessWidget {
  ShowPropertyDetailsView({super.key});

  final ShowPropertyDetailsController showPropertyDetailsController =
      Get.put(ShowPropertyDetailsController());

  @override
  Widget build(BuildContext context) {
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

            // Rooms Section
            _buildRoomsSection(),

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

    return Row(
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

    // Récupérer les valeurs DPE et GES
    String dpeValue = '';
    String gesValue = '';

    // Essayer différentes structures de données possibles
    if (energyDiagnostics['dpe'] != null) {
      dpeValue = energyDiagnostics['dpe'].toString().toUpperCase();
    }
    if (energyDiagnostics['ges'] != null) {
      gesValue = energyDiagnostics['ges'].toString().toUpperCase();
    }

    // Log pour debug
    print('🔋 DPE affiché: $dpeValue');
    print('🔋 GES affiché: $gesValue');

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
          Row(
            children: [
              Text(
                'Diagnostics Énergie',
                style: AppStyle.heading4SemiBold(color: AppColor.textColor),
              ),
              SizedBox(width: AppSize.appSize8),
              if (dpeValue.isEmpty && gesValue.isEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.appSize8,
                    vertical: AppSize.appSize2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.descriptionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSize.appSize4),
                  ),
                  child: Text(
                    'Non renseigné',
                    style: AppStyle.heading7Regular(color: AppColor.descriptionColor),
                  ),
                ),
            ],
          ),
          SizedBox(height: AppSize.appSize16),

          // DPE (Energy Class)
          _buildEnergyRating(
            'Classe énergie (DPE)',
            dpeValue,
            Icons.energy_savings_leaf_outlined,
          ),

          SizedBox(height: AppSize.appSize12),

          // GES (Greenhouse Gas)
          _buildEnergyRating(
            'Émissions de gaz (GES)',
            gesValue,
            Icons.co2_outlined,
          ),

          // Afficher la date du diagnostic si disponible
          if (energyDiagnostics['dateDiagnostique'] != null) ...[
            SizedBox(height: AppSize.appSize12),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                     size: AppSize.appSize16,
                     color: AppColor.descriptionColor),
                SizedBox(width: AppSize.appSize8),
                Text(
                  'Date du diagnostic: ${_formatDiagnosticDate(energyDiagnostics['dateDiagnostique'])}',
                  style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDiagnosticDate(dynamic date) {
    try {
      if (date == null) return '';
      DateTime dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date.toString();
    }
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          children: [
            Icon(icon, size: AppSize.appSize18, color: AppColor.descriptionColor),
            SizedBox(width: AppSize.appSize8),
            Expanded(
              child: Text(
                label,
                style: AppStyle.heading5Regular(color: AppColor.textColor),
              ),
            ),
            Icon(Icons.info_outline,
                size: AppSize.appSize16, color: AppColor.descriptionColor),
          ],
        ),
        SizedBox(height: AppSize.appSize8),

        // Grades row - scrollable on small screens
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: grades.map((grade) {
              int index = grades.indexOf(grade);
              bool isSelected = grade == rating.toUpperCase();

              return Container(
                margin: EdgeInsets.only(right: AppSize.appSize4),
                width: isSelected ? AppSize.appSize40 : AppSize.appSize32,
                height: isSelected ? AppSize.appSize36 : AppSize.appSize28,
                decoration: BoxDecoration(
                  color:
                      isSelected ? colors[index] : colors[index].withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppSize.appSize6),
                  border: isSelected
                      ? Border.all(color: colors[index].withOpacity(0.8), width: 2)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colors[index].withOpacity(0.4),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    grade,
                    style: TextStyle(
                      color:
                          isSelected ? AppColor.whiteColor : AppColor.textColor.withOpacity(0.6),
                      fontSize: isSelected ? 16 : 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getEnergyRatingDescription(String rating) {
    switch (rating) {
      case 'A':
        return 'Excellent - Très performant';
      case 'B':
        return 'Très bien - Bon niveau de performance';
      case 'C':
        return 'Bien - Performance moyenne';
      case 'D':
        return 'Assez bien - Performance acceptable';
      case 'E':
        return 'Passable - Performance médiocre';
      case 'F':
        return 'Insuffisant - Peu performant';
      case 'G':
        return 'Très insuffisant - Très peu performant';
      default:
        return 'Non renseigné';
    }
  }

  Widget _buildRoomsSection() {
    final pieces = showPropertyDetailsController.pieces;

    if (pieces.isEmpty) {
      return SizedBox.shrink();
    }

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
            'Composition des pièces',
            style: AppStyle.heading4SemiBold(color: AppColor.textColor),
          ),
          SizedBox(height: AppSize.appSize16),
          ...pieces.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> piece = entry.value;

            return Column(
              children: [
                if (index > 0)
                  Divider(
                    color: AppColor.descriptionColor.withOpacity(0.3),
                    height: AppSize.appSize24,
                  ),
                _buildRoomItem(piece),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRoomItem(Map<String, dynamic> piece) {
    String type = _getRoomTypeLabel(piece['type']?.toString() ?? '');
    String nom = piece['nom']?.toString() ?? '';
    double? surface = piece['surface']?.toDouble();
    int niveau = piece['niveau']?.toInt() ?? 0;
    String orientation = piece['orientation']?.toString() ?? '';
    String description = piece['description']?.toString() ?? '';

    // Check for special features
    List<String> features = [];
    if (piece['avecBalcon'] == true) features.add('Balcon');
    if (piece['avecTerrasse'] == true) features.add('Terrasse');
    if (piece['avecDressing'] == true) features.add('Dressing');
    if (piece['avecSalleDeBainPrivee'] == true) features.add('Salle de bain privée');

    return Container(
      padding: EdgeInsets.all(AppSize.appSize12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.appSize8),
        border: Border.all(color: AppColor.borderColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSize.appSize8),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSize.appSize6),
                ),
                child: Icon(
                  _getRoomIcon(piece['type']?.toString() ?? ''),
                  color: AppColor.primaryColor,
                  size: AppSize.appSize20,
                ),
              ),
              SizedBox(width: AppSize.appSize12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nom.isNotEmpty ? nom : type,
                      style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                    ),
                    if (nom.isNotEmpty)
                      Text(
                        type,
                        style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                      ),
                  ],
                ),
              ),
              if (surface != null && surface > 0)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.appSize8,
                    vertical: AppSize.appSize4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize4),
                  ),
                  child: Text(
                    '${surface.toInt()} m²',
                    style: AppStyle.heading6Medium(color: AppColor.whiteColor),
                  ),
                ),
            ],
          ),

          // Additional details
          if (niveau > 0 || orientation.isNotEmpty || features.isNotEmpty) ...[
            SizedBox(height: AppSize.appSize12),
            Wrap(
              spacing: AppSize.appSize8,
              runSpacing: AppSize.appSize6,
              children: [
                if (niveau > 0)
                  _buildRoomDetail(Icons.layers_outlined, 'Niveau $niveau'),
                if (orientation.isNotEmpty)
                  _buildRoomDetail(Icons.compass_calibration_outlined, orientation),
                ...features.map((feature) =>
                  _buildRoomDetail(Icons.check_circle_outline, feature)
                ),
              ],
            ),
          ],

          // Description
          if (description.isNotEmpty) ...[
            SizedBox(height: AppSize.appSize8),
            Text(
              description,
              style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoomDetail(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSize.appSize8,
        vertical: AppSize.appSize4,
      ),
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(AppSize.appSize4),
        border: Border.all(color: AppColor.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSize.appSize14, color: AppColor.descriptionColor),
          SizedBox(width: AppSize.appSize4),
          Text(
            text,
            style: AppStyle.heading7Regular(color: AppColor.textColor),
          ),
        ],
      ),
    );
  }

  String _getRoomTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'chambre':
        return 'Chambre';
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
      case 'cellier':
        return 'Cellier';
      case 'dressing':
        return 'Dressing';
      case 'entree':
        return 'Entrée';
      case 'couloir':
        return 'Couloir';
      case 'autre':
        return 'Autre pièce';
      default:
        return type;
    }
  }

  IconData _getRoomIcon(String type) {
    switch (type.toLowerCase()) {
      case 'chambre':
        return Icons.bed_outlined;
      case 'salon':
        return Icons.weekend_outlined;
      case 'cuisine':
        return Icons.kitchen_outlined;
      case 'salle_de_bain':
      case 'salle_d_eau':
        return Icons.bathtub_outlined;
      case 'wc':
        return Icons.wc_outlined;
      case 'bureau':
        return Icons.desk_outlined;
      case 'cellier':
        return Icons.inventory_2_outlined;
      case 'dressing':
        return Icons.checkroom_outlined;
      case 'entree':
      case 'couloir':
        return Icons.meeting_room_outlined;
      default:
        return Icons.room_outlined;
    }
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
          Obx(() => GestureDetector(
            onTap: () {
              showPropertyDetailsController.toggleKeyInfoExpansion();
            },
            child: Row(
              children: [
                Text(
                  showPropertyDetailsController.isKeyInfoExpanded.value
                      ? 'Masquer les critères supplémentaires'
                      : 'Voir les critères supplémentaires',
                  style: AppStyle.heading5Medium(color: AppColor.primaryColor)
                      .copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
                SizedBox(width: AppSize.appSize4),
                Icon(
                  showPropertyDetailsController.isKeyInfoExpanded.value
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColor.primaryColor,
                  size: AppSize.appSize18,
                ),
              ],
            ),
          )),
          Obx(() {
            if (showPropertyDetailsController.isKeyInfoExpanded.value) {
              return Column(
                children: [
                  SizedBox(height: AppSize.appSize16),
                  _buildAdditionalInfoGrid(),
                ],
              );
            }
            return SizedBox.shrink();
          }),
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
    final propertyData = showPropertyDetailsController.propertyData;

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

    // Surface Carrez
    if (surfaces['habitableCarrez'] != null && surfaces['habitableCarrez'] > 0) {
      infoItems.add(_buildKeyInfoItem(
        Icons.straighten_outlined,
        'Surface Carrez',
        '${surfaces['habitableCarrez'].toInt()} m²',
      ));
    }

    // Surface totale du terrain
    if (surfaces['terrain'] != null && surfaces['terrain'] > 0) {
      infoItems.add(_buildKeyInfoItem(
        Icons.landscape_outlined,
        'Surface terrain',
        '${surfaces['terrain'].toInt()} m²',
      ));
    }

    // Surface garage
    if (surfaces['garage'] != null && surfaces['garage'] > 0) {
      infoItems.add(_buildKeyInfoItem(
        Icons.garage_outlined,
        'Surface garage',
        '${surfaces['garage'].toInt()} m²',
      ));
    }

    // Nombre de pièces
    if (numberOfRooms > 0) {
      infoItems.add(_buildKeyInfoItem(
        Icons.meeting_room_outlined,
        'Nombre de pièces',
        '$numberOfRooms pièce${numberOfRooms > 1 ? 's' : ''}',
      ));
    }

    // Nombre de niveaux
    if (propertyData['nombreNiveaux'] != null && propertyData['nombreNiveaux'] > 0) {
      infoItems.add(_buildKeyInfoItem(
        Icons.layers_outlined,
        'Nombre de niveaux',
        '${propertyData['nombreNiveaux']} niveau${propertyData['nombreNiveaux'] > 1 ? 'x' : ''}',
      ));
    }

    // Nombre de chambres
    int bedrooms = pieces.where((piece) => piece['type'] == 'chambre').length;
    if (bedrooms > 0) {
      infoItems.add(_buildKeyInfoItem(
        Icons.bed_outlined,
        'Chambres',
        '$bedrooms',
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
        'Salles de bain',
        '$bathrooms',
      ));
    }

    // Année de construction
    if (propertyData['batiment'] != null &&
        propertyData['batiment']['anneeConstruction'] != null) {
      infoItems.add(_buildKeyInfoItem(
        Icons.calendar_today_outlined,
        'Année de construction',
        '${propertyData['batiment']['anneeConstruction']}',
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

  Widget _buildAdditionalInfoGrid() {
    final characteristics = showPropertyDetailsController.characteristics;
    final chauffageClim = showPropertyDetailsController.heating;
    final energie = showPropertyDetailsController.energy;
    final propertyData = showPropertyDetailsController.propertyData;

    List<Widget> infoItems = [];

    // Copropriété
    if (propertyData['batiment'] != null) {
      bool isCopropriete = propertyData['batiment']['copropriete'] ?? false;
      infoItems.add(_buildKeyInfoItem(
        Icons.apartment_outlined,
        'Copropriété',
        isCopropriete ? 'Oui' : 'Non',
      ));
    }

    // Caractéristiques du bien
    List<String> availableFeatures = [];
    if (characteristics['grenier'] == true) availableFeatures.add('Grenier');
    if (characteristics['balcon'] == true) availableFeatures.add('Balcon');
    if (characteristics['terrasse'] == true) availableFeatures.add('Terrasse');
    if (characteristics['cave'] == true) availableFeatures.add('Cave');
    if (characteristics['box'] == true) availableFeatures.add('Box');
    if (characteristics['parkingOuvert'] == true) availableFeatures.add('Parking');
    if (characteristics['jardin'] == true) availableFeatures.add('Jardin');
    if (characteristics['piscine'] == true) availableFeatures.add('Piscine');
    if (characteristics['ascenseur'] == true) availableFeatures.add('Ascenseur');
    if (characteristics['dependance'] == true) availableFeatures.add('Dépendance');

    if (availableFeatures.isNotEmpty) {
      infoItems.add(_buildKeyInfoItem(
        Icons.check_circle_outline,
        'Équipements',
        availableFeatures.join(', '),
      ));
    }

    // Chauffage
    List<String> heatingTypes = [];
    if (chauffageClim['cheminee'] == true) heatingTypes.add('Cheminée');
    if (chauffageClim['poeleABois'] == true) heatingTypes.add('Poêle à bois');
    if (chauffageClim['insertABois'] == true) heatingTypes.add('Insert à bois');
    if (chauffageClim['poeleAPellets'] == true) heatingTypes.add('Poêle à pellets');
    if (chauffageClim['chauffageIndividuelChaudiere'] == true) heatingTypes.add('Chaudière individuelle');
    if (chauffageClim['chauffageAuSol'] == true) heatingTypes.add('Chauffage au sol');
    if (chauffageClim['chauffageIndividuelElectrique'] == true) heatingTypes.add('Chauffage électrique');
    if (chauffageClim['chauffageUrbain'] == true) heatingTypes.add('Chauffage urbain');

    if (heatingTypes.isNotEmpty) {
      infoItems.add(_buildKeyInfoItem(
        Icons.thermostat_outlined,
        'Chauffage',
        heatingTypes.join(', '),
      ));
    }

    // Énergie
    List<String> energyTypes = [];
    if (energie['electricite'] == true) energyTypes.add('Électricité');
    if (energie['gaz'] == true) energyTypes.add('Gaz');
    if (energie['fioul'] == true) energyTypes.add('Fioul');
    if (energie['pompeAChaleur'] == true) energyTypes.add('Pompe à chaleur');
    if (energie['geothermie'] == true) energyTypes.add('Géothermie');

    if (energyTypes.isNotEmpty) {
      infoItems.add(_buildKeyInfoItem(
        Icons.bolt_outlined,
        'Sources d\'énergie',
        energyTypes.join(', '),
      ));
    }

    // Accès égout
    if (characteristics['accesEgout'] != null) {
      infoItems.add(_buildKeyInfoItem(
        Icons.water_outlined,
        'Accès égout',
        characteristics['accesEgout'] ? 'Oui' : 'Non',
      ));
    }

    // Informations financières
    if (propertyData['prix'] != null) {
      Map<String, dynamic> prix = propertyData['prix'];

      // Prix net vendeur
      if (prix['netVendeur'] != null) {
        infoItems.add(_buildKeyInfoItem(
          Icons.euro_outlined,
          'Prix net vendeur',
          '${prix['netVendeur'].toInt()} €',
        ));
      }

      // Honoraires
      if (prix['honoraireEuros'] != null && prix['honoraireEuros'] > 0) {
        infoItems.add(_buildKeyInfoItem(
          Icons.account_balance_wallet_outlined,
          'Honoraires',
          '${prix['honoraireEuros'].toInt()} € (${prix['honorairePourcentage'] ?? 0}%)',
        ));
      }

      // Charges copropriété
      if (prix['chargesAnnuellesCopropriete'] != null && prix['chargesAnnuellesCopropriete'] > 0) {
        infoItems.add(_buildKeyInfoItem(
          Icons.receipt_long_outlined,
          'Charges annuelles',
          '${prix['chargesAnnuellesCopropriete'].toInt()} €/an',
        ));
      }
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
    // Check if value is long (e.g., lists of features)
    bool isLongValue = value.length > 20;

    if (isLongValue) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSize.appSize18, color: AppColor.descriptionColor),
              SizedBox(width: AppSize.appSize12),
              Expanded(
                child: Text(
                  label,
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSize.appSize6),
          Padding(
            padding: EdgeInsets.only(left: AppSize.appSize30),
            child: Text(
              value,
              style: AppStyle.heading5Medium(color: AppColor.textColor),
            ),
          ),
        ],
      );
    }

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
    // Get owner information from propertyData
    final utilisateur = showPropertyDetailsController.propertyData['utilisateur'];
    final ownerName = utilisateur != null
        ? '${utilisateur['prenom'] ?? ''} ${utilisateur['nom'] ?? ''}'.trim()
        : 'Propriétaire';
    final ownerEmail = utilisateur?['email'] ?? '';
    final ownerPhone = utilisateur?['phoneNumber'] ?? '';
    final firstLetter = ownerName.isNotEmpty ? ownerName[0].toUpperCase() : 'P';

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
              // Owner avatar with first letter
              Container(
                width: AppSize.appSize50,
                height: AppSize.appSize50,
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize25),
                ),
                child: Center(
                  child: Text(
                    firstLetter,
                    style: AppStyle.heading4Medium(color: AppColor.whiteColor),
                  ),
                ),
              ),
              SizedBox(width: AppSize.appSize12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ownerName,
                      style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (ownerEmail.isNotEmpty)
                      Text(
                        ownerEmail,
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
          SizedBox(height: AppSize.appSize16),

          // Action buttons
          Row(
            children: [
              // Call button
              if (ownerPhone.isNotEmpty)
                Expanded(
                  child: CommonButton(
                    onPressed: () async {
                      final Uri phoneUri = Uri(scheme: 'tel', path: ownerPhone);
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      } else {
                        Get.snackbar(
                          'Erreur',
                          'Impossible d\'appeler ce numéro',
                          backgroundColor: AppColor.negativeColor,
                          colorText: AppColor.whiteColor,
                        );
                      }
                    },
                    backgroundColor: AppColor.primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: AppColor.whiteColor, size: 18),
                        SizedBox(width: AppSize.appSize8),
                        Text(
                          'Appeler',
                          style: AppStyle.heading6Medium(color: AppColor.whiteColor),
                        ),
                      ],
                    ),
                  ),
                ),

              if (ownerPhone.isNotEmpty) SizedBox(width: AppSize.appSize12),

              // Message button
              Expanded(
                child: CommonButton(
                  onPressed: () {
                    // Navigate to messaging
                    Get.toNamed(AppRoutes.chatView, arguments: {
                      'propertyId': showPropertyDetailsController.propertyData['id'],
                      'sellerId': utilisateur?['id'],
                    });
                  },
                  backgroundColor: AppColor.whiteColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.message, color: AppColor.primaryColor, size: 18),
                      SizedBox(width: AppSize.appSize8),
                      Text(
                        'Message',
                        style: AppStyle.heading6Medium(color: AppColor.primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
    return Obx(() {
      // Show loading state
      if (showPropertyDetailsController.isLoadingSimilarProperties.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biens similaires',
              style: AppStyle.heading4SemiBold(color: AppColor.textColor),
            ),
            SizedBox(height: AppSize.appSize16),
            Center(
              child: CircularProgressIndicator(color: AppColor.primaryColor),
            ),
          ],
        );
      }

      // Show empty state if no similar properties
      if (showPropertyDetailsController.similarProperties.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biens similaires',
              style: AppStyle.heading4SemiBold(color: AppColor.textColor),
            ),
            SizedBox(height: AppSize.appSize16),
            Container(
              padding: EdgeInsets.all(AppSize.appSize16),
              decoration: BoxDecoration(
                color: AppColor.secondaryColor,
                borderRadius: BorderRadius.circular(AppSize.appSize12),
                border: Border.all(color: AppColor.borderColor.withOpacity(0.3)),
              ),
              child: Text(
                'Aucun bien similaire trouvé',
                style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
              ),
            ),
          ],
        );
      }

      // Show similar properties
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biens similaires',
                style: AppStyle.heading4SemiBold(color: AppColor.textColor),
              ),
              Text(
                '${showPropertyDetailsController.similarProperties.length} ${showPropertyDetailsController.similarProperties.length > 1 ? 'biens' : 'bien'}',
                style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
            ],
          ),
          SizedBox(height: AppSize.appSize16),
          SizedBox(
            height: AppSize.appSize300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: showPropertyDetailsController.similarProperties.length,
              itemBuilder: (context, index) {
                final property = showPropertyDetailsController.similarProperties[index];

                // Extract property details
                final propertyId = property['id']?.toString() ?? '';
                final images = property['listeImages'] as List?;
                final imageUrl = images != null && images.isNotEmpty
                    ? (images.first.toString().startsWith('http')
                        ? images.first.toString()
                        : '${ApiConfig.baseUrl}/${images.first}')
                    : Assets.images.property3.path;

                final price = property['prix']?['hai'];
                final priceString = price != null
                    ? (price >= 1000000
                        ? '${(price / 1000000).toStringAsFixed(1)}M €'
                        : price >= 1000
                            ? '${(price / 1000).toStringAsFixed(0)}K €'
                            : '${price.toStringAsFixed(0)} €')
                    : 'Prix sur demande';

                final typeBien = property['typeBien']?.toString() ?? 'Bien immobilier';
                final nombrePieces = property['nombrePiecesTotal']?.toInt() ?? 0;
                final title = nombrePieces > 0 ? '$typeBien ${nombrePieces}P' : typeBien;

                final localisation = property['localisation'];
                final ville = localisation?['ville']?.toString() ?? '';
                final codePostal = localisation?['codePostal']?.toString() ?? '';
                final address = ville.isNotEmpty && codePostal.isNotEmpty
                    ? '$ville, $codePostal'
                    : ville.isNotEmpty
                        ? ville
                        : codePostal.isNotEmpty
                            ? codePostal
                            : 'Localisation non spécifiée';

                return GestureDetector(
                  onTap: () {
                    // Navigate to this property's details
                    Get.toNamed(AppRoutes.showPropertyDetailsView, arguments: propertyId);
                  },
                  child: Container(
                    width: AppSize.appSize250,
                    margin: EdgeInsets.only(right: AppSize.appSize16),
                    decoration: BoxDecoration(
                      color: AppColor.secondaryColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      border: Border.all(color: AppColor.borderColor.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.textColor.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppSize.appSize12),
                            ),
                            child: imageUrl.startsWith('http')
                                ? Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColor.backgroundColor,
                                        child: Icon(
                                          Icons.home_outlined,
                                          size: AppSize.appSize60,
                                          color: AppColor.descriptionColor,
                                        ),
                                      );
                                    },
                                  )
                                : Image.asset(
                                    imageUrl,
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
                                priceString,
                                style: AppStyle.heading5SemiBold(
                                    color: AppColor.primaryColor),
                              ),
                              SizedBox(height: AppSize.appSize4),
                              Text(
                                title,
                                style: AppStyle.heading6Medium(
                                    color: AppColor.textColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                address,
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
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
