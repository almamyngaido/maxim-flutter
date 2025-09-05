import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/post_property_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class PostPropertyView extends StatelessWidget {
  PostPropertyView({super.key});

  final PostPropertyController postPropertyController =
      Get.put(PostPropertyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildPostProperty(context),
      bottomNavigationBar: buildButton(context),
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
        AppString.postProperty,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildPostProperty(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations de base',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),

          // Type de bien (Dropdown)
          buildDropdownField(
            label: 'Type de bien',
            hint: 'Sélectionnez le type de bien',
            value: postPropertyController.selectedTypeBien,
            options: postPropertyController.typeBienOptions,
            onChanged: postPropertyController.updateTypeBien,
            required: true,
          ).paddingOnly(top: AppSize.appSize16),

          // Nombre de pièces total
          buildTextField(
            controller: postPropertyController.nombrePiecesTotalController,
            label: 'Nombre de pièces total',
            hint: 'Ex: 4',
            hasInput: postPropertyController.nombrePiecesTotalHasInput,
            required: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
          ).paddingOnly(top: AppSize.appSize16),

          // Nombre de niveaux (optionnel)
          buildTextField(
            controller: postPropertyController.nombreNiveauxController,
            label: 'Nombre de niveaux',
            hint: 'Ex: 2 (optionnel)',
            hasInput: postPropertyController.nombreNiveauxHasInput,
            required: false,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
          ).paddingOnly(top: AppSize.appSize16),

          // Statut (Dropdown)
          buildDropdownField(
            label: 'Statut',
            hint: 'Sélectionnez le statut',
            value: postPropertyController.selectedStatut,
            options: postPropertyController.statutOptions,
            onChanged: postPropertyController.updateStatut,
            required: true,
          ).paddingOnly(top: AppSize.appSize16),
        ],
      ).paddingOnly(
        top: AppSize.appSize10,
        left: AppSize.appSize16,
        right: AppSize.appSize16,
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required RxBool hasInput,
    required bool required,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Obx(() => Container(
          padding: EdgeInsets.only(
            top: hasInput.value ? AppSize.appSize6 : AppSize.appSize14,
            bottom: hasInput.value ? AppSize.appSize8 : AppSize.appSize14,
            left: AppSize.appSize16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.appSize12),
            border: Border.all(
              color: hasInput.value ||
                      postPropertyController.focusNodes[controller]!.hasFocus
                  ? AppColor.primaryColor
                  : AppColor.descriptionColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasInput.value ||
                  postPropertyController.focusNodes[controller]!.hasFocus)
                Row(
                  children: [
                    Text(
                      label,
                      style: AppStyle.heading6Regular(
                          color: AppColor.primaryColor),
                    ),
                    if (required)
                      Text(
                        ' *',
                        style: AppStyle.heading6Regular(color: Colors.red),
                      ),
                  ],
                ).paddingOnly(bottom: AppSize.appSize2),
              TextFormField(
                controller: controller,
                focusNode: postPropertyController.focusNodes[controller],
                cursorColor: AppColor.primaryColor,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                style: AppStyle.heading4Regular(color: AppColor.textColor),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize0,
                    vertical: AppSize.appSize0,
                  ),
                  isDense: true,
                  hintText: (hasInput.value ||
                          postPropertyController
                              .focusNodes[controller]!.hasFocus)
                      ? ''
                      : hint,
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
                ),
              ),
            ],
          ),
        ));
  }

  Widget buildDropdownField({
    required String label,
    required String hint,
    required RxString value,
    required List<String> options,
    required Function(String) onChanged,
    required bool required,
  }) {
    return Obx(() => Container(
          padding: EdgeInsets.only(
            top: value.value.isNotEmpty ? AppSize.appSize6 : AppSize.appSize14,
            bottom:
                value.value.isNotEmpty ? AppSize.appSize8 : AppSize.appSize14,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.appSize12),
            border: Border.all(
              color: value.value.isNotEmpty
                  ? AppColor.primaryColor
                  : AppColor.descriptionColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (value.value.isNotEmpty)
                Row(
                  children: [
                    Text(
                      label,
                      style: AppStyle.heading6Regular(
                          color: AppColor.primaryColor),
                    ),
                    if (required)
                      Text(
                        ' *',
                        style: AppStyle.heading6Regular(color: Colors.red),
                      ),
                  ],
                ).paddingOnly(bottom: AppSize.appSize2),
              DropdownButtonFormField<String>(
                value: value.value.isEmpty ? null : value.value,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize0,
                    vertical: AppSize.appSize0,
                  ),
                  isDense: true,
                  hintText: value.value.isNotEmpty ? '' : hint,
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
                ),
                style: AppStyle.heading4Regular(color: AppColor.textColor),
                dropdownColor: AppColor.whiteColor,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColor.descriptionColor,
                ),
                items: options.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(
                      option,
                      style:
                          AppStyle.heading4Regular(color: AppColor.textColor),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onChanged(newValue);
                  }
                },
              ),
            ],
          ),
        ));
  }

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Obx(() {
        // FIXED: Use the reactive canProceedValue instead of calling canProceed()
        final canProceedNow = postPropertyController.canProceedValue.value;

        return CommonButton(
          onPressed: canProceedNow
              ? () {
                  print('🔄 Proceeding to next step...');
                  postPropertyController.proceedToNextStep();
                }
              : () {
                  // Show why they can't proceed
                  final error = postPropertyController.getValidationError();
                  if (error != null) {
                    Get.snackbar(
                      'Formulaire incomplet',
                      error,
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                      colorText: AppColor.primaryColor,
                      duration: const Duration(seconds: 2),
                    );
                  }
                },
          backgroundColor: canProceedNow
              ? AppColor.primaryColor
              : AppColor.descriptionColor.withOpacity(0.5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppString.continueButton,
                style: AppStyle.heading5Medium(
                  color: canProceedNow
                      ? AppColor.whiteColor
                      : AppColor.whiteColor.withOpacity(0.7),
                ),
              ),
              if (canProceedNow) ...[
                SizedBox(width: AppSize.appSize8),
                Icon(
                  Icons.arrow_forward,
                  color: AppColor.whiteColor,
                  size: AppSize.appSize18,
                ),
              ]
            ],
          ),
        );
      }),
    ).paddingOnly(
      left: AppSize.appSize16,
      right: AppSize.appSize16,
      bottom: AppSize.appSize26,
      top: AppSize.appSize10,
    );
  }
}
