import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_rich_text.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_textfield.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/show_property_details_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/text_segment_model.dart';
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
            Get.offAllNamed(AppRoutes.bottomBarView);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSize.appSize30),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: AppSize.appSize200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              image: DecorationImage(
                image: AssetImage(Assets.images.property3.path),
                fit: BoxFit.fill,
              ),
            ),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Text(
            AppString.rupees50Lakh,
            style: AppStyle.heading4Medium(color: AppColor.primaryColor),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Text(
                  AppString.readyToMove,
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
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
                  AppString.semiFurnished,
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
          Text(
            AppString.semiModernHouse,
            style: AppStyle.heading5SemiBold(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize8,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Text(
            AppString.northBombaySociety,
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
          Row(
            children: List.generate(
                showPropertyDetailsController.searchPropertyTitleList.length,
                (index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSize.appSize6,
                  horizontal: AppSize.appSize14,
                ),
                margin: const EdgeInsets.only(right: AppSize.appSize16),
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
                      showPropertyDetailsController
                          .searchPropertyImageList[index],
                      width: AppSize.appSize18,
                      height: AppSize.appSize18,
                    ).paddingOnly(right: AppSize.appSize6),
                    Text(
                      showPropertyDetailsController
                          .searchPropertyTitleList[index],
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ),
                  ],
                ),
              );
            }),
          ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          Row(
            children: List.generate(
                showPropertyDetailsController.searchProperty2TitleList.length,
                (index) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSize.appSize6,
                  horizontal: AppSize.appSize14,
                ),
                margin: const EdgeInsets.only(right: AppSize.appSize16),
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
                      showPropertyDetailsController
                          .searchProperty2ImageList[index],
                      width: AppSize.appSize18,
                      height: AppSize.appSize18,
                    ).paddingOnly(right: AppSize.appSize6),
                    Text(
                      showPropertyDetailsController
                          .searchProperty2TitleList[index],
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ),
                  ],
                ),
              );
            }),
          ).paddingOnly(
            top: AppSize.appSize10,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Container(
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
                  AppString.keyHighlights,
                  style: AppStyle.heading4SemiBold(color: AppColor.whiteColor),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                      showPropertyDetailsController
                          .keyHighlightsTitleList.length, (index) {
                    return Row(
                      children: [
                        Container(
                          width: AppSize.appSize5,
                          height: AppSize.appSize5,
                          margin:
                              const EdgeInsets.only(left: AppSize.appSize10),
                          decoration: const BoxDecoration(
                            color: AppColor.whiteColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          showPropertyDetailsController
                              .keyHighlightsTitleList[index],
                          style: AppStyle.heading5Regular(
                              color: AppColor.whiteColor),
                        ).paddingOnly(left: AppSize.appSize10),
                      ],
                    ).paddingOnly(top: AppSize.appSize10);
                  }),
                ).paddingOnly(top: AppSize.appSize6),
              ],
            ),
          ),
          Obx(() {
            if (showPropertyDetailsController.isLoadingProperty.value) {
              return Container(
                margin: const EdgeInsets.only(
                  top: AppSize.appSize36,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                ),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final bienImmo = showPropertyDetailsController.bienImmo.value;
            if (bienImmo == null) {
              return Container(
                margin: const EdgeInsets.only(
                  top: AppSize.appSize36,
                  left: AppSize.appSize16,
                  right: AppSize.appSize16,
                ),
                child: Text("Erreur lors du chargement des données"),
              );
            }

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
                      // BASIC INFORMATION
                      _buildDetailRow("Type de bien", bienImmo.typeBien),
                      _buildDetailRow(
                          "Nombre de pièces", "${bienImmo.nombrePieces}"),

                      // LOCATION
                      _buildDetailRow(
                          "Adresse", "${bienImmo.numeroRue} ${bienImmo.rue}"),
                      _buildDetailRow("Code postal", bienImmo.codePostal),
                      _buildDetailRow("Ville", bienImmo.ville),
                      _buildDetailRow("Département", bienImmo.departement),

                      // SURFACES
                      _buildDetailRow("Surface habitable",
                          "${bienImmo.surfaceHabitable.toInt()} m²"),
                      if (bienImmo.surfaceTerrain != null)
                        _buildDetailRow("Surface terrain",
                            "${bienImmo.surfaceTerrain!.toInt()} m²"),
                      if (bienImmo.surfaceLoiCarrez != null)
                        _buildDetailRow("Surface loi Carrez",
                            "${bienImmo.surfaceLoiCarrez!.toInt()} m²"),

                      // ROOMS
                      if (bienImmo.chambres != null)
                        _buildDetailRow("Chambres", "${bienImmo.chambres}"),
                      if (bienImmo.cuisine != null)
                        _buildDetailRow("Cuisine", "${bienImmo.cuisine}"),
                      if (bienImmo.salleDeBain != null)
                        _buildDetailRow(
                            "Salle de bain", "${bienImmo.salleDeBain}"),
                      if (bienImmo.salleDEau != null)
                        _buildDetailRow("Salle d'eau", "${bienImmo.salleDEau}"),
                      if (bienImmo.sejour != null)
                        _buildDetailRow("Séjour", "${bienImmo.sejour}"),

                      // BUILDING INFO
                      if (bienImmo.nombreNiveaux != null)
                        _buildDetailRow(
                            "Nombre de niveaux", "${bienImmo.nombreNiveaux}"),
                      if (bienImmo.anneeConstruction != null)
                        _buildDetailRow("Année construction",
                            "${bienImmo.anneeConstruction}"),

                      // CHARACTERISTICS
                      if (bienImmo.balcon == true)
                        _buildDetailRow("Balcon", "Oui"),
                      if (bienImmo.jardin == true)
                        _buildDetailRow("Jardin", "Oui"),
                      if (bienImmo.terrasse == true)
                        _buildDetailRow("Terrasse", "Oui"),
                      if (bienImmo.piscine == true)
                        _buildDetailRow("Piscine", "Oui"),
                      if (bienImmo.ascenseur == true)
                        _buildDetailRow("Ascenseur", "Oui"),
                      if (bienImmo.parkingOuvert == true)
                        _buildDetailRow("Parking", "Oui"),
                      if (bienImmo.box == true)
                        _buildDetailRow("Garage/Box", "Oui"),

                      // ENERGY
                      if (bienImmo.dpe != null)
                        _buildDetailRow("DPE", bienImmo.dpe!),
                      if (bienImmo.ges != null)
                        _buildDetailRow("GES", bienImmo.ges!),

                      // HEATING/ENERGY
                      if (bienImmo.cheminee == true)
                        _buildDetailRow("Cheminée", "Oui"),
                      if (bienImmo.chauffageAuSol == true)
                        _buildDetailRow("Chauffage au sol", "Oui"),
                      if (bienImmo.pompeAChaleur == true)
                        _buildDetailRow("Pompe à chaleur", "Oui"),

                      // PRICE INFORMATION
                      _buildDetailRow(
                          "Prix HAI", "${_formatPrice(bienImmo.prixHAI)} €"),
                      if (bienImmo.honorairePourcentage != null)
                        _buildDetailRow(
                            "Honoraires", "${bienImmo.honorairePourcentage}%"),
                      if (bienImmo.netVendeur != null)
                        _buildDetailRow("Net vendeur",
                            "${_formatPrice(bienImmo.netVendeur!)} €"),
                      if (bienImmo.chargesAnnuellesCopropriete != null)
                        _buildDetailRow("Charges annuelles",
                            "${_formatPrice(bienImmo.chargesAnnuellesCopropriete!)} €"),
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
          }),
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
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      AppString.hall,
                      style:
                          AppStyle.heading3Medium(color: AppColor.whiteColor),
                    ),
                  ).paddingOnly(
                      left: AppSize.appSize16, bottom: AppSize.appSize16),
                ),
              ),
            ).paddingOnly(left: AppSize.appSize16, right: AppSize.appSize16),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.galleryView);
                  },
                  child: Container(
                    height: AppSize.appSize150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      image: DecorationImage(
                        image: AssetImage(Assets.images.kitchen.path),
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
                            colors: [
                              Colors.transparent,
                              Colors.black,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            AppString.kitchen,
                            style: AppStyle.heading3Medium(
                                color: AppColor.whiteColor),
                          ),
                        ).paddingOnly(
                            left: AppSize.appSize16, bottom: AppSize.appSize16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSize.appSize16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.galleryView);
                  },
                  child: Container(
                    height: AppSize.appSize150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      image: DecorationImage(
                        image: AssetImage(Assets.images.bedroom.path),
                        fit: BoxFit.cover,
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
                            colors: [
                              Colors.transparent,
                              Colors.black,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            AppString.bedroom,
                            style: AppStyle.heading3Medium(
                                color: AppColor.whiteColor),
                          ),
                        ).paddingOnly(
                            left: AppSize.appSize16, bottom: AppSize.appSize16),
                      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.furnishingDetails,
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.furnishingDetailsView);
                },
                child: Text(
                  AppString.viewAll,
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
          SizedBox(
            height: AppSize.appSize85,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: showPropertyDetailsController
                  .furnishingDetailsImageList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding: const EdgeInsets.only(
                    left: AppSize.appSize16,
                    right: AppSize.appSize16,
                    top: AppSize.appSize16,
                    bottom: AppSize.appSize16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        showPropertyDetailsController
                            .furnishingDetailsImageList[index],
                        width: AppSize.appSize24,
                        color: AppColor.descriptionColor,
                      ),
                      Text(
                        showPropertyDetailsController
                            .furnishingDetailsTitleList[index],
                        style:
                            AppStyle.heading5Regular(color: AppColor.textColor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
          Text(
            AppString.facilities,
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
              itemCount:
                  showPropertyDetailsController.facilitiesImageList.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: AppSize.appSize16),
                  padding: const EdgeInsets.only(
                    left: AppSize.appSize16,
                    right: AppSize.appSize16,
                    top: AppSize.appSize16,
                    bottom: AppSize.appSize16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        showPropertyDetailsController
                            .facilitiesImageList[index],
                        width: AppSize.appSize40,
                        color: AppColor.descriptionColor,
                      ),
                      Text(
                        showPropertyDetailsController
                            .facilitiesTitleList[index],
                        style:
                            AppStyle.heading5Regular(color: AppColor.textColor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ).paddingOnly(top: AppSize.appSize16),
          Text(
            AppString.aboutProperty,
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
                  AppString.semiModernHouse,
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
                        AppString.address6,
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
                text: AppString.aboutPropertyString,
                style:
                    AppStyle.heading5Regular(color: AppColor.descriptionColor),
              ),
              TextSegment(
                text: AppString.readMore,
                onTap: () {
                  Get.toNamed(AppRoutes.aboutPropertyView);
                },
                style: AppStyle.heading5Regular(color: AppColor.primaryColor),
              ),
            ],
          ).paddingOnly(
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
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
                        style:
                            AppStyle.heading4Medium(color: AppColor.textColor),
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
                              color: AppColor.descriptionColor
                                  .withValues(alpha: AppSize.appSizePoint4),
                              thickness: AppSize.appSizePoint7,
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
          CommonTextField(
            controller: showPropertyDetailsController.fullNameController,
            focusNode: showPropertyDetailsController.focusNode,
            hasFocus: true,
            hasInput: true,
            hintText: AppString.fullName,
            labelText: AppString.fullName,
            readOnly: true,
            border: Border.all(
              color: AppColor.primaryColor
                  .withValues(alpha: AppSize.appSizePoint50),
              width: AppSize.appSizePoint7,
            ),
            labelStyle: AppStyle.heading6Regular(
              color: AppColor.primaryColor
                  .withValues(alpha: AppSize.appSizePoint50),
            ),
            textfieldStyle: AppStyle.heading4Regular(
              color:
                  AppColor.textColor.withValues(alpha: AppSize.appSizePoint50),
            ),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Obx(() => Container(
                padding: EdgeInsets.only(
                  top:
                      showPropertyDetailsController.hasPhoneNumberFocus.value ||
                              showPropertyDetailsController
                                  .hasPhoneNumberInput.value
                          ? AppSize.appSize6
                          : AppSize.appSize14,
                  bottom:
                      showPropertyDetailsController.hasPhoneNumberFocus.value ||
                              showPropertyDetailsController
                                  .hasPhoneNumberInput.value
                          ? AppSize.appSize8
                          : AppSize.appSize14,
                  left: showPropertyDetailsController.hasPhoneNumberFocus.value
                      ? AppSize.appSize0
                      : AppSize.appSize16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  border: Border.all(
                    color: showPropertyDetailsController
                                .hasPhoneNumberFocus.value ||
                            showPropertyDetailsController
                                .hasPhoneNumberInput.value
                        ? AppColor.primaryColor
                            .withValues(alpha: AppSize.appSizePoint50)
                        : AppColor.descriptionColor
                            .withValues(alpha: AppSize.appSizePoint50),
                    width: AppSize.appSizePoint7,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    showPropertyDetailsController.hasPhoneNumberFocus.value ||
                            showPropertyDetailsController
                                .hasPhoneNumberInput.value
                        ? Text(
                            AppString.phoneNumber,
                            style: AppStyle.heading6Regular(
                              color: AppColor.primaryColor
                                  .withValues(alpha: AppSize.appSizePoint50),
                            ),
                          ).paddingOnly(
                            left: showPropertyDetailsController
                                    .hasPhoneNumberInput.value
                                ? (showPropertyDetailsController
                                        .hasPhoneNumberFocus.value
                                    ? AppSize.appSize16
                                    : AppSize.appSize0)
                                : AppSize.appSize16,
                            bottom: showPropertyDetailsController
                                    .hasPhoneNumberInput.value
                                ? AppSize.appSize2
                                : AppSize.appSize2,
                          )
                        : const SizedBox.shrink(),
                    Row(
                      children: [
                        showPropertyDetailsController
                                    .hasPhoneNumberFocus.value ||
                                showPropertyDetailsController
                                    .hasPhoneNumberInput.value
                            ? SizedBox(
                                // width: AppSize.appSize78,
                                child: IntrinsicHeight(
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: Row(
                                      children: [
                                        Text(
                                          AppString.countryCode,
                                          style: AppStyle.heading4Regular(
                                            color: AppColor.primaryColor
                                                .withValues(
                                                    alpha:
                                                        AppSize.appSizePoint50),
                                          ),
                                        ),
                                        Image.asset(
                                          Assets.images.dropdown.path,
                                          width: AppSize.appSize16,
                                          color: AppColor.descriptionColor
                                              .withValues(
                                                  alpha:
                                                      AppSize.appSizePoint50),
                                        ).paddingOnly(
                                            left: AppSize.appSize8,
                                            right: AppSize.appSize3),
                                        VerticalDivider(
                                          color: AppColor.primaryColor
                                              .withValues(
                                                  alpha:
                                                      AppSize.appSizePoint50),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).paddingOnly(
                                left: showPropertyDetailsController
                                        .hasPhoneNumberInput.value
                                    ? (showPropertyDetailsController
                                            .hasPhoneNumberFocus.value
                                        ? AppSize.appSize16
                                        : AppSize.appSize0)
                                    : AppSize.appSize16,
                              )
                            : const SizedBox.shrink(),
                        Expanded(
                          child: SizedBox(
                            height: AppSize.appSize27,
                            width: double.infinity,
                            child: TextFormField(
                              readOnly: true,
                              focusNode: showPropertyDetailsController
                                  .phoneNumberFocusNode,
                              controller: showPropertyDetailsController
                                  .mobileNumberController,
                              cursorColor: AppColor.primaryColor,
                              keyboardType: TextInputType.phone,
                              style: AppStyle.heading4Regular(
                                color: AppColor.textColor
                                    .withValues(alpha: AppSize.appSizePoint50),
                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(
                                    AppSize.size10),
                              ],
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSize.appSize0,
                                  vertical: AppSize.appSize0,
                                ),
                                isDense: true,
                                hintText: showPropertyDetailsController
                                        .hasPhoneNumberFocus.value
                                    ? ''
                                    : AppString.phoneNumber,
                                hintStyle: AppStyle.heading4Regular(
                                    color: AppColor.descriptionColor),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSize.appSize12),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSize.appSize12),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSize.appSize12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          CommonTextField(
            controller: showPropertyDetailsController.emailController,
            focusNode: showPropertyDetailsController.emailFocusNode,
            hasFocus: true,
            hasInput: true,
            hintText: AppString.emailAddress,
            labelText: AppString.emailAddress,
            readOnly: true,
            border: Border.all(
              color: AppColor.primaryColor
                  .withValues(alpha: AppSize.appSizePoint50),
              width: AppSize.appSizePoint7,
            ),
            labelStyle: AppStyle.heading6Regular(
              color: AppColor.primaryColor
                  .withValues(alpha: AppSize.appSizePoint50),
            ),
            textfieldStyle: AppStyle.heading4Regular(
              color:
                  AppColor.textColor.withValues(alpha: AppSize.appSizePoint50),
            ),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Text(
            AppString.areYouARealEstateAgent,
            style: AppStyle.heading4Regular(
              color:
                  AppColor.textColor.withValues(alpha: AppSize.appSizePoint50),
            ),
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Row(
            children: List.generate(
                showPropertyDetailsController.realEstateList.length, (index) {
              return GestureDetector(
                onTap: () {
                  // showPropertyDetailsController.updateAgent(index);
                },
                child: Obx(() => Container(
                      width: AppSize.appSize75,
                      margin: const EdgeInsets.only(right: AppSize.appSize16),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSize.appSize10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: showPropertyDetailsController
                                      .selectAgent.value ==
                                  index
                              ? AppColor.primaryColor
                                  .withValues(alpha: AppSize.appSizePoint50)
                              : AppColor.borderColor
                                  .withValues(alpha: AppSize.appSizePoint50),
                          width: AppSize.appSize1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          showPropertyDetailsController.realEstateList[index],
                          style: AppStyle.heading5Medium(
                            color: showPropertyDetailsController
                                        .selectAgent.value ==
                                    index
                                ? AppColor.primaryColor
                                    .withValues(alpha: AppSize.appSizePoint50)
                                : AppColor.descriptionColor
                                    .withValues(alpha: AppSize.appSizePoint50),
                          ),
                        ),
                      ),
                    )),
              );
            }),
          ).paddingOnly(
            top: AppSize.appSize10,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  showPropertyDetailsController.toggleCheckbox();
                },
                child: Obx(() => Image.asset(
                      showPropertyDetailsController.isChecked.value
                          ? Assets.images.checkbox.path
                          : Assets.images.emptyCheckbox.path,
                      width: AppSize.appSize20,
                    )).paddingOnly(right: AppSize.appSize16),
              ),
              Expanded(
                child: CommonRichText(
                  segments: [
                    TextSegment(
                      text: AppString.terms1,
                      style: AppStyle.heading6Regular(
                        color: AppColor.descriptionColor,
                      ),
                    ),
                    TextSegment(
                      text: AppString.terms2,
                      style: AppStyle.heading6Regular(
                        color: AppColor.primaryColor,
                      ),
                    ),
                    TextSegment(
                      text: AppString.terms3,
                      style: AppStyle.heading6Regular(
                        color: AppColor.descriptionColor,
                      ),
                    ),
                    TextSegment(
                      text: AppString.terms4,
                      style: AppStyle.heading6Regular(
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize16,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
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
                            showPropertyDetailsController
                                .searchImageList[index],
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
                                  color: AppColor.whiteColor.withValues(
                                      alpha: AppSize.appSizePoint50),
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
                            showPropertyDetailsController
                                .searchTitleList[index],
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
                            showPropertyDetailsController
                                .searchRupeesList[index],
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
                      Divider(
                        color: AppColor.descriptionColor
                            .withValues(alpha: AppSize.appSizePoint3),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                            showPropertyDetailsController
                                .searchPropertyImageList.length, (index) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSize.appSize6,
                              horizontal: AppSize.appSize16,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppSize.appSize12),
                              border: Border.all(
                                color: AppColor.primaryColor,
                                width: AppSize.appSizePoint50,
                              ),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  showPropertyDetailsController
                                      .searchPropertyImageList[index],
                                  width: AppSize.appSize18,
                                  height: AppSize.appSize18,
                                ).paddingOnly(right: AppSize.appSize6),
                                Text(
                                  showPropertyDetailsController
                                      .similarPropertyTitleList[index],
                                  style: AppStyle.heading5Medium(
                                      color: AppColor.textColor),
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
                        showPropertyDetailsController
                            .interestingImageList[index],
                      ).paddingOnly(right: AppSize.appSize16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showPropertyDetailsController
                                  .interestingTitleList[index],
                              maxLines: AppSize.size3,
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
      ).paddingOnly(top: AppSize.appSize10),
    );
  }

  Widget _buildDetailRow(String title, String value) {
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
          color: AppColor.descriptionColor
              .withValues(alpha: AppSize.appSizePoint4),
          thickness: AppSize.appSizePoint7,
          height: AppSize.appSize0,
        ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize16),
      ],
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]} ',
        );
  }
}
