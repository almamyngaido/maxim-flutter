import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_status_bar.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bottom_bar_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/home_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/messaging_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:timeago/timeago.dart' as timeago;
//import 'package:luxury_real_estate_flutter_ui_kit/views/home/widget/explore_city_bottom_sheet.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final HomeController homeController = Get.put(HomeController());
  final MessagingController messagingController = Get.put(MessagingController());

  @override
  Widget build(BuildContext context) {
    homeController.isTrendPropertyLiked.value = List<bool>.generate(
        homeController.searchImageList.length, (index) => false);

    // Load conversations for recent contacts
    messagingController.loadConversations();

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColor.whiteColor,
          body: buildHome(context),
        ),
        const CommonStatusBar(),
      ],
    );
  }

  Widget buildHome(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Scaffold.of(context).openDrawer();
                    },
                    child: Image.asset(
                      Assets.images.drawer.path,
                      width: AppSize.appSize40,
                      height: AppSize.appSize40,
                    ).paddingOnly(right: AppSize.appSize16),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                            'Bonjour ${homeController.userName.value}',
                            style: AppStyle.heading5Medium(
                                color: AppColor.descriptionColor),
                          )),
                      Text(
                        AppString.welcome,
                        style: AppStyle.heading3Medium(
                            color: AppColor.primaryColor),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.notificationView);
                },
                child: Image.asset(
                  Assets.images.notification.path,
                  width: AppSize.appSize40,
                  height: AppSize.appSize40,
                ),
              )
            ],
          ).paddingOnly(
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
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
              controller: homeController.searchController,
              cursorColor: AppColor.primaryColor,
              style: AppStyle.heading4Regular(color: AppColor.textColor),
              readOnly: true,
              onTap: () {
                Get.toNamed(AppRoutes.searchView);
              },
              decoration: InputDecoration(
                hintText: AppString.searchCity,
                hintStyle:
                    AppStyle.heading4Regular(color: AppColor.descriptionColor),
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
              ),
            ),
          ).paddingOnly(
            top: AppSize.appSize20,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.yourListing,
                style: AppStyle.heading3SemiBold(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () {
                  BottomBarController bottomBarController =
                      Get.put(BottomBarController());
                  bottomBarController.pageController.jumpToPage(AppSize.size1);
                },
                child: Text(
                  AppString.viewAll,
                  style:
                      AppStyle.heading5Medium(color: AppColor.descriptionColor),
                ),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize26,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          // Dynamic "My Listings" Card
          _buildMyListingsCard().paddingOnly(
            left: AppSize.appSize16,
            right: AppSize.appSize16,
            top: AppSize.appSize16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppString.recommendedProject,
                style: AppStyle.heading3SemiBold(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.propertyListView);
                },
                child: Text(
                  AppString.viewAll,
                  style:
                      AppStyle.heading5Medium(color: AppColor.descriptionColor),
                ),
              ),
            ],
          ).paddingOnly(
            top: AppSize.appSize26,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          // Dynamic Recommended Properties
          _buildRecommendedProperties().paddingOnly(top: AppSize.appSize16),

          // Recent Contacts from Messaging
          _buildRecentContacts(),
          // Row(
          //   children: [
          //     Text(
          //       AppString.popularBuilders,
          //       style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          //     ),
          //     Text(
          //       AppString.inWesternMumbai,
          //       style:
          //           AppStyle.heading5Regular(color: AppColor.descriptionColor),
          //     ),
          //   ],
          // ).paddingOnly(
          //   top: AppSize.appSize26,
          //   left: AppSize.appSize16,
          //   right: AppSize.appSize16,
          // ),
          // SizedBox(
          //   height: AppSize.appSize95,
          //   child: ListView.builder(
          //     shrinkWrap: true,
          //     scrollDirection: Axis.horizontal,
          //     physics: const ClampingScrollPhysics(),
          //     padding: const EdgeInsets.only(left: AppSize.appSize16),
          //     itemCount: homeController.popularBuilderImageList.length,
          //     itemBuilder: (context, index) {
          //       return GestureDetector(
          //         onTap: () {
          //           if (index == AppSize.size0) {
          //             Get.toNamed(AppRoutes.popularBuildersView);
          //           }
          //         },
          //         child: Container(
          //           width: AppSize.appSize160,
          //           padding: const EdgeInsets.symmetric(
          //             vertical: AppSize.appSize16,
          //             horizontal: AppSize.appSize10,
          //           ),
          //           margin: const EdgeInsets.only(right: AppSize.appSize16),
          //           decoration: BoxDecoration(
          //             color: AppColor.secondaryColor,
          //             borderRadius: BorderRadius.circular(AppSize.appSize12),
          //           ),
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //             children: [
          //               Center(
          //                 child: Image.asset(
          //                   homeController.popularBuilderImageList[index],
          //                   width: AppSize.appSize30,
          //                   height: AppSize.appSize30,
          //                 ),
          //               ),
          //               Center(
          //                 child: Text(
          //                   homeController.popularBuilderTitleList[index],
          //                   style: AppStyle.heading5Medium(
          //                       color: AppColor.textColor),
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ).paddingOnly(top: AppSize.appSize16),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text(
          //       AppString.upcomingProject,
          //       style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          //     ),
          //     Text(
          //       AppString.viewAll,
          //       style:
          //           AppStyle.heading5Medium(color: AppColor.descriptionColor),
          //     ),
          //   ],
          // ).paddingOnly(
          //   top: AppSize.appSize26,
          //   left: AppSize.appSize16,
          //   right: AppSize.appSize16,
          // ),
          // SizedBox(
          //   height: AppSize.appSize320,
          //   child: ListView.builder(
          //     shrinkWrap: true,
          //     physics: const ClampingScrollPhysics(),
          //     padding: const EdgeInsets.only(left: AppSize.appSize16),
          //     scrollDirection: Axis.horizontal,
          //     itemCount: homeController.upcomingProjectImageList.length,
          //     itemBuilder: (context, index) {
          //       return Container(
          //         width: AppSize.appSize343,
          //         margin: const EdgeInsets.only(right: AppSize.appSize16),
          //         padding: const EdgeInsets.all(AppSize.appSize10),
          //         decoration: BoxDecoration(
          //           color: AppColor.whiteColor,
          //           borderRadius: BorderRadius.circular(AppSize.appSize12),
          //           image: DecorationImage(
          //             image: AssetImage(
          //                 homeController.upcomingProjectImageList[index]),
          //           ),
          //         ),
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           mainAxisAlignment: MainAxisAlignment.end,
          //           children: [
          //             Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               children: [
          //                 Text(
          //                   homeController.upcomingProjectTitleList[index],
          //                   style:
          //                       AppStyle.heading3(color: AppColor.whiteColor),
          //                 ),
          //                 Text(
          //                   homeController.upcomingProjectPriceList[index],
          //                   style:
          //                       AppStyle.heading5(color: AppColor.whiteColor),
          //                 ),
          //               ],
          //             ),
          //             Text(
          //               homeController.upcomingProjectAddressList[index],
          //               style: AppStyle.heading5Regular(
          //                   color: AppColor.whiteColor),
          //             ).paddingOnly(top: AppSize.appSize6),
          //             Text(
          //               homeController.upcomingProjectFlatSizeList[index],
          //               style:
          //                   AppStyle.heading6Medium(color: AppColor.whiteColor),
          //             ).paddingOnly(top: AppSize.appSize6),
          //           ],
          //         ),
          //       );
          //     },
          //   ),
          // ).paddingOnly(top: AppSize.appSize16),

          // Text(
          //   AppString.explorePopularCity,
          //   style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          // ).paddingOnly(
          //   top: AppSize.appSize26,
          //   left: AppSize.appSize16,
          //   right: AppSize.appSize16,
          // ),
          // SizedBox(
          //   height: AppSize.appSize100,
          //   child: ListView.builder(
          //     shrinkWrap: true,
          //     physics: const ClampingScrollPhysics(),
          //     padding: const EdgeInsets.only(left: AppSize.appSize16),
          //     scrollDirection: Axis.horizontal,
          //     itemCount: homeController.popularCityImageList.length,
          //     itemBuilder: (context, index) {
          //       return GestureDetector(
          //         onTap: () {
          //           exploreCityBottomSheet(context);
          //         },
          //         child: Container(
          //           width: AppSize.appSize100,
          //           margin: const EdgeInsets.only(right: AppSize.appSize16),
          //           padding: const EdgeInsets.only(bottom: AppSize.appSize10),
          //           decoration: BoxDecoration(
          //             color: AppColor.whiteColor,
          //             borderRadius: BorderRadius.circular(AppSize.appSize16),
          //             image: DecorationImage(
          //               image: AssetImage(
          //                   homeController.popularCityImageList[index]),
          //             ),
          //           ),
          //           child: Align(
          //             alignment: Alignment.bottomCenter,
          //             child: Text(
          //               homeController.popularCityTitleList[index],
          //               style:
          //                   AppStyle.heading5Medium(color: AppColor.whiteColor),
          //             ),
          //           ),
          //         ),
          //       );
          //     },
          //   ),
          // ).paddingOnly(top: AppSize.appSize16),
        ],
      ).paddingOnly(top: AppSize.appSize50, bottom: AppSize.appSize20),
    );
  }

  Widget _buildMyListingsCard() {
    return Obx(() {
      if (homeController.isLoadingProperties.value) {
        return Container(
          padding: const EdgeInsets.all(AppSize.appSize24),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 197, 204, 212),
            borderRadius: BorderRadius.circular(AppSize.appSize12),
          ),
          child: Center(
            child: CircularProgressIndicator(color: AppColor.whiteColor),
          ),
        );
      }

      if (homeController.userProperties.isEmpty) {
        // No properties - show default card
        return Container(
          padding: const EdgeInsets.all(AppSize.appSize10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 197, 204, 212),
            borderRadius: BorderRadius.circular(AppSize.appSize12),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Image.asset(
                  Assets.images.property1.path,
                  width: AppSize.appSize112,
                ).paddingOnly(right: AppSize.appSize16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        'Aucune propriété',
                        style: AppStyle.heading5Medium(
                            color: AppColor.whiteColor),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ajoutez votre première',
                            style: AppStyle.heading5SemiBold(
                                color: AppColor.whiteColor),
                          ),
                          Text(
                            'propriété immobilière',
                            style: AppStyle.heading5Regular(
                                color: AppColor.whiteColor),
                          ),
                        ],
                      ),
                      IntrinsicWidth(
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.postPropertyView);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ajouter maintenant',
                                style: AppStyle.heading5Medium(
                                    color: AppColor.whiteColor),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: AppSize.appSize3),
                                height: AppSize.appSize1,
                                color: AppColor.whiteColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Get the first property to display
      final property = homeController.userProperties.first;
      final propertyId = property['id']?.toString() ?? '';

      // Get property details
      String price = 'Prix sur demande';
      if (property['prix'] != null && property['prix']['hai'] != null) {
        double priceValue = property['prix']['hai'].toDouble();
        if (priceValue >= 1000000) {
          price = '${(priceValue / 1000000).toStringAsFixed(1)}M €';
        } else if (priceValue >= 1000) {
          price = '${(priceValue / 1000).toStringAsFixed(0)}K €';
        } else {
          price = '${priceValue.toStringAsFixed(0)} €';
        }
      }

      String title = property['typeBien']?.toString() ?? 'Propriété';
      if (property['description'] != null &&
          property['description']['titre'] != null &&
          property['description']['titre'].toString().isNotEmpty) {
        title = property['description']['titre'].toString();
      } else {
        int rooms = property['nombrePiecesTotal']?.toInt() ?? 0;
        if (rooms > 0) {
          title = '$title ${rooms}P';
        }
      }

      String address = '';
      if (property['localisation'] != null) {
        List<String> addressParts = [];
        if (property['localisation']['ville'] != null) {
          addressParts.add(property['localisation']['ville'].toString());
        }
        if (property['localisation']['codePostal'] != null) {
          addressParts.add(property['localisation']['codePostal'].toString());
        }
        address = addressParts.join(', ');
      }
      if (address.isEmpty) {
        address = 'Adresse non spécifiée';
      }

      // Get image
      String? imageUrl;
      bool isNetworkImage = false;
      if (property['listeImages'] != null &&
          property['listeImages'] is List &&
          (property['listeImages'] as List).isNotEmpty) {
        String imagePath = (property['listeImages'] as List).first.toString();
        if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
          imageUrl = imagePath;
          isNetworkImage = true;
        } else {
          imageUrl = '${ApiConfig.baseUrl}/$imagePath';
          isNetworkImage = true;
        }
      }

      // Build the original design with dynamic data
      return GestureDetector(
        onTap: () {
          if (propertyId.isNotEmpty) {
            Get.toNamed(
              AppRoutes.showPropertyDetailsView,
              arguments: propertyId,
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(AppSize.appSize10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 197, 204, 212),
            borderRadius: BorderRadius.circular(AppSize.appSize12),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Property Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSize.appSize8),
                  child: imageUrl != null && isNetworkImage
                      ? Image.network(
                          imageUrl,
                          width: AppSize.appSize112,
                          height: AppSize.appSize112,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              Assets.images.property1.path,
                              width: AppSize.appSize112,
                              height: AppSize.appSize112,
                              fit: BoxFit.cover,
                            );
                          },
                        )
                      : Image.asset(
                          Assets.images.property1.path,
                          width: AppSize.appSize112,
                          height: AppSize.appSize112,
                          fit: BoxFit.cover,
                        ),
                ).paddingOnly(right: AppSize.appSize16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        price,
                        style: AppStyle.heading5Medium(
                            color: AppColor.whiteColor),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppStyle.heading5SemiBold(
                                color: AppColor.whiteColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            address,
                            style: AppStyle.heading5Regular(
                                color: AppColor.whiteColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      IntrinsicWidth(
                        child: GestureDetector(
                          onTap: () {
                            Get.toNamed(AppRoutes.activityView);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppString.VoirListe,
                                style: AppStyle.heading5Medium(
                                    color: AppColor.whiteColor),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: AppSize.appSize3),
                                height: AppSize.appSize1,
                                color: AppColor.whiteColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRecommendedProperties() {
    return Obx(() {
      if (homeController.isLoadingAllProperties.value) {
        return Container(
          height: AppSize.appSize250,
          padding: EdgeInsets.symmetric(horizontal: AppSize.appSize16),
          child: Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          ),
        );
      }

      if (homeController.allProperties.isEmpty) {
        return Container(
          height: AppSize.appSize200,
          margin: EdgeInsets.symmetric(horizontal: AppSize.appSize16),
          padding: EdgeInsets.all(AppSize.appSize24),
          decoration: BoxDecoration(
            color: AppColor.secondaryColor,
            borderRadius: BorderRadius.circular(AppSize.appSize12),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_outlined,
                  size: AppSize.appSize50,
                  color: AppColor.descriptionColor,
                ),
                SizedBox(height: AppSize.appSize12),
                Text(
                  'Aucune propriété disponible',
                  style: AppStyle.heading5Medium(color: AppColor.textColor),
                ),
              ],
            ),
          ),
        );
      }

      // Limit to 4 properties
      final displayProperties = homeController.allProperties.take(4).toList();

      return SizedBox(
        height: AppSize.appSize282,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: AppSize.appSize16),
          itemCount: displayProperties.length,
          itemBuilder: (context, index) {
            final property = displayProperties[index];
            final propertyId = property['id']?.toString() ?? '';

            // Get property details
            String price = 'Prix sur demande';
            if (property['prix'] != null && property['prix']['hai'] != null) {
              double priceValue = property['prix']['hai'].toDouble();
              if (priceValue >= 1000000) {
                price = '${(priceValue / 1000000).toStringAsFixed(1)}M €';
              } else if (priceValue >= 1000) {
                price = '${(priceValue / 1000).toStringAsFixed(0)}K €';
              } else {
                price = '${priceValue.toStringAsFixed(0)} €';
              }
            }

            String title = property['typeBien']?.toString() ?? 'Propriété';
            if (property['description'] != null &&
                property['description']['titre'] != null &&
                property['description']['titre'].toString().isNotEmpty) {
              title = property['description']['titre'].toString();
            }

            String address = '';
            if (property['localisation'] != null) {
              List<String> addressParts = [];
              if (property['localisation']['ville'] != null) {
                addressParts.add(property['localisation']['ville'].toString());
              }
              address = addressParts.join(', ');
            }
            if (address.isEmpty) {
              address = 'Adresse non disponible';
            }

            // Get image
            String? imageUrl;
            bool isNetworkImage = false;
            if (property['listeImages'] != null &&
                property['listeImages'] is List &&
                (property['listeImages'] as List).isNotEmpty) {
              String imagePath = (property['listeImages'] as List).first.toString();
              if (imagePath.startsWith('http://') ||
                  imagePath.startsWith('https://')) {
                imageUrl = imagePath;
                isNetworkImage = true;
              } else {
                imageUrl = '${ApiConfig.baseUrl}/$imagePath';
                isNetworkImage = true;
              }
            }

            // Format date (use createdAt or current date)
            String dateText = 'Récent';
            if (property['createdAt'] != null) {
              try {
                DateTime createdDate = DateTime.parse(property['createdAt'].toString());
                DateTime now = DateTime.now();
                int daysDiff = now.difference(createdDate).inDays;

                if (daysDiff == 0) {
                  dateText = 'Aujourd\'hui';
                } else if (daysDiff == 1) {
                  dateText = 'Hier';
                } else if (daysDiff < 7) {
                  dateText = 'Il y a $daysDiff jours';
                } else if (daysDiff < 30) {
                  int weeks = (daysDiff / 7).floor();
                  dateText = 'Il y a $weeks semaine${weeks > 1 ? 's' : ''}';
                } else {
                  int months = (daysDiff / 30).floor();
                  dateText = 'Il y a $months mois';
                }
              } catch (e) {
                dateText = 'Récent';
              }
            }

            return GestureDetector(
              onTap: () {
                if (propertyId.isNotEmpty) {
                  Get.toNamed(
                    AppRoutes.showPropertyDetailsView,
                    arguments: propertyId,
                  );
                }
              },
              child: Container(
                width: AppSize.appSize200,
                padding: EdgeInsets.all(AppSize.appSize10),
                margin: EdgeInsets.only(right: AppSize.appSize16),
                decoration: BoxDecoration(
                  color: AppColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Property Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppSize.appSize8),
                      child: imageUrl != null && isNetworkImage
                          ? Image.network(
                              imageUrl,
                              height: AppSize.appSize130,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: AppSize.appSize130,
                                  color: AppColor.backgroundColor,
                                  child: Icon(
                                    Icons.home_outlined,
                                    size: AppSize.appSize50,
                                    color: AppColor.descriptionColor,
                                  ),
                                );
                              },
                            )
                          : Container(
                              height: AppSize.appSize130,
                              color: AppColor.backgroundColor,
                              child: Icon(
                                Icons.home_outlined,
                                size: AppSize.appSize50,
                                color: AppColor.descriptionColor,
                              ),
                            ),
                    ),
                    SizedBox(height: AppSize.appSize8),
                    // Price
                    Container(
                      padding: EdgeInsets.all(AppSize.appSize6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColor.primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                      ),
                      child: Center(
                        child: Text(
                          price,
                          style: AppStyle.heading5Medium(
                              color: AppColor.primaryColor),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSize.appSize8),
                    // Title and Address
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppStyle.heading6Medium(
                              color: AppColor.textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSize.appSize4),
                        Text(
                          address,
                          style: AppStyle.heading6Regular(
                              color: AppColor.descriptionColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSize.appSize4),
                    // Date
                    Text(
                      dateText,
                      style: AppStyle.heading7Regular(
                          color: AppColor.descriptionColor),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  /// Build recent contacts section from messaging conversations
  Widget _buildRecentContacts() {
    // Configure timeago for French
    timeago.setLocaleMessages('fr', timeago.FrMessages());

    return Obx(() {
      print('🔍 Total conversations: ${messagingController.conversations.length}');

      // Get conversations with valid participant data
      final contactsToShow = messagingController.conversations
          .where((conv) => conv.otherParticipant != null)
          .take(5)
          .toList();

      print('🔍 Contacts with participant data: ${contactsToShow.length}');

      if (contactsToShow.isEmpty) {
        print('⚠️ No contacts to show - hiding Recent Contacts section');
        return const SizedBox(); // Don't show section if no contacts
      }

      print('✅ Showing ${contactsToShow.length} recent contacts');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contacts récents',
            style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          ).paddingOnly(
            top: AppSize.appSize26,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          SizedBox(
            height: AppSize.appSize150,
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(left: AppSize.appSize16),
              itemCount: contactsToShow.length,
              itemBuilder: (context, index) {
                final conversation = contactsToShow[index];
                final participant = conversation.otherParticipant!;
                final timeAgo = timeago.format(
                  conversation.lastMessageAt,
                  locale: 'fr',
                );

                return GestureDetector(
                  onTap: () {
                    // Navigate to chat with this contact
                    Get.toNamed(
                      AppRoutes.chatView,
                      arguments: {
                        'conversationId': conversation.id,
                        'propertyTitle':
                            conversation.bienImmo?.titre ?? 'Propriété',
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSize.appSize10),
                    margin: const EdgeInsets.only(right: AppSize.appSize16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColor.descriptionColor
                            .withValues(alpha: AppSize.appSizePoint50),
                      ),
                      borderRadius: BorderRadius.circular(AppSize.appSize12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSize.appSize10),
                          decoration: BoxDecoration(
                            color: AppColor.backgroundColor,
                            borderRadius:
                                BorderRadius.circular(AppSize.appSize16),
                          ),
                          child: Row(
                            children: [
                              // Avatar with initials
                              Container(
                                width: AppSize.appSize50,
                                height: AppSize.appSize50,
                                decoration: BoxDecoration(
                                  color: AppColor.primaryColor
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(
                                      AppSize.appSize25),
                                ),
                                child: Center(
                                  child: Text(
                                    participant.prenom.isNotEmpty
                                        ? participant.prenom[0].toUpperCase()
                                        : participant.nom[0].toUpperCase(),
                                    style: AppStyle.heading3SemiBold(
                                        color: AppColor.primaryColor),
                                  ),
                                ),
                              ).paddingOnly(right: AppSize.appSize10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    participant.fullName,
                                    style: AppStyle.heading4Medium(
                                        color: AppColor.textColor),
                                  ).paddingOnly(bottom: AppSize.appSize4),
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Contact',
                                          style: AppStyle.heading5Regular(
                                              color: AppColor.descriptionColor),
                                        ),
                                        const VerticalDivider(
                                          color: AppColor.borderColor,
                                          width: AppSize.appSize20,
                                          indent: AppSize.appSize2,
                                          endIndent: AppSize.appSize2,
                                        ),
                                        Text(
                                          timeAgo,
                                          style: AppStyle.heading5Regular(
                                              color: AppColor.descriptionColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Phone number
                            if (participant.phoneNumber != null)
                              Row(
                                children: [
                                  Image.asset(
                                    Assets.images.call.path,
                                    width: AppSize.appSize14,
                                  ).paddingOnly(right: AppSize.appSize6),
                                  Text(
                                    participant.phoneNumber!,
                                    style: AppStyle.heading6Regular(
                                        color: AppColor.primaryColor),
                                  ),
                                ],
                              ),
                            // Email
                            Row(
                              children: [
                                Image.asset(
                                  Assets.images.email.path,
                                  width: AppSize.appSize14,
                                ).paddingOnly(right: AppSize.appSize6),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                      maxWidth: AppSize.appSize200),
                                  child: Text(
                                    participant.email,
                                    style: AppStyle.heading6Regular(
                                        color: AppColor.primaryColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ).paddingOnly(
                                top: participant.phoneNumber != null
                                    ? AppSize.appSize8
                                    : 0),
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
}
