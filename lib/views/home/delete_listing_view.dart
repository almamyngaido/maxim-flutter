import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/delete_listing_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class DeleteListingView extends StatelessWidget {
  DeleteListingView({super.key});

  final DeleteListingController deleteListingController =
      Get.put(DeleteListingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildDeleteListingContent(context),
      bottomNavigationBar: buildDeleteButton(),
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
      title: Text(
        AppString.deleteListing,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildDeleteListingContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: AppSize.appSize16,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Information Card
          Obx(() => Container(
                padding: const EdgeInsets.all(AppSize.appSize16),
                decoration: BoxDecoration(
                  color: AppColor.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  border: Border.all(
                    color: AppColor.negativeColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: AppSize.appSize70,
                      height: AppSize.appSize70,
                      margin: const EdgeInsets.only(right: AppSize.appSize16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                        color: AppColor.secondaryColor,
                      ),
                      child: _buildPropertyImage(
                          deleteListingController.propertyImage.value),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deleteListingController.propertyTitle.value,
                            style: AppStyle.heading5SemiBold(
                                color: AppColor.textColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            deleteListingController.propertyAddress.value,
                            style: AppStyle.heading5Regular(
                                color: AppColor.descriptionColor),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ).paddingOnly(top: AppSize.appSize4),
                          Container(
                            margin:
                                const EdgeInsets.only(top: AppSize.appSize8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize8,
                              vertical: AppSize.appSize4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColor.negativeColor.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSize.appSize6),
                              border: Border.all(
                                color: AppColor.negativeColor.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'À supprimer',
                              style: AppStyle.heading6Regular(
                                  color: AppColor.negativeColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),

          // Warning message
          Container(
            margin: const EdgeInsets.only(top: AppSize.appSize24),
            padding: const EdgeInsets.all(AppSize.appSize16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: AppSize.appSize24,
                ).paddingOnly(right: AppSize.appSize12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attention',
                        style: AppStyle.heading5SemiBold(
                            color: Colors.orange.shade700),
                      ),
                      Text(
                        'Cette action est irréversible. La propriété sera définitivement supprimée de votre compte.',
                        style: AppStyle.heading6Regular(
                            color: Colors.orange.shade600),
                      ).paddingOnly(top: AppSize.appSize4),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Deletion reason selection
          Text(
            'Raison de la suppression',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize32, bottom: AppSize.appSize16),

          // Reasons list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: deleteListingController.listingList.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      deleteListingController.updateListing(index);
                    },
                    child: Obx(() {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSize.appSize12),
                        child: Row(
                          children: [
                            Container(
                              width: AppSize.appSize20,
                              height: AppSize.appSize20,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: deleteListingController
                                              .selectListing.value ==
                                          index
                                      ? AppColor.primaryColor
                                      : AppColor.descriptionColor,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child:
                                  deleteListingController.selectListing.value ==
                                          index
                                      ? Center(
                                          child: Container(
                                            width: AppSize.appSize10,
                                            height: AppSize.appSize10,
                                            decoration: const BoxDecoration(
                                              color: AppColor.primaryColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                            ),
                            Expanded(
                              child: Text(
                                deleteListingController.listingList[index],
                                style: AppStyle.heading5Regular(
                                  color: deleteListingController
                                              .selectListing.value ==
                                          index
                                      ? AppColor.textColor
                                      : AppColor.descriptionColor,
                                ),
                              ).paddingOnly(left: AppSize.appSize12),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  if (index <
                      deleteListingController.listingList.length - 1) ...[
                    Divider(
                      color: AppColor.descriptionColor.withOpacity(0.4),
                      thickness: 0.5,
                      height: 1,
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyImage(String imagePath) {
    if (imagePath.isEmpty) {
      return _buildFallbackImage();
    }

    // Check if it's a network image or asset
    if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppSize.appSize8),
        child: Image.network(
          imagePath,
          width: AppSize.appSize70,
          height: AppSize.appSize70,
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
          width: AppSize.appSize70,
          height: AppSize.appSize70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildFallbackImage();
          },
        ),
      );
    }
  }

  Widget _buildFallbackImage() {
    return Container(
      width: AppSize.appSize70,
      height: AppSize.appSize70,
      decoration: BoxDecoration(
        color: AppColor.descriptionColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSize.appSize8),
      ),
      child: Icon(
        Icons.home_outlined,
        size: AppSize.appSize30,
        color: AppColor.descriptionColor,
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: AppSize.appSize70,
      height: AppSize.appSize70,
      decoration: BoxDecoration(
        color: AppColor.backgroundColor,
        borderRadius: BorderRadius.circular(AppSize.appSize8),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildDeleteButton() {
    return Obx(() => CommonButton(
          onPressed: deleteListingController.isDeleting.value
              ? null
              : () {
                  _showDeleteConfirmation();
                },
          backgroundColor: deleteListingController.isDeleting.value
              ? AppColor.descriptionColor
              : AppColor.negativeColor,
          child: deleteListingController.isDeleting.value
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: AppSize.appSize20,
                      height: AppSize.appSize20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColor.whiteColor),
                      ),
                    ).paddingOnly(right: AppSize.appSize8),
                    Text(
                      'Suppression...',
                      style:
                          AppStyle.heading5Medium(color: AppColor.whiteColor),
                    ),
                  ],
                )
              : Text(
                  AppString.deleteButton,
                  style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                ),
        ).paddingOnly(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
          bottom: AppSize.appSize26,
          top: AppSize.appSize10,
        ));
  }

  void _showDeleteConfirmation() {
    // Validate that a reason is selected
    if (!deleteListingController.validateDeletion()) {
      Get.snackbar(
        'Attention',
        'Veuillez sélectionner une raison pour la suppression',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSize.appSize12),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: AppColor.negativeColor,
              size: AppSize.appSize24,
            ).paddingOnly(right: AppSize.appSize8),
            Text(
              'Confirmer la suppression',
              style: AppStyle.heading4SemiBold(color: AppColor.textColor),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer cette propriété ?',
              style: AppStyle.heading5Regular(color: AppColor.textColor),
            ),
            Text(
              'Raison sélectionnée: ${deleteListingController.getSelectedDeletionReason()}',
              style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
            ).paddingOnly(top: AppSize.appSize8),
            Container(
              margin: const EdgeInsets.only(top: AppSize.appSize16),
              padding: const EdgeInsets.all(AppSize.appSize12),
              decoration: BoxDecoration(
                color: AppColor.negativeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize8),
              ),
              child: Text(
                'Cette action est irréversible.',
                style: AppStyle.heading6Regular(color: AppColor.negativeColor),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              deleteListingController.deleteProperty();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.negativeColor,
              foregroundColor: AppColor.whiteColor,
            ),
            child: Text(
              'Supprimer',
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
          ),
        ],
      ),
    );
  }
}
