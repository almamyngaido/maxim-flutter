import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/gallery_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class GalleryView extends StatelessWidget {
  GalleryView({super.key});

  final GalleryController galleryController = Get.put(GalleryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildGallery(),
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
        AppString.gallery,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  SingleChildScrollView buildGallery() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSize.appSize10),
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.hall,
            style: AppStyle.heading3Medium(color: AppColor.textColor),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: galleryController.hallImageList.length,
            itemBuilder: (context, index) {
              return Image.asset(
                galleryController.hallImageList[index],
                height: AppSize.appSize150,
              ).paddingOnly(bottom: AppSize.appSize4);
            },
          ).paddingOnly(top: AppSize.appSize10),
          Text(
            AppString.kitchen,
            style: AppStyle.heading3Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize14),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: galleryController.kitchenImageList.length,
            itemBuilder: (context, index) {
              return Image.asset(
                galleryController.kitchenImageList[index],
                height: AppSize.appSize150,
              ).paddingOnly(bottom: AppSize.appSize4);
            },
          ).paddingOnly(top: AppSize.appSize10),
          Text(
            AppString.bedroom,
            style: AppStyle.heading3Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize14),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: galleryController.bedroomImageList.length,
            itemBuilder: (context, index) {
              return Image.asset(
                galleryController.bedroomImageList[index],
                height: AppSize.appSize150,
              ).paddingOnly(bottom: AppSize.appSize4);
            },
          ).paddingOnly(top: AppSize.appSize10),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16, right: AppSize.appSize16,
      ),
    );
  }
}
