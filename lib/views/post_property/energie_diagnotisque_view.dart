import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/energie_diagnostique_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class EnergyDiagnosticsView extends StatelessWidget {
  EnergyDiagnosticsView({super.key});

  final EnergyDiagnosticsController energyDiagnosticsController =
      Get.put(EnergyDiagnosticsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildEnergyDiagnosticsFields(context),
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
        'Diagnostics énergétiques',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildEnergyDiagnosticsFields(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Performance énergétique du bien',
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ),
                const SizedBox(height: AppSize.appSize8),
                Text(
                  'Informations optionnelles sur l\'efficacité énergétique',
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSize.appSize24),

          // DPE Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DPE - Diagnostic de Performance Énergétique',
                  style: AppStyle.heading5Medium(color: AppColor.textColor),
                ),
                const SizedBox(height: AppSize.appSize4),
                Text(
                  'Consommation énergétique du logement',
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                ),
                const SizedBox(height: AppSize.appSize16),
                buildEnergyRatingDropdown(
                  label: 'Classe DPE',
                  hint: 'Sélectionnez la classe énergétique',
                  selectedValue: energyDiagnosticsController.selectedDpe,
                  onChanged: energyDiagnosticsController.updateDpe,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSize.appSize32),

          // GES Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GES - Émissions de Gaz à Effet de Serre',
                  style: AppStyle.heading5Medium(color: AppColor.textColor),
                ),
                const SizedBox(height: AppSize.appSize4),
                Text(
                  'Impact climatique du logement',
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                ),
                const SizedBox(height: AppSize.appSize16),
                buildEnergyRatingDropdown(
                  label: 'Classe GES',
                  hint: 'Sélectionnez la classe d\'émission',
                  selectedValue: energyDiagnosticsController.selectedGes,
                  onChanged: energyDiagnosticsController.updateGes,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSize.appSize32),

          // Date Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date du diagnostic',
                  style: AppStyle.heading5Medium(color: AppColor.textColor),
                ),
                const SizedBox(height: AppSize.appSize4),
                Text(
                  'Date de réalisation des diagnostics (optionnel)',
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                ),
                const SizedBox(height: AppSize.appSize16),
                buildDatePicker(context),
              ],
            ),
          ),

          const SizedBox(height: AppSize.appSize32),

          // Rating Legend
          buildRatingLegend(),

          const SizedBox(height: AppSize.appSize24),

          // Info section
          buildInfoSection(),
        ],
      ),
    );
  }

  Widget buildEnergyRatingDropdown({
    required String label,
    required String hint,
    required RxString selectedValue,
    required Function(String?) onChanged,
  }) {
    return Obx(() => Container(
          padding: EdgeInsets.only(
            top: selectedValue.value.isNotEmpty
                ? AppSize.appSize6
                : AppSize.appSize14,
            bottom: selectedValue.value.isNotEmpty
                ? AppSize.appSize8
                : AppSize.appSize14,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSize.appSize12),
            border: Border.all(
              color: selectedValue.value.isNotEmpty
                  ? energyDiagnosticsController
                      .getRatingColor(selectedValue.value)
                  : AppColor.descriptionColor,
              width: selectedValue.value.isNotEmpty ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectedValue.value.isNotEmpty)
                Text(
                  label,
                  style: AppStyle.heading6Regular(
                    color: energyDiagnosticsController
                        .getRatingColor(selectedValue.value),
                  ),
                ).paddingOnly(bottom: AppSize.appSize2),
              DropdownButtonFormField<String>(
                value: selectedValue.value.isEmpty ? null : selectedValue.value,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  hintText: selectedValue.value.isNotEmpty ? '' : hint,
                  hintStyle: AppStyle.heading4Regular(
                      color: AppColor.descriptionColor),
                  border: InputBorder.none,
                ),
                style: AppStyle.heading4Regular(color: AppColor.textColor),
                dropdownColor: AppColor.whiteColor,
                icon: Icon(Icons.keyboard_arrow_down,
                    color: AppColor.descriptionColor),
                items: energyDiagnosticsController.energyRatings.map((rating) {
                  return DropdownMenuItem<String>(
                    value: rating,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Rating badge
                        Container(
                          width: 20,
                          height: 14,
                          decoration: BoxDecoration(
                            color: energyDiagnosticsController
                                .getRatingColor(rating),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Center(
                            child: Text(
                              rating,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Simple text
                        Text(
                          'Classe $rating',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
              // Show selected rating info
              if (selectedValue.value.isNotEmpty) ...[
                const SizedBox(height: AppSize.appSize6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSize.appSize8),
                  decoration: BoxDecoration(
                    color: energyDiagnosticsController
                        .getRatingColor(selectedValue.value)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSize.appSize6),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: AppSize.appSize18,
                        height: AppSize.appSize18,
                        decoration: BoxDecoration(
                          color: energyDiagnosticsController
                              .getRatingColor(selectedValue.value),
                          borderRadius: BorderRadius.circular(AppSize.appSize4),
                        ),
                        child: Center(
                          child: Text(
                            selectedValue.value,
                            style: AppStyle.heading7Bold(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSize.appSize8),
                      Expanded(
                        child: Text(
                          energyDiagnosticsController
                              .getRatingDescription(selectedValue.value),
                          style: AppStyle.heading7Regular(
                              color: AppColor.textColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ));
  }

  Widget buildDatePicker(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: () => energyDiagnosticsController.selectDate(context),
          child: Container(
            padding: EdgeInsets.only(
              top: energyDiagnosticsController.dateHasInput.value
                  ? AppSize.appSize6
                  : AppSize.appSize14,
              bottom: energyDiagnosticsController.dateHasInput.value
                  ? AppSize.appSize8
                  : AppSize.appSize14,
              left: AppSize.appSize16,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: energyDiagnosticsController.dateHasInput.value
                    ? AppColor.primaryColor
                    : AppColor.descriptionColor,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (energyDiagnosticsController.dateHasInput.value)
                        Text(
                          'Date du diagnostic',
                          style: AppStyle.heading6Regular(
                              color: AppColor.primaryColor),
                        ).paddingOnly(bottom: AppSize.appSize2),
                      Text(
                        energyDiagnosticsController.dateController.text.isEmpty
                            ? 'Sélectionner la date (optionnel)'
                            : energyDiagnosticsController.dateController.text,
                        style: AppStyle.heading4Regular(
                          color: energyDiagnosticsController
                                  .dateController.text.isEmpty
                              ? AppColor.descriptionColor
                              : AppColor.textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (energyDiagnosticsController.selectedDate.value != null)
                      GestureDetector(
                        onTap: () => energyDiagnosticsController.clearDate(),
                        child: Container(
                          padding: const EdgeInsets.all(AppSize.appSize4),
                          child: Icon(
                            Icons.clear,
                            color: AppColor.descriptionColor,
                            size: AppSize.appSize16,
                          ),
                        ),
                      ),
                    const SizedBox(width: AppSize.appSize8),
                    Icon(
                      Icons.calendar_today,
                      color: AppColor.descriptionColor,
                      size: AppSize.appSize20,
                    ),
                    const SizedBox(width: AppSize.appSize16),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget buildRatingLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      padding: const EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(color: AppColor.descriptionColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Échelle des classes énergétiques',
            style: AppStyle.heading6Medium(color: AppColor.textColor),
          ),
          const SizedBox(height: AppSize.appSize12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: energyDiagnosticsController.energyRatings.map((rating) {
                return Container(
                  width: AppSize.appSize40,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSize.appSize6),
                  decoration: BoxDecoration(
                    color: energyDiagnosticsController.getRatingColor(rating),
                    borderRadius: BorderRadius.circular(AppSize.appSize4),
                  ),
                  child: Center(
                    child: Text(
                      rating,
                      style: AppStyle.heading6Bold(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSize.appSize8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Très performant',
                style:
                    AppStyle.heading7Regular(color: AppColor.descriptionColor),
              ),
              Text(
                'Peu performant',
                style:
                    AppStyle.heading7Regular(color: AppColor.descriptionColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      padding: const EdgeInsets.all(AppSize.appSize16),
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
                'À propos des diagnostics',
                style: AppStyle.heading6Medium(color: AppColor.primaryColor),
              ),
            ],
          ),
          const SizedBox(height: AppSize.appSize12),
          Text(
            '• DPE : Indique la consommation énergétique annuelle du logement',
            style: AppStyle.heading7Regular(color: AppColor.textColor),
          ),
          const SizedBox(height: AppSize.appSize4),
          Text(
            '• GES : Mesure l\'impact environnemental en émissions de CO₂',
            style: AppStyle.heading7Regular(color: AppColor.textColor),
          ),
          const SizedBox(height: AppSize.appSize4),
          Text(
            '• Ces diagnostics sont valables 10 ans depuis leur réalisation',
            style: AppStyle.heading7Regular(color: AppColor.textColor),
          ),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CommonButton(
        onPressed: () {
          final error = energyDiagnosticsController.getValidationError();
          if (error == null) {
            // Data is valid, navigate to next page
            final diagnosticsData =
                energyDiagnosticsController.getEnergyDiagnosticsData();
            print('Energy Diagnostics Data: $diagnosticsData'); // Debug log

            Get.toNamed(AppRoutes.priceView);
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
        },
        backgroundColor: AppColor.primaryColor,
        child: Text(
          'Continuer',
          style: AppStyle.heading5Medium(color: AppColor.whiteColor),
        ),
      ).paddingOnly(
        left: AppSize.appSize16,
        right: AppSize.appSize16,
        bottom: AppSize.appSize26,
        top: AppSize.appSize10,
      ),
    );
  }
}
