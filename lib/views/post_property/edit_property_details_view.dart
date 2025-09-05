import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/edit_property_details_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/bottom_bar/bottom_bar_view.dart';

class EditPropertyDetailsView extends StatelessWidget {
  EditPropertyDetailsView({super.key});

  final EditPropertyDetailsController editPropertyDetailsController =
      Get.put(EditPropertyDetailsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        backgroundColor: AppColor.whiteColor,
        appBar: buildAppBar(),
        body: buildEditPropertyDetailsFields(),
        bottomNavigationBar: buildButton(),
      );
    });
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(AppSize.appSize40),
        child: SizedBox(
          height: AppSize.appSize40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Row(
                children: List.generate(
                    editPropertyDetailsController.propertyList.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      editPropertyDetailsController.updateProperty(index);
                    },
                    child: Obx(() => Container(
                          height: AppSize.appSize25,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: editPropertyDetailsController
                                            .selectProperty.value ==
                                        index
                                    ? AppColor.primaryColor
                                    : AppColor.borderColor,
                                width: AppSize.appSize1,
                              ),
                              right: BorderSide(
                                color: index == AppSize.size3
                                    ? Colors.transparent
                                    : AppColor.borderColor,
                                width: AppSize.appSize1,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              editPropertyDetailsController.propertyList[index],
                              style: AppStyle.heading5Medium(
                                color: editPropertyDetailsController
                                            .selectProperty.value ==
                                        index
                                    ? AppColor.primaryColor
                                    : AppColor.textColor,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEditPropertyDetailsFields() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppString.yourContactDetails,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),
          Obx(() => Container(
                padding: EdgeInsets.only(
                  top:
                      editPropertyDetailsController.hasPhoneNumberFocus.value ||
                              editPropertyDetailsController
                                  .hasPhoneNumberInput.value
                          ? AppSize.appSize6
                          : AppSize.appSize14,
                  bottom:
                      editPropertyDetailsController.hasPhoneNumberFocus.value ||
                              editPropertyDetailsController
                                  .hasPhoneNumberInput.value
                          ? AppSize.appSize8
                          : AppSize.appSize14,
                  left: editPropertyDetailsController.hasPhoneNumberFocus.value
                      ? AppSize.appSize0
                      : AppSize.appSize16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                  border: Border.all(
                    color: editPropertyDetailsController
                                .hasPhoneNumberFocus.value ||
                            editPropertyDetailsController
                                .hasPhoneNumberInput.value
                        ? AppColor.primaryColor
                        : AppColor.descriptionColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    editPropertyDetailsController.hasPhoneNumberFocus.value ||
                            editPropertyDetailsController
                                .hasPhoneNumberInput.value
                        ? Text(
                            AppString.phoneNumber,
                            style: AppStyle.heading6Regular(
                                color: AppColor.primaryColor),
                          ).paddingOnly(
                            left: editPropertyDetailsController
                                    .hasPhoneNumberInput.value
                                ? (editPropertyDetailsController
                                        .hasPhoneNumberFocus.value
                                    ? AppSize.appSize16
                                    : AppSize.appSize0)
                                : AppSize.appSize16,
                            bottom: editPropertyDetailsController
                                    .hasPhoneNumberInput.value
                                ? AppSize.appSize2
                                : AppSize.appSize2,
                          )
                        : const SizedBox.shrink(),
                    Row(
                      children: [
                        editPropertyDetailsController
                                    .hasPhoneNumberFocus.value ||
                                editPropertyDetailsController
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
                                              color: AppColor.primaryColor),
                                        ),
                                        Image.asset(
                                          Assets.images.dropdown.path,
                                          width: AppSize.appSize16,
                                        ).paddingOnly(
                                            left: AppSize.appSize8,
                                            right: AppSize.appSize3),
                                        const VerticalDivider(
                                          color: AppColor.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).paddingOnly(
                                left: editPropertyDetailsController
                                        .hasPhoneNumberInput.value
                                    ? (editPropertyDetailsController
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
                              focusNode: editPropertyDetailsController
                                  .phoneNumberFocusNode,
                              controller: editPropertyDetailsController
                                  .mobileNumberController,
                              cursorColor: AppColor.primaryColor,
                              keyboardType: TextInputType.phone,
                              style: AppStyle.heading4Regular(
                                  color: AppColor.textColor),
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
                                hintText: editPropertyDetailsController
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
              )).paddingOnly(top: AppSize.appSize16),
          Align(
            alignment: Alignment.topRight,
            child: Text(
              AppString.changeAccount,
              style: AppStyle.heading5Regular(color: AppColor.primaryColor),
            ),
          ).paddingOnly(top: AppSize.appSize6),
          Text(
            AppString.lookingToText,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize36),
          Row(
            children: List.generate(
                editPropertyDetailsController.propertyLookingList.length,
                (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    editPropertyDetailsController.updatePropertyLooking(index);
                  },
                  child: Obx(() => Container(
                        margin: const EdgeInsets.only(right: AppSize.appSize16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.appSize16,
                          vertical: AppSize.appSize10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize12),
                          border: Border.all(
                            color: editPropertyDetailsController
                                        .selectPropertyLooking.value ==
                                    index
                                ? AppColor.primaryColor
                                : AppColor.borderColor,
                            width: AppSize.appSize1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            editPropertyDetailsController
                                .propertyLookingList[index],
                            style: AppStyle.heading5Medium(
                              color: editPropertyDetailsController
                                          .selectPropertyLooking.value ==
                                      index
                                  ? AppColor.primaryColor
                                  : AppColor.descriptionColor,
                            ),
                          ),
                        ),
                      )),
                ),
              );
            }),
          ).paddingOnly(top: AppSize.appSize16),
          Text(
            AppString.whatKindOfProperty,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize36),
          Row(
            children: List.generate(
                editPropertyDetailsController.propertyTypeList.length, (index) {
              return GestureDetector(
                onTap: () {
                  editPropertyDetailsController.updatePropertyType(index);
                },
                child: Obx(() => Container(
                      margin: const EdgeInsets.only(right: AppSize.appSize16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize16,
                        vertical: AppSize.appSize10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: editPropertyDetailsController
                                      .selectPropertyType.value ==
                                  index
                              ? AppColor.primaryColor
                              : AppColor.borderColor,
                          width: AppSize.appSize1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          editPropertyDetailsController.propertyTypeList[index],
                          style: AppStyle.heading5Medium(
                            color: editPropertyDetailsController
                                        .selectPropertyType.value ==
                                    index
                                ? AppColor.primaryColor
                                : AppColor.descriptionColor,
                          ),
                        ),
                      ),
                    )),
              );
            }),
          ).paddingOnly(top: AppSize.appSize16),
          Text(
            AppString.selectPropertyType,
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ).paddingOnly(top: AppSize.appSize36),
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppSize.size2,
              crossAxisSpacing: AppSize.appSize16,
              mainAxisSpacing: AppSize.appSize16,
              mainAxisExtent: AppSize.appSize72,
            ),
            shrinkWrap: true,
            padding: const EdgeInsets.only(top: AppSize.appSize16),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: editPropertyDetailsController.propertyType2List.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  editPropertyDetailsController.updateSelectProperty2(index);
                },
                child: Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize16,
                        vertical: AppSize.appSize10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSize.appSize12),
                        border: Border.all(
                          color: editPropertyDetailsController
                                      .selectPropertyType2.value ==
                                  index
                              ? AppColor.primaryColor
                              : AppColor.descriptionColor
                                  .withValues(alpha: AppSize.appSizePoint4),
                          width: AppSize.appSizePoint7,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            editPropertyDetailsController
                                .propertyTypeImageList[index],
                            width: AppSize.appSize24,
                            color: editPropertyDetailsController
                                        .selectPropertyType2.value ==
                                    index
                                ? AppColor.primaryColor
                                : AppColor.descriptionColor,
                          ),
                          Text(
                            editPropertyDetailsController
                                .propertyType2List[index],
                            overflow: TextOverflow.ellipsis,
                            style: AppStyle.heading5Regular(
                              color: editPropertyDetailsController
                                          .selectPropertyType2.value ==
                                      index
                                  ? AppColor.primaryColor
                                  : AppColor.descriptionColor,
                            ),
                          ),
                        ],
                      ),
                    )),
              );
            },
          ),
        ],
      ).paddingOnly(
        top: AppSize.appSize26,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
    );
  }

  Widget buildButton() {
    return CommonButton(
      onPressed: () {
        Future.delayed(const Duration(milliseconds: AppSize.size400), () {
          Get.offAll(() => BottomBarView(initialIndex: 1));
        });
      },
      backgroundColor: AppColor.primaryColor,
      child: Text(
        AppString.saveButton,
        style: AppStyle.heading5Medium(color: AppColor.whiteColor),
      ),
    ).paddingOnly(
      left: AppSize.appSize16,
      right: AppSize.appSize16,
      bottom: AppSize.appSize26,
      top: AppSize.appSize10,
    );
  }
}
