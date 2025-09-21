import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/activity_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/activity/widgets/listings_states_bottom_sheet.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/activity/widgets/sort_by_listing_bottom_sheet.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/home/widget/manage_property_bottom_sheet.dart';

class ActivityView extends StatelessWidget {
  ActivityView({super.key});

  final ActivityController activityController = Get.put(ActivityController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: AppColor.whiteColor,
          appBar: buildAppBar(),
          body: buildActivityView(context),
        ));
  }

  Widget buildActivityView(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => activityController.refreshProperties(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: AppSize.appSize20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with filters and sorting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    listingStatesBottomSheet(context);
                  },
                  child: Row(
                    children: [
                      Text(
                        activityController.deleteShowing.value == true
                            ? AppString.deleteListings
                            : AppString.yourListing,
                        style: AppStyle.heading3SemiBold(
                            color: AppColor.textColor),
                      ).paddingOnly(right: AppSize.appSize6),
                      Image.asset(
                        Assets.images.dropdown.path,
                        width: AppSize.appSize20,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    sortByListingBottomSheet(context);
                  },
                  child: Text(
                    AppString.sortByText,
                    style:
                        AppStyle.heading5Medium(color: AppColor.primaryColor),
                  ),
                )
              ],
            ),

            // Search bar
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
                controller: activityController.searchListController,
                cursorColor: AppColor.primaryColor,
                style: AppStyle.heading4Regular(color: AppColor.textColor),
                decoration: InputDecoration(
                  hintText: AppString.searchListing,
                  hintStyle: AppStyle.heading4Regular(
                      color: AppColor.descriptionColor),
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
            ).paddingOnly(top: AppSize.appSize26),

            // Properties count indicator
            if (!activityController.isLoading.value) ...[
              Padding(
                padding: const EdgeInsets.only(top: AppSize.appSize16),
                child: Text(
                  '${activityController.filteredProperties.length} propriété(s) trouvée(s)',
                  style: AppStyle.heading5Regular(
                      color: AppColor.descriptionColor),
                ),
              ),
            ],

            // Main content
            _buildMainContent(context),
          ],
        ).paddingOnly(
          top: AppSize.appSize10,
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    // Loading state
    if (activityController.isLoading.value) {
      return _buildLoadingState();
    }

    // Error state
    if (activityController.hasError.value) {
      return _buildErrorState();
    }

    // Empty state
    if (activityController.filteredProperties.isEmpty) {
      return _buildEmptyState();
    }

    // Success state with properties
    return _buildPropertiesList(context);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator()
              .paddingOnly(bottom: AppSize.appSize16),
          Text(
            'Chargement de vos propriétés...',
            style: AppStyle.heading4Regular(color: AppColor.descriptionColor),
          ),
        ],
      ),
    ).paddingOnly(top: AppSize.appSize100);
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: AppSize.appSize60,
            color: AppColor.negativeColor,
          ).paddingOnly(bottom: AppSize.appSize16),
          Text(
            'Erreur de chargement',
            style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          ).paddingOnly(bottom: AppSize.appSize8),
          Text(
            activityController.errorMessage.value,
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            textAlign: TextAlign.center,
          ).paddingOnly(bottom: AppSize.appSize24),
          ElevatedButton(
            onPressed: () => activityController.refreshProperties(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primaryColor,
              foregroundColor: AppColor.whiteColor,
            ),
            child: Text('Réessayer'),
          ),
        ],
      ),
    ).paddingOnly(top: AppSize.appSize100);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined,
            size: AppSize.appSize80,
            color: AppColor.descriptionColor,
          ).paddingOnly(bottom: AppSize.appSize16),
          Text(
            'Aucune propriété trouvée',
            style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          ).paddingOnly(bottom: AppSize.appSize8),
          Text(
            activityController.searchListController.text.isNotEmpty
                ? 'Aucun résultat pour votre recherche'
                : 'Vous n\'avez pas encore de propriétés',
            style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            textAlign: TextAlign.center,
          ).paddingOnly(bottom: AppSize.appSize24),
          if (activityController.searchListController.text.isNotEmpty) ...[
            ElevatedButton(
              onPressed: () {
                activityController.searchListController.clear();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: AppColor.whiteColor,
              ),
              child: Text('Effacer la recherche'),
            ),
          ] else ...[
            ElevatedButton(
              onPressed: () {
                // Navigate to add property page
                // Get.toNamed(AppRoutes.addPropertyView);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primaryColor,
                foregroundColor: AppColor.whiteColor,
              ),
              child: Text('Ajouter une propriété'),
            ),
          ],
        ],
      ),
    ).paddingOnly(top: AppSize.appSize100);
  }

  Widget _buildPropertiesList(BuildContext context) {
    return activityController.deleteShowing.value == true
        ? _buildDeleteModeList(context)
        : _buildNormalList(context);
  }

  Widget _buildDeleteModeList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: AppSize.appSize26),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activityController.filteredProperties.length,
      itemBuilder: (context, index) {
        final property = activityController.filteredProperties[index];
        final propertyId = activityController.getPropertyId(property);

        return Container(
          margin: const EdgeInsets.only(bottom: AppSize.appSize26),
          padding: const EdgeInsets.all(AppSize.appSize16),
          decoration: BoxDecoration(
            color: AppColor.backgroundColor,
            borderRadius: BorderRadius.circular(AppSize.appSize12),
          ),
          child: Row(
            children: [
              _buildPropertyImage(
                activityController.propertyListImage[index],
                index,
              ).paddingOnly(right: AppSize.appSize16),
              Expanded(
                child: SizedBox(
                  height: AppSize.appSize110,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            activityController.propertyListRupee[index],
                            style: AppStyle.heading5Medium(
                                color: AppColor.textColor),
                          ),
                          GestureDetector(
                            onTap: () {
                              _showDeleteConfirmation(context, propertyId);
                            },
                            child: Text(
                              AppString.deleteButton,
                              style: AppStyle.heading5Medium(
                                  color: AppColor.negativeColor),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        activityController.propertyListTitle[index],
                        style: AppStyle.heading5SemiBold(
                            color: AppColor.textColor),
                      ),
                      Text(
                        activityController.propertyListAddress[index],
                        style: AppStyle.heading5Regular(
                            color: AppColor.descriptionColor),
                      ),
                      // FIXED: Pass property data to bottom sheet
                      GestureDetector(
                        onTap: () {
                          print(
                              '🔍 DEBUG: Manage property tapped for index: $index (delete mode)');
                          print('🔍 DEBUG: Property data: $property');

                          // ✅ FIXED: Pass the property data to the bottom sheet
                          managePropertyBottomSheet(context,
                              property: property);
                        },
                        child: Text(
                          AppString.manageProperty,
                          style: AppStyle.heading5Medium(
                              color: AppColor.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNormalList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: AppSize.appSize26),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activityController.filteredProperties.length,
      itemBuilder: (context, index) {
        final property = activityController.filteredProperties[index];
        final propertyId = activityController.getPropertyId(property);
        final propertyStatus = activityController.getPropertyStatus(property);

        return GestureDetector(
          onTap: () {
            // Navigate to property details
            _navigateToPropertyDetails(propertyId);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: AppSize.appSize26),
            padding: const EdgeInsets.all(AppSize.appSize16),
            decoration: BoxDecoration(
              color: AppColor.backgroundColor,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildPropertyImage(
                  activityController.propertyListImage[index],
                  index,
                ).paddingOnly(right: AppSize.appSize16),
                Expanded(
                  child: SizedBox(
                    height: AppSize.appSize110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              activityController.propertyListRupee[index],
                              style: AppStyle.heading5Medium(
                                  color: AppColor.textColor),
                            ),
                            _buildStatusChip(propertyStatus),
                          ],
                        ),
                        Text(
                          activityController.propertyListTitle[index],
                          style: AppStyle.heading5SemiBold(
                              color: AppColor.textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          activityController.propertyListAddress[index],
                          style: AppStyle.heading5Regular(
                              color: AppColor.descriptionColor),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // FIXED: Pass property data to bottom sheet
                        GestureDetector(
                          onTap: () {
                            print(
                                '🔍 DEBUG: Manage property tapped for index: $index');
                            print('🔍 DEBUG: Property data: $property');

                            // ✅ FIXED: Pass the property data to the bottom sheet
                            managePropertyBottomSheet(context,
                                property: property);
                          },
                          child: Text(
                            AppString.manageProperty,
                            style: AppStyle.heading5Medium(
                                color: AppColor.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPropertyImage(String imagePath, int index) {
    // Check if it's a network image or asset
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSize.appSize8),
        child: Image.network(
          imagePath,
          width: AppSize.appSize90,
          height: AppSize.appSize90,
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
        borderRadius: BorderRadius.circular(AppSize.appSize8),
        child: Image.asset(
          imagePath,
          width: AppSize.appSize90,
          height: AppSize.appSize90,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  Widget _buildFallbackImage() {
    return Container(
      width: AppSize.appSize90,
      height: AppSize.appSize90,
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(AppSize.appSize8),
      ),
      child: Icon(
        Icons.home_outlined,
        size: AppSize.appSize40,
        color: AppColor.descriptionColor,
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: AppSize.appSize90,
      height: AppSize.appSize90,
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(AppSize.appSize8),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String displayStatus;

    switch (status.toLowerCase()) {
      case 'à vendre':
        chipColor = AppColor.primaryColor;
        displayStatus = 'Actif';
        break;
      case 'vendu':
        chipColor = Colors.green;
        displayStatus = 'Vendu';
        break;
      case 'expiré':
        chipColor = Colors.orange;
        displayStatus = 'Expiré';
        break;
      case 'brouillon':
        chipColor = Colors.grey;
        displayStatus = 'Brouillon';
        break;
      default:
        chipColor = AppColor.descriptionColor;
        displayStatus = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.appSize8,
        vertical: AppSize.appSize4,
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        displayStatus,
        style: AppStyle.heading6Regular(color: chipColor),
      ),
    );
  }

  void _navigateToPropertyDetails(String propertyId) {
    // Navigate to property details page
    // Get.toNamed(AppRoutes.propertyDetailsView, arguments: propertyId);
    print('Navigate to property details: $propertyId');
  }

  void _showDeleteConfirmation(BuildContext context, String propertyId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette propriété?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                activityController.deleteProperty(propertyId);
              },
              style:
                  TextButton.styleFrom(foregroundColor: AppColor.negativeColor),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
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
            if (activityController.deleteShowing.value == true) {
              // If in delete mode, just exit delete mode
              activityController.deleteShowing.value = false;
              activityController.selectListing.value = AppSize.size0;
            } else {
              // Navigate back to the previous screen (HomeView)
              Get.back();
            }
          },
          child: Image.asset(
            Assets.images.backArrow.path,
          ),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      actions: [
        // Refresh button
        IconButton(
          onPressed: () => activityController.refreshProperties(),
          icon: Icon(
            Icons.refresh,
            color: AppColor.primaryColor,
          ),
        ),
      ],
    );
  }
}
