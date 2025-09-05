import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/add_property_location_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class AddPropertyDetailsView extends StatelessWidget {
  AddPropertyDetailsView({super.key});

  final AddPropertyDetailsController addPropertyDetailsController =
      Get.put(AddPropertyDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildAddPropertyFields(context),
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
        'Adresse du bien',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildAddPropertyFields(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Localisation du bien',
            style: AppStyle.heading4Medium(color: AppColor.textColor),
          ),

          // Numero
          buildTextField(
            controller: addPropertyDetailsController.numeroController,
            label: 'Numéro',
            hint: 'Ex: 123',
            hasInput: addPropertyDetailsController.numeroHasInput,
            required: true,
          ).paddingOnly(top: AppSize.appSize16),

          // Rue
          buildTextField(
            controller: addPropertyDetailsController.rueController,
            label: 'Rue',
            hint: 'Ex: Avenue des Champs-Élysées',
            hasInput: addPropertyDetailsController.rueHasInput,
            required: true,
          ).paddingOnly(top: AppSize.appSize16),

          // Complement (optional)
          buildTextField(
            controller: addPropertyDetailsController.complementController,
            label: 'Complément d\'adresse',
            hint: 'Ex: Bâtiment A, Étage 2 (optionnel)',
            hasInput: addPropertyDetailsController.complementHasInput,
            required: false,
          ).paddingOnly(top: AppSize.appSize16),

          // Boite (optional)
          buildTextField(
            controller: addPropertyDetailsController.boiteController,
            label: 'Boîte postale',
            hint: 'Ex: BP 123 (optionnel)',
            hasInput: addPropertyDetailsController.boiteHasInput,
            required: false,
          ).paddingOnly(top: AppSize.appSize16),

          // Code Postal
          buildTextField(
            controller: addPropertyDetailsController.codePostalController,
            label: 'Code postal',
            hint: 'Ex: 75001',
            hasInput: addPropertyDetailsController.codePostalHasInput,
            required: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ).paddingOnly(top: AppSize.appSize16),

          // Ville
          buildTextField(
            controller: addPropertyDetailsController.villeController,
            label: 'Ville',
            hint: 'Ex: Paris',
            hasInput: addPropertyDetailsController.villeHasInput,
            required: true,
          ).paddingOnly(top: AppSize.appSize16),

          // Departement
          buildTextField(
            controller: addPropertyDetailsController.departementController,
            label: 'Département',
            hint: 'Ex: Paris, Hauts-de-Seine',
            hasInput: addPropertyDetailsController.departementHasInput,
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
                      addPropertyDetailsController
                          .focusNodes[controller]!.hasFocus
                  ? AppColor.primaryColor
                  : AppColor.descriptionColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasInput.value ||
                  addPropertyDetailsController.focusNodes[controller]!.hasFocus)
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
                focusNode: addPropertyDetailsController.focusNodes[controller],
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
                          addPropertyDetailsController
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
                onChanged: (value) {
                  // No need for manual update, RxBool handles reactivity
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
        // FIXED: Access reactive variables properly to trigger reactivity
        final numeroHasInput =
            addPropertyDetailsController.numeroHasInput.value;
        final rueHasInput = addPropertyDetailsController.rueHasInput.value;
        final codePostalHasInput =
            addPropertyDetailsController.codePostalHasInput.value;
        final villeHasInput = addPropertyDetailsController.villeHasInput.value;
        final departementHasInput =
            addPropertyDetailsController.departementHasInput.value;

        // Also check the actual text content for validation
        final codePostalText =
            addPropertyDetailsController.codePostalController.text;

        // Check validation in real-time using the reactive variables
        final canProceedNow = numeroHasInput &&
            rueHasInput &&
            codePostalHasInput &&
            villeHasInput &&
            departementHasInput &&
            codePostalText.length >= 5;

        return CommonButton(
          onPressed: canProceedNow
              ? () {
                  print('🔄 Proceeding to next step from location...');
                  // Call the method directly without Obx issues
                  final error =
                      addPropertyDetailsController.getValidationError();
                  if (error == null) {
                    addPropertyDetailsController.proceedToNextStep();
                  } else {
                    Get.snackbar(
                      'Erreur de validation',
                      error,
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppColor.primaryColor,
                      colorText: AppColor.whiteColor,
                      duration: const Duration(seconds: 3),
                    );
                  }
                }
              : () {
                  // Show why they can't proceed
                  final error =
                      addPropertyDetailsController.getValidationError();
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
          child: Text(
            'Continuer',
            style: AppStyle.heading5Medium(
              color: canProceedNow
                  ? AppColor.whiteColor
                  : AppColor.whiteColor.withOpacity(0.7),
            ),
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
