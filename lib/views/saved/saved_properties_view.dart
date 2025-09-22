import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_rich_text.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bottom_bar_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/saved_properties_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/favoris_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/text_segment_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class SavedPropertiesView extends StatelessWidget {
  SavedPropertiesView({super.key});

  final SavedPropertiesController savedPropertiesController = Get.put(SavedPropertiesController());
  final FavorisController favorisController = Get.put(FavorisController());

  @override
  Widget build(BuildContext context) {
    savedPropertiesController.isSimilarPropertyLiked.value = List<bool>.generate(
        savedPropertiesController.searchImageList.length, (index) => false);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColor.whiteColor,
        appBar: buildAppBar(),
        body: TabBarView(
          children: [
            buildFavoritesList(),
            buildSimilarList(),
            buildSoldList(),
          ],
        ),
      ),
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
            BottomBarController bottomBarController = Get.put(BottomBarController());
            bottomBarController.pageController.jumpToPage(AppSize.size0);
          },
          child: Image.asset(
            Assets.images.backArrow.path,
          ),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Text(
        AppString.savedProperties,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
      bottom: const TabBar(
        indicatorColor: AppColor.primaryColor,
        labelColor: AppColor.primaryColor,
        unselectedLabelColor: AppColor.textColor,
        tabs: [
          Tab(text: "Mes Favoris"),
          Tab(text: "Similaires"),
          Tab(text: "Vendus"),
        ],
      ),
    );
  }

  Widget buildFavoritesList() {
    return Obx(() {
      if (favorisController.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSize.appSize50),
            child: CircularProgressIndicator(
              color: AppColor.primaryColor,
            ),
          ),
        );
      }

      if (favorisController.favoris.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSize.appSize20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: AppSize.appSize50,
                  color: AppColor.descriptionColor,
                ),
                const SizedBox(height: AppSize.appSize16),
                Text(
                  'Aucun favori enregistré',
                  style: AppStyle.heading5Regular(
                    color: AppColor.descriptionColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSize.appSize8),
                Text(
                  'Ajoutez des propriétés à vos favoris pour les retrouver ici',
                  style: AppStyle.heading6Regular(
                    color: AppColor.descriptionColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return buildRealFavoritesList();
    });
  }

  Widget buildRealFavoritesList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 800;

        if (isDesktop) {
          // Affichage en grille pour ordinateur
          return Padding(
            padding: const EdgeInsets.only(
              bottom: AppSize.appSize20,
              top: AppSize.appSize10,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSize.appSize16,
                mainAxisSpacing: AppSize.appSize16,
                childAspectRatio: 1.2,
              ),
              itemCount: favorisController.favoris.length,
              itemBuilder: (context, index) {
                final property = favorisController.favoris[index];
                return buildRealPropertyCard(context, property, isDesktop: true);
              },
            ),
          );
        } else {
          // Affichage en liste pour mobile
          return RefreshIndicator(
            onRefresh: favorisController.rafraichir,
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(
                bottom: AppSize.appSize20,
                top: AppSize.appSize10,
                left: AppSize.appSize16,
                right: AppSize.appSize16,
              ),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: favorisController.favoris.length,
              itemBuilder: (context, index) {
                final property = favorisController.favoris[index];
                return buildRealPropertyCard(context, property, isDesktop: false);
              },
            ),
          );
        }
      },
    );
  }

  Widget buildSimilarList() {
    return buildPropertyList(savedPropertiesController.searchImageList,
                           savedPropertiesController.searchTitleList,
                           savedPropertiesController.searchAddressList,
                           savedPropertiesController.searchRupeesList);
  }

  Widget buildSoldList() {
    return buildPropertyList(savedPropertiesController.searchImageList,
                           savedPropertiesController.searchTitleList,
                           savedPropertiesController.searchAddressList,
                           savedPropertiesController.searchRupeesList,
                           isSold: true);
  }

  Widget buildPropertyList(List<String> images, List<String> titles,
                          List<String> addresses, List<String> prices,
                          {bool showFavoriteIcon = false, bool isSold = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isDesktop = constraints.maxWidth > 800;

        if (isDesktop) {
          // Affichage en grille pour ordinateur
          return Padding(
            padding: const EdgeInsets.only(
              bottom: AppSize.appSize20,
              top: AppSize.appSize10,
              left: AppSize.appSize16,
              right: AppSize.appSize16,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSize.appSize16,
                mainAxisSpacing: AppSize.appSize16,
                childAspectRatio: 1.2,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return buildPropertyCard(
                  context, index, images, titles, addresses, prices,
                  showFavoriteIcon: showFavoriteIcon,
                  isSold: isSold,
                  isDesktop: true,
                );
              },
            ),
          );
        } else {
          // Affichage en liste pour mobile
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.only(
              bottom: AppSize.appSize20, top: AppSize.appSize10,
              left: AppSize.appSize16, right: AppSize.appSize16,
            ),
            physics: const ClampingScrollPhysics(),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return buildPropertyCard(
                context, index, images, titles, addresses, prices,
                showFavoriteIcon: showFavoriteIcon,
                isSold: isSold,
                isDesktop: false,
              );
            },
          );
        }
      },
    );
  }

  Widget buildPropertyCard(BuildContext context, int index, List<String> images,
                          List<String> titles, List<String> addresses, List<String> prices,
                          {bool showFavoriteIcon = false, bool isSold = false, bool isDesktop = false}) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.propertyDetailsView);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSize.appSize10),
        margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.only(bottom: AppSize.appSize16),
        decoration: BoxDecoration(
          color: isSold ? AppColor.descriptionColor.withValues(alpha: 0.1) : AppColor.secondaryColor,
          borderRadius: BorderRadius.circular(AppSize.appSize12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                      child: ColorFiltered(
                        colorFilter: isSold
                          ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                          : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                        child: Image.asset(
                          images[index],
                          height: isDesktop ? AppSize.appSize130 : AppSize.appSize200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (isSold)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(AppSize.appSize12),
                          ),
                          child: const Center(
                            child: Text(
                              "VENDU",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (showFavoriteIcon)
                      Positioned(
                        right: AppSize.appSize6,
                        top: AppSize.appSize6,
                        child: GestureDetector(
                          onTap: () {
                            savedPropertiesController.isSimilarPropertyLiked[index] =
                            !savedPropertiesController.isSimilarPropertyLiked[index];
                          },
                          child: Container(
                            width: AppSize.appSize32,
                            height: AppSize.appSize32,
                            decoration: BoxDecoration(
                              color: AppColor.whiteColor.withValues(alpha:AppSize.appSizePoint50),
                              borderRadius: BorderRadius.circular(AppSize.appSize6),
                            ),
                            child: Center(
                              child: Obx(() => Icon(
                                savedPropertiesController.isSimilarPropertyLiked[index]
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: AppColor.primaryColor,
                                size: AppSize.appSize24,
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
                      isSold ? "Projet Vendu" : AppString.completedProjects,
                      style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                    ),
                    Text(
                      titles[index],
                      style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                    ).paddingOnly(top: AppSize.appSize6),
                    Text(
                      addresses[index],
                      style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                    ).paddingOnly(top: AppSize.appSize6),
                  ],
                ).paddingOnly(top: AppSize.appSize16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      prices[index],
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
                ).paddingOnly(top: AppSize.appSize16),
                Divider(
                  color: AppColor.descriptionColor.withValues(alpha:AppSize.appSizePoint3),
                  height: AppSize.appSize0,
                ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize16),
                Row(
                  children: List.generate(savedPropertiesController.searchPropertyTitleList.length, (propertyIndex) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSize.appSize6, horizontal: AppSize.appSize14,
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
                            savedPropertiesController.searchPropertyImageList[propertyIndex],
                            width: AppSize.appSize18,
                            height: AppSize.appSize18,
                          ).paddingOnly(right: AppSize.appSize6),
                          Text(
                            savedPropertiesController.searchPropertyTitleList[propertyIndex],
                            style: AppStyle.heading5Medium(color: AppColor.textColor),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      CommonRichText(
                        segments: [
                          TextSegment(
                            text: AppString.squareFeet966,
                            style: AppStyle.heading5Regular(color: AppColor.textColor),
                          ),
                          TextSegment(
                            text: AppString.builtUp,
                            style: AppStyle.heading7Regular(color: AppColor.descriptionColor),
                          ),
                        ],
                      ),
                      const VerticalDivider(
                        color: AppColor.descriptionColor,
                        width: AppSize.appSize0,
                        indent: AppSize.appSize2,
                        endIndent: AppSize.appSize2,
                      ).paddingOnly(left: AppSize.appSize8, right: AppSize.appSize8),
                      CommonRichText(
                        segments: [
                          TextSegment(
                            text: AppString.squareFeet773,
                            style: AppStyle.heading5Regular(color: AppColor.textColor),
                          ),
                          TextSegment(
                            text: AppString.builtUp,
                            style: AppStyle.heading7Regular(color: AppColor.descriptionColor),
                          ),
                        ],
                      ),
                    ],
                  ).paddingOnly(top: AppSize.appSize10),
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: AppSize.appSize35,
                        child: ElevatedButton(
                          onPressed: isSold ? null : () {
                            Get.toNamed(AppRoutes.propertyDetailsView);
                          },
                          style: ButtonStyle(
                            elevation: const WidgetStatePropertyAll(AppSize.appSize0),
                            shape: WidgetStatePropertyAll(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSize.appSize12),
                                side: const BorderSide(
                                    color: AppColor.primaryColor,
                                    width: AppSize.appSizePoint7
                                ),
                              ),
                            ),
                            backgroundColor: WidgetStateColor.transparent,
                          ),
                          child: Text(
                            "Voir Détails",
                            style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.appSize10),
                    if (!isSold)
                      Expanded(
                        child: SizedBox(
                          height: AppSize.appSize35,
                          child: ElevatedButton(
                            onPressed: () {
                              savedPropertiesController.launchDialer();
                            },
                            style: ButtonStyle(
                              elevation: const WidgetStatePropertyAll(AppSize.appSize0),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                                  side: const BorderSide(
                                      color: AppColor.primaryColor,
                                      width: AppSize.appSizePoint7
                                  ),
                                ),
                              ),
                              backgroundColor: WidgetStateColor.transparent,
                            ),
                            child: Text(
                              AppString.getCallbackButton,
                              style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                            ),
                          ),
                        ),
                      ),
                  ],
                ).paddingOnly(top: isDesktop ? AppSize.appSize16 : AppSize.appSize26),
              ],
            ),
          ),
        );
  }

  Widget buildRealPropertyCard(BuildContext context, BienImmo property, {bool isDesktop = false}) {
    String getPropertyImage(BienImmo property) {
      if (property.listeImages.isNotEmpty) {
        return property.listeImages.first;
      }
      return Assets.images.searchProperty1.path; // Image par défaut
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.propertyDetailsView, arguments: property);
      },
      child: Container(
        padding: const EdgeInsets.all(AppSize.appSize10),
        margin: isDesktop ? EdgeInsets.zero : const EdgeInsets.only(bottom: AppSize.appSize16),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Image avec bouton de suppression des favoris
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  child: Image.asset(
                    getPropertyImage(property),
                    height: isDesktop ? AppSize.appSize130 : AppSize.appSize200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: isDesktop ? AppSize.appSize130 : AppSize.appSize200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColor.backgroundColor,
                          borderRadius: BorderRadius.circular(AppSize.appSize12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home,
                              size: AppSize.appSize50,
                              color: AppColor.descriptionColor,
                            ),
                            Text(
                              property.typeBien,
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
                      if (property.id != null) {
                        favorisController.retirerDesFavoris(property.id!);
                      }
                    },
                    child: Container(
                      width: AppSize.appSize32,
                      height: AppSize.appSize32,
                      decoration: BoxDecoration(
                        color: AppColor.whiteColor.withValues(alpha: AppSize.appSizePoint50),
                        borderRadius: BorderRadius.circular(AppSize.appSize6),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.favorite,
                          color: AppColor.primaryColor,
                          size: AppSize.appSize24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Détails de la propriété
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize8,
                    vertical: AppSize.appSize4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSize.appSize4),
                  ),
                  child: Text(
                    property.statut,
                    style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                  ),
                ),

                // Titre
                Text(
                  property.displayTitle,
                  style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).paddingOnly(top: AppSize.appSize6),

                // Adresse
                Text(
                  property.displayAddress,
                  style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ).paddingOnly(top: AppSize.appSize6),
              ],
            ).paddingOnly(top: AppSize.appSize16),

            // Prix et note
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
            ).paddingOnly(top: AppSize.appSize16),

            // Divider
            Divider(
              color: AppColor.descriptionColor.withValues(alpha: AppSize.appSizePoint3),
              height: AppSize.appSize0,
            ).paddingOnly(top: AppSize.appSize16, bottom: AppSize.appSize16),

            // Caractéristiques
            Wrap(
              spacing: AppSize.appSize12,
              children: [
                if (property.nombreChambres > 0)
                  _buildFeatureChip(
                    Assets.images.bed.path,
                    '${property.nombreChambres}',
                  ),
                if (property.nombreSallesDeBain > 0)
                  _buildFeatureChip(
                    Assets.images.bath.path,
                    '${property.nombreSallesDeBain}',
                  ),
                _buildFeatureChip(
                  Assets.images.plot.path,
                  property.formattedSurface,
                ),
              ],
            ),

            // Surface détaillée
            CommonRichText(
              segments: [
                TextSegment(
                  text: '${property.surfaceHabitable.toInt()}m²',
                  style: AppStyle.heading5Regular(color: AppColor.textColor),
                ),
                TextSegment(
                  text: ' habitable',
                  style: AppStyle.heading7Regular(color: AppColor.descriptionColor),
                ),
              ],
            ).paddingOnly(top: AppSize.appSize10),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: AppSize.appSize35,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.toNamed(AppRoutes.propertyDetailsView, arguments: property);
                      },
                      style: ButtonStyle(
                        elevation: const WidgetStatePropertyAll(AppSize.appSize0),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.appSize12),
                            side: const BorderSide(
                              color: AppColor.primaryColor,
                              width: AppSize.appSizePoint7,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateColor.transparent,
                      ),
                      child: Text(
                        "Voir Détails",
                        style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSize.appSize10),
                Expanded(
                  child: SizedBox(
                    height: AppSize.appSize35,
                    child: ElevatedButton(
                      onPressed: () {
                        savedPropertiesController.launchDialer();
                      },
                      style: ButtonStyle(
                        elevation: const WidgetStatePropertyAll(AppSize.appSize0),
                        shape: WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSize.appSize12),
                            side: const BorderSide(
                              color: AppColor.primaryColor,
                              width: AppSize.appSizePoint7,
                            ),
                          ),
                        ),
                        backgroundColor: WidgetStateColor.transparent,
                      ),
                      child: Text(
                        "Contacter",
                        style: AppStyle.heading6Regular(color: AppColor.primaryColor),
                      ),
                    ),
                  ),
                ),
              ],
            ).paddingOnly(top: isDesktop ? AppSize.appSize16 : AppSize.appSize26),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String iconPath, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSize.appSize6,
        horizontal: AppSize.appSize12,
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
