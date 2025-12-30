import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/edit_property_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class EditPropertyView extends StatelessWidget {
  EditPropertyView({super.key});

  final EditPropertyController editPropertyController = Get.put(EditPropertyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildEditProperty(),
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
        AppString.editing,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildEditProperty() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppString.propertyID,
          style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
        ),
        ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(top: AppSize.appSize16),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: editPropertyController.editPropertyTitleList.length,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(AppSize.appSize16),
              margin: const EdgeInsets.only(bottom: AppSize.appSize16),
              decoration: BoxDecoration(
                color: AppColor.backgroundColor,
                borderRadius: BorderRadius.circular(AppSize.appSize6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        editPropertyController.editPropertyTitleList[index],
                        style: AppStyle.heading4Medium(color: AppColor.textColor),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Pass property ID and section index to details view
                          Get.toNamed(
                            AppRoutes.editPropertyDetailsView,
                            arguments: {
                              'propertyId': editPropertyController.propertyId,
                              'sectionIndex': index,
                            },
                          );
                        },
                        child: Image.asset(
                          Assets.images.edit.path,
                          width: AppSize.appSize20,
                          color: AppColor.descriptionColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    editPropertyController.editPropertySubtitleList[index],
                    style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
                  ).paddingOnly(top: AppSize.appSize6),
                ],
              ),
            );
          },
        ),
      ],
    ).paddingOnly(
      top: AppSize.appSize10,
      left: AppSize.appSize16, right: AppSize.appSize16,
    );
  }
}
