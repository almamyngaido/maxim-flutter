import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/caracteristique_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';

class PropertyFeaturesView extends StatelessWidget {
  PropertyFeaturesView({super.key});

  final PropertyFeaturesController propertyFeaturesController =
      Get.put(PropertyFeaturesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildPropertyFeaturesFields(),
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
        'Caractéristiques du bien',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
      actions: [
        // Reset button
        Obx(() {
          final selectedCount =
              propertyFeaturesController.getSelectedFeaturesCount();
          return selectedCount > 0
              ? Padding(
                  padding: const EdgeInsets.only(right: AppSize.appSize16),
                  child: GestureDetector(
                    onTap: () => propertyFeaturesController.resetAllFeatures(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize8,
                        vertical: AppSize.appSize4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.descriptionColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSize.appSize6),
                      ),
                      child: Text(
                        'Tout désélectionner',
                        style: AppStyle.heading6Regular(
                            color: AppColor.descriptionColor),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget buildPropertyFeaturesFields() {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: AppSize.appSize20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with selection count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Équipements et caractéristiques',
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ),
                const SizedBox(height: AppSize.appSize8),
                Obx(() {
                  final selectedCount =
                      propertyFeaturesController.getSelectedFeaturesCount();
                  return Text(
                    selectedCount == 0
                        ? 'Sélectionnez les équipements disponibles (optionnel)'
                        : '$selectedCount équipement${selectedCount > 1 ? 's' : ''} sélectionné${selectedCount > 1 ? 's' : ''}',
                    style: AppStyle.heading6Regular(
                        color: AppColor.descriptionColor),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSize.appSize20),

          // Features grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSize.appSize12,
                mainAxisSpacing: AppSize.appSize12,
                childAspectRatio:
                    1.0, // Changed from 1.2 to 1.0 for more height
              ),
              itemCount: propertyFeaturesController.features.length,
              itemBuilder: (context, index) {
                final feature = propertyFeaturesController.features[index];
                return buildFeatureTile(feature);
              },
            ),
          ),

          const SizedBox(height: AppSize.appSize24),

          // Selected features summary (if any selected)
          Obx(() {
            final selectedFeatures =
                propertyFeaturesController.getSelectedFeatures();
            return selectedFeatures.isNotEmpty
                ? Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: AppSize.appSize16),
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
                              Icons.check_circle_outline,
                              color: AppColor.primaryColor,
                              size: AppSize.appSize20,
                            ),
                            const SizedBox(width: AppSize.appSize8),
                            Text(
                              'Équipements sélectionnés',
                              style: AppStyle.heading6Medium(
                                  color: AppColor.primaryColor),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSize.appSize8),
                        Wrap(
                          spacing: AppSize.appSize6,
                          runSpacing: AppSize.appSize4,
                          children: selectedFeatures.map((feature) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSize.appSize8,
                                vertical: AppSize.appSize4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColor.whiteColor,
                                borderRadius:
                                    BorderRadius.circular(AppSize.appSize12),
                                border: Border.all(
                                  color: AppColor.primaryColor.withOpacity(0.5),
                                ),
                              ),
                              child: Text(
                                feature,
                                style: AppStyle.heading6Regular(
                                    color: AppColor.textColor),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget buildFeatureTile(Map<String, dynamic> feature) {
    final String key = feature['key'];
    final String label = feature['label'];
    final String description = feature['description'];
    final String icon = feature['icon'];

    return Obx(() {
      final isSelected = propertyFeaturesController.getFeatureValue(key).value;

      return GestureDetector(
        onTap: () => propertyFeaturesController.toggleFeature(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSize.appSize12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColor.primaryColor.withOpacity(0.1)
                : AppColor.whiteColor,
            borderRadius: BorderRadius.circular(AppSize.appSize12),
            border: Border.all(
              color: isSelected
                  ? AppColor.primaryColor
                  : AppColor.descriptionColor.withOpacity(0.3),
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Checkbox icon
              Container(
                width: AppSize.appSize24,
                height: AppSize.appSize24,
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColor.primaryColor : AppColor.whiteColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize4),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.primaryColor
                        : AppColor.descriptionColor,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: AppColor.whiteColor,
                        size: AppSize.appSize16,
                      )
                    : null,
              ),

              const SizedBox(height: AppSize.appSize8),

              // Feature emoji/icon
              Text(
                icon,
                style: const TextStyle(fontSize: 20),
              ),

              const SizedBox(height: AppSize.appSize6),

              // Feature label
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppStyle.heading6Medium(
                  color:
                      isSelected ? AppColor.primaryColor : AppColor.textColor,
                ),
              ),

              const SizedBox(height: AppSize.appSize4),

              // Feature description
              Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppStyle.heading7Regular(
                  color: AppColor.descriptionColor,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CommonButton(
        onPressed: () {
          // Since all features are optional, no validation needed
          final featuresData = propertyFeaturesController.getFeaturesData();
          print('Features Data: $featuresData'); // Debug log

          // Navigate to next page (Technical Details page)
          // Update this route to your next page in the flow
          Get.toNamed(AppRoutes.techniqueDetailsView);
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
