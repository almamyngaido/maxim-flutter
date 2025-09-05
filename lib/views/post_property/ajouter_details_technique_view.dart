import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/ajouter_details_technique_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class TechnicalDetailsView extends StatelessWidget {
  TechnicalDetailsView({super.key});

  final TechnicalDetailsController technicalDetailsController =
      Get.put(TechnicalDetailsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildTechnicalDetailsFields(),
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
          onTap: () => Get.back(),
          child: Image.asset(Assets.images.backArrow.path),
        ),
      ),
      leadingWidth: AppSize.appSize40,
      title: Text(
        'Détails techniques',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildTechnicalDetailsFields() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
            child: Text(
              'Informations techniques du bien',
              style: AppStyle.heading4Medium(color: AppColor.textColor),
            ),
          ),

          const SizedBox(height: AppSize.appSize24),

          // Section 1: Chauffage et Climatisation
          buildSectionHeader('Chauffage et climatisation',
              'Sélectionnez les systèmes présents'),
          buildHeatingSection(),

          const SizedBox(height: AppSize.appSize32),

          // Section 2: Sources d'énergie
          buildSectionHeader(
              'Sources d\'énergie', 'Sélectionnez les énergies utilisées'),
          buildEnergySection(),

          const SizedBox(height: AppSize.appSize32),

          // Section 3: Informations du bâtiment
          buildSectionHeader(
              'Informations du bâtiment', 'Détails sur la construction'),
          buildBuildingInfoSection(),

          const SizedBox(height: AppSize.appSize32),

          // Section 4: Orientations
          buildSectionHeader(
              'Orientations', 'Orientation des espaces extérieurs (optionnel)'),
          buildOrientationSection(),
        ],
      ),
    );
  }

  Widget buildSectionHeader(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyle.heading5Medium(color: AppColor.textColor),
          ),
          const SizedBox(height: AppSize.appSize4),
          Text(
            description,
            style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
          ),
          const SizedBox(height: AppSize.appSize16),
        ],
      ),
    );
  }

  Widget buildHeatingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      child: Wrap(
        spacing: AppSize.appSize8,
        runSpacing: AppSize.appSize8,
        children: technicalDetailsController.heatingOptions.map((heating) {
          return buildTechnicalChip(
            key: heating['key'],
            label: heating['label'],
            description: heating['description'],
            value: technicalDetailsController.getHeatingValue(heating['key']),
            onTap: () =>
                technicalDetailsController.toggleHeating(heating['key']),
          );
        }).toList(),
      ),
    );
  }

  Widget buildEnergySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      child: Wrap(
        spacing: AppSize.appSize8,
        runSpacing: AppSize.appSize8,
        children: technicalDetailsController.energyOptions.map((energy) {
          return buildTechnicalChip(
            key: energy['key'],
            label: energy['label'],
            description: energy['description'],
            value: technicalDetailsController.getEnergyValue(energy['key']),
            onTap: () => technicalDetailsController.toggleEnergy(energy['key']),
          );
        }).toList(),
      ),
    );
  }

  Widget buildBuildingInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      child: Column(
        children: [
          // Year of construction
          buildTextField(
            controller: technicalDetailsController.anneeConstructionController,
            focusNode: technicalDetailsController.anneeConstructionFocusNode,
            label: 'Année de construction',
            hint: 'Ex: 1990 (optionnel)',
            hasInput: technicalDetailsController.anneeConstructionHasInput,
            required: false,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
          ),

          const SizedBox(height: AppSize.appSize16),

          // Copropriete toggle
          buildBooleanTile(
            label: 'En copropriété',
            description: 'Le bien fait-il partie d\'une copropriété ?',
            value: technicalDetailsController.copropriete,
            onTap: () => technicalDetailsController.toggleCopropriete(),
          ),
        ],
      ),
    );
  }

  Widget buildOrientationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      child: Column(
        children: [
          // Jardin orientation
          buildDropdownField(
            label: 'Orientation du jardin',
            hint: 'Sélectionnez l\'orientation',
            value: technicalDetailsController.orientationJardin,
            options: technicalDetailsController.orientationOptions,
            onChanged: technicalDetailsController.updateOrientationJardin,
            required: false,
          ),

          const SizedBox(height: AppSize.appSize16),

          // Terrasse orientation
          buildDropdownField(
            label: 'Orientation de la terrasse',
            hint: 'Sélectionnez l\'orientation',
            value: technicalDetailsController.orientationTerrasse,
            options: technicalDetailsController.orientationOptions,
            onChanged: technicalDetailsController.updateOrientationTerrasse,
            required: false,
          ),

          const SizedBox(height: AppSize.appSize16),

          // Main orientation
          buildDropdownField(
            label: 'Orientation principale',
            hint: 'Orientation générale du bien',
            value: technicalDetailsController.orientationPrincipale,
            options: technicalDetailsController.orientationOptions,
            onChanged: technicalDetailsController.updateOrientationPrincipale,
            required: false,
          ),
        ],
      ),
    );
  }

  Widget buildTechnicalChip({
    required String key,
    required String label,
    required String description,
    required RxBool value,
    required VoidCallback onTap,
  }) {
    return Obx(() => GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSize.appSize12,
              vertical: AppSize.appSize8,
            ),
            decoration: BoxDecoration(
              color: value.value ? AppColor.primaryColor : AppColor.whiteColor,
              borderRadius: BorderRadius.circular(AppSize.appSize8),
              border: Border.all(
                color: value.value
                    ? AppColor.primaryColor
                    : AppColor.descriptionColor,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppStyle.heading6Medium(
                    color:
                        value.value ? AppColor.whiteColor : AppColor.textColor,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: AppSize.appSize2),
                  Text(
                    description,
                    style: AppStyle.heading7Regular(
                      color: value.value
                          ? AppColor.whiteColor.withOpacity(0.8)
                          : AppColor.descriptionColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ));
  }

  Widget buildBooleanTile({
    required String label,
    required String description,
    required RxBool value,
    required VoidCallback onTap,
  }) {
    return Obx(() => GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSize.appSize16),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: value.value
                    ? AppColor.primaryColor
                    : AppColor.descriptionColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: AppSize.appSize24,
                  height: AppSize.appSize24,
                  decoration: BoxDecoration(
                    color: value.value
                        ? AppColor.primaryColor
                        : AppColor.whiteColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize4),
                    border: Border.all(
                      color: value.value
                          ? AppColor.primaryColor
                          : AppColor.descriptionColor,
                      width: 2,
                    ),
                  ),
                  child: value.value
                      ? Icon(
                          Icons.check,
                          color: AppColor.whiteColor,
                          size: AppSize.appSize16,
                        )
                      : null,
                ),

                const SizedBox(width: AppSize.appSize12),

                // Label and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style:
                            AppStyle.heading6Medium(color: AppColor.textColor),
                      ),
                      const SizedBox(height: AppSize.appSize2),
                      Text(
                        description,
                        style: AppStyle.heading7Regular(
                            color: AppColor.descriptionColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
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
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  hintText: (hasInput.value || focusNode.hasFocus) ? '' : hint,
                  hintStyle: AppStyle.heading4Regular(
                      color: AppColor.descriptionColor),
                  border: InputBorder.none,
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
    required Function(String?) onChanged,
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
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  hintText: value.value.isNotEmpty ? '' : hint,
                  hintStyle: AppStyle.heading4Regular(
                      color: AppColor.descriptionColor),
                  border: InputBorder.none,
                ),
                style: AppStyle.heading4Regular(color: AppColor.textColor),
                dropdownColor: AppColor.whiteColor,
                icon: Icon(Icons.keyboard_arrow_down,
                    color: AppColor.descriptionColor),
                items: options.map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option,
                        style: AppStyle.heading4Regular(
                            color: AppColor.textColor)),
                  );
                }).toList(),
                onChanged: onChanged,
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
        // Use reactive validation from the controller
        final canProceedNow = technicalDetailsController.canProceedValue.value;
        final selectedCount =
            technicalDetailsController.getSelectedTechnicalFeaturesCount();
        final hasConstructionYear = technicalDetailsController
            .anneeConstructionController.text.isNotEmpty;

        return CommonButton(
          onPressed: canProceedNow
              ? () {
                  print('🔄 Proceeding to next step from technical details...');
                  technicalDetailsController.proceedToNextStep();
                }
              : () {
                  // Show why they can't proceed
                  final error = technicalDetailsController.getValidationError();
                  if (error != null) {
                    Get.snackbar(
                      'Erreur de validation',
                      error,
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: AppColor.primaryColor,
                      colorText: AppColor.whiteColor,
                      duration: const Duration(seconds: 3),
                    );
                  }
                },
          backgroundColor: canProceedNow
              ? AppColor.primaryColor
              : AppColor.descriptionColor.withOpacity(0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
              if (selectedCount > 0 || hasConstructionYear) ...[
                SizedBox(height: AppSize.appSize4),
                Text(
                  _buildStatusText(selectedCount, hasConstructionYear),
                  style: AppStyle.heading7Regular(
                    color: canProceedNow
                        ? AppColor.whiteColor.withOpacity(0.8)
                        : AppColor.whiteColor.withOpacity(0.6),
                  ),
                ),
              ] else ...[
                SizedBox(height: AppSize.appSize4),
                Text(
                  'Informations techniques (optionnel)',
                  style: AppStyle.heading7Regular(
                    color: AppColor.whiteColor.withOpacity(0.8),
                  ),
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

// Helper method to build status text
  String _buildStatusText(int selectedCount, bool hasConstructionYear) {
    List<String> parts = [];

    if (selectedCount > 0) {
      parts.add(
          '$selectedCount option${selectedCount > 1 ? 's' : ''} sélectionnée${selectedCount > 1 ? 's' : ''}');
    }

    if (hasConstructionYear) {
      parts.add('Année de construction renseignée');
    }

    return parts.join(' • ');
  }
}
