import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/ajouter_surface_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class AddAmenitiesView extends StatelessWidget {
  AddAmenitiesView({super.key});

  final AddAmenitiesController addAmenitiesController =
      Get.put(AddAmenitiesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildAddAmenitiesFields(),
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
        'Surfaces principales',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildAddAmenitiesFields() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Surfaces du bien',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),

          // Surface habitable (required)
          buildTextField(
            controller: addAmenitiesController.habitableController,
            label: 'Surface habitable',
            hint: 'Ex: 85 m²',
            hasInput: addAmenitiesController.habitableHasInput,
            focusNode: addAmenitiesController.habitableFocusNode,
            required: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ).paddingOnly(top: AppSize.appSize16),

          // Surface terrain (optional)
          buildTextField(
            controller: addAmenitiesController.terrainController,
            label: 'Surface terrain',
            hint: 'Ex: 500 m² (optionnel)',
            hasInput: addAmenitiesController.terrainHasInput,
            focusNode: addAmenitiesController.terrainFocusNode,
            required: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ).paddingOnly(top: AppSize.appSize16),

          // Surface habitable Carrez (optional)
          buildTextField(
            controller: addAmenitiesController.habitableCarrezController,
            label: 'Surface habitable (loi Carrez)',
            hint: 'Ex: 82 m² (optionnel)',
            hasInput: addAmenitiesController.habitableCarrezHasInput,
            focusNode: addAmenitiesController.habitableCarrezFocusNode,
            required: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ).paddingOnly(top: AppSize.appSize16),

          // Surface garage (optional)
          buildTextField(
            controller: addAmenitiesController.garageController,
            label: 'Surface garage',
            hint: 'Ex: 20 m² (optionnel)',
            hasInput: addAmenitiesController.garageHasInput,
            focusNode: addAmenitiesController.garageFocusNode,
            required: false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
          ).paddingOnly(top: AppSize.appSize16),

          // Information note about surfaces
          Container(
            padding: const EdgeInsets.all(AppSize.appSize16),
            margin: const EdgeInsets.only(top: AppSize.appSize24),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: AppColor.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColor.primaryColor,
                      size: AppSize.appSize20,
                    ),
                    const SizedBox(width: AppSize.appSize8),
                    Text(
                      'Information',
                      style:
                          AppStyle.heading6Medium(color: AppColor.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: AppSize.appSize8),
                Text(
                  '• Surface habitable : surface de plancher construite',
                  style: AppStyle.heading6Regular(color: AppColor.textColor),
                ),
                const SizedBox(height: AppSize.appSize4),
                Text(
                  '• Loi Carrez : surface privative d\'un lot de copropriété',
                  style: AppStyle.heading6Regular(color: AppColor.textColor),
                ),
                const SizedBox(height: AppSize.appSize4),
                Text(
                  '• Surface terrain : superficie du terrain (si applicable)',
                  style: AppStyle.heading6Regular(color: AppColor.textColor),
                ),
              ],
            ),
          ),
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
    required FocusNode focusNode,
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
              color: hasInput.value || focusNode.hasFocus
                  ? AppColor.primaryColor
                  : AppColor.descriptionColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasInput.value || focusNode.hasFocus)
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
                focusNode: focusNode,
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
                  hintText: (hasInput.value || focusNode.hasFocus) ? '' : hint,
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

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Obx(() {
        // Use reactive variables to check form validity
        final habitableHasInput =
            addAmenitiesController.habitableHasInput.value;
        final habitableText = addAmenitiesController.habitableController.text;

        // Check validation in real-time
        final canProceedNow = habitableHasInput &&
            habitableText.isNotEmpty &&
            (double.tryParse(habitableText) ?? 0) > 0;

        return CommonButton(
          onPressed: canProceedNow
              ? () {
                  print('🔄 Proceeding to next step from surfaces...');
                  addAmenitiesController.proceedToNextStep();
                }
              : () {
                  // Show why they can't proceed
                  final error = addAmenitiesController.getValidationError();
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
                'Continuer',
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
