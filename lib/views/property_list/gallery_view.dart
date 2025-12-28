import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class GalleryView extends StatelessWidget {
  GalleryView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get images from navigation arguments
    final Map<String, dynamic>? args = Get.arguments as Map<String, dynamic>?;
    final List<String> images = args?['images'] ?? [];
    final int initialIndex = args?['initialIndex'] ?? 0;

    // Create a PageController with the initial index
    final PageController pageController = PageController(initialPage: initialIndex);
    final RxInt currentImageIndex = initialIndex.obs;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(currentImageIndex, images.length),
      body: buildGallery(images, pageController, currentImageIndex),
    );
  }

  AppBar buildAppBar(RxInt currentImageIndex, int totalImages) {
    return AppBar(
      backgroundColor: Colors.black,
      scrolledUnderElevation: AppSize.appSize0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSize.appSize16),
        child: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.close,
            color: AppColor.whiteColor,
            size: AppSize.appSize24,
          ),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Obx(() => Text(
            '${currentImageIndex.value + 1} / $totalImages',
            style: AppStyle.heading4Medium(color: AppColor.whiteColor),
          )),
      centerTitle: true,
    );
  }

  Widget buildGallery(List<String> images, PageController pageController, RxInt currentImageIndex) {
    if (images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: AppSize.appSize80,
              color: AppColor.descriptionColor,
            ),
            SizedBox(height: AppSize.appSize16),
            Text(
              'Aucune image disponible',
              style: AppStyle.heading4Medium(color: AppColor.whiteColor),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: pageController,
      itemCount: images.length,
      onPageChanged: (index) {
        currentImageIndex.value = index;
      },
      itemBuilder: (context, index) {
        final imageUrl = images[index];

        return Container(
          color: Colors.black,
          child: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: _buildImage(imageUrl),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(String imageUrl) {
    // Check if it's a network URL or local asset
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: AppColor.primaryColor,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: AppSize.appSize60,
                color: AppColor.descriptionColor,
              ),
              SizedBox(height: AppSize.appSize12),
              Text(
                'Erreur de chargement',
                style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
              ),
            ],
          );
        },
      );
    } else {
      // Local asset
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.broken_image_outlined,
                size: AppSize.appSize60,
                color: AppColor.descriptionColor,
              ),
              SizedBox(height: AppSize.appSize12),
              Text(
                'Image non trouvée',
                style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
              ),
            ],
          );
        },
      );
    }
  }
}
