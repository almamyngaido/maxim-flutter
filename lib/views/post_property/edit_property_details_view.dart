import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_textfield.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/edit_property_details_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class EditPropertyDetailsView extends StatelessWidget {
  EditPropertyDetailsView({super.key});

  final EditPropertyDetailsController controller =
      Get.put(EditPropertyDetailsController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show loading state while property data is being loaded
      if (controller.isLoadingProperty.value) {
        return Scaffold(
          backgroundColor: AppColor.whiteColor,
          appBar: buildAppBar(),
          body: Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          ),
        );
      }

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
        'Modifier le bien',
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
                children: List.generate(controller.propertyList.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      controller.updateProperty(index);
                    },
                    child: Obx(() => Container(
                          height: AppSize.appSize25,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSize.appSize14),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: controller.selectProperty.value == index
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
                              controller.propertyList[index],
                              style: AppStyle.heading5Medium(
                                color: controller.selectProperty.value == index
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
    return Obx(() {
      // Display content based on selected tab
      return SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(AppSize.appSize16),
        child: IndexedStack(
          index: controller.selectProperty.value,
          children: [
            buildBasicDetailsTab(),
            buildPropertyDetailsTab(),
            buildPricingTab(),
            buildAmenitiesTab(),
          ],
        ),
      );
    });
  }

  Widget buildBasicDetailsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations de base',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        SizedBox(height: AppSize.appSize16),

        // Title
        TextField(
          controller: controller.titleController,
          decoration: InputDecoration(
            labelText: 'Titre de l\'annonce',
            hintText: 'Ex: Appartement 3 pièces avec vue',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(color: AppColor.primaryColor),
            ),
          ),
        ),
        SizedBox(height: AppSize.appSize16),

        // Description
        TextField(
          controller: controller.descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: 'Description',
            hintText: 'Décrivez votre bien immobilier...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(color: AppColor.primaryColor),
            ),
          ),
        ),
        SizedBox(height: AppSize.appSize24),

        // Location Section
        Text(
          'Localisation',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        SizedBox(height: AppSize.appSize16),

        TextField(
          controller: controller.rueController,
          decoration: InputDecoration(
            labelText: 'Adresse',
            hintText: 'Numéro et nom de rue',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(color: AppColor.primaryColor),
            ),
          ),
        ),
        SizedBox(height: AppSize.appSize16),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller.villeController,
                decoration: InputDecoration(
                  labelText: 'Ville',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    borderSide: BorderSide(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSize.appSize16),
            Expanded(
              child: TextField(
                controller: controller.codePostalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Code Postal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    borderSide: BorderSide(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.appSize16),

        TextField(
          controller: controller.paysController,
          decoration: InputDecoration(
            labelText: 'Pays',
            hintText: 'France',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(color: AppColor.primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildPropertyDetailsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Caractéristiques',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        SizedBox(height: AppSize.appSize16),

        // Number of rooms
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.nombrePiecesTotalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Nombre de pièces',
                  hintText: '3',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    borderSide: BorderSide(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSize.appSize16),
            Expanded(
              child: TextField(
                controller: controller.nombreChambresController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Chambres',
                  hintText: '2',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    borderSide: BorderSide(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSize.appSize16),

        // Bathrooms
        TextField(
          controller: controller.nombreSallesBainController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Salles de bain',
            hintText: '1',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(color: AppColor.primaryColor),
            ),
          ),
        ),
        SizedBox(height: AppSize.appSize24),

        Text(
          'Surfaces',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        SizedBox(height: AppSize.appSize16),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.surfaceHabitableController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Surface habitable (m²)',
                  hintText: '75',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    borderSide: BorderSide(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSize.appSize16),
            Expanded(
              child: TextField(
                controller: controller.surfaceTerrainController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Surface terrain (m²)',
                  hintText: '100',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                    borderSide: BorderSide(color: AppColor.primaryColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPricingTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informations financières',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        SizedBox(height: AppSize.appSize16),

        // Price HAI (Honoraires Acquéreur Inclus)
        TextField(
          controller: controller.priceHaiController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Prix HAI (€)',
            hintText: '250000',
            helperText: 'Honoraires acquéreur inclus',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(color: AppColor.primaryColor),
            ),
          ),
        ),
        SizedBox(height: AppSize.appSize16),

        // Price Net Vendor
        TextField(
          controller: controller.priceNetController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Prix net vendeur (€)',
            hintText: '240000',
            helperText: 'Prix sans les honoraires',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(color: AppColor.primaryColor),
            ),
          ),
        ),
        SizedBox(height: AppSize.appSize16),

        // Monthly Charges
        TextField(
          controller: controller.chargeMensuelleController,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Charges mensuelles (€)',
            hintText: '150',
            helperText: 'Copropriété, entretien, etc.',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              borderSide: BorderSide(color: AppColor.primaryColor),
            ),
          ),
        ),

        SizedBox(height: AppSize.appSize24),

        // Price summary card
        Container(
          padding: EdgeInsets.all(AppSize.appSize16),
          decoration: BoxDecoration(
            color: AppColor.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSize.appSize12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Résumé',
                style: AppStyle.heading5SemiBold(color: AppColor.textColor),
              ),
              SizedBox(height: AppSize.appSize8),
              if (controller.priceHaiController.text.isNotEmpty)
                Text(
                  'Prix affiché: ${controller.priceHaiController.text} €',
                  style: AppStyle.heading6Regular(color: AppColor.textColor),
                ),
              if (controller.chargeMensuelleController.text.isNotEmpty)
                Text(
                  'Charges: ${controller.chargeMensuelleController.text} €/mois',
                  style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAmenitiesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Équipements & Services',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        SizedBox(height: AppSize.appSize16),

        Container(
          padding: EdgeInsets.all(AppSize.appSize16),
          decoration: BoxDecoration(
            color: AppColor.backgroundColor,
            borderRadius: BorderRadius.circular(AppSize.appSize12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.construction,
                size: AppSize.appSize48,
                color: AppColor.descriptionColor,
              ),
              SizedBox(height: AppSize.appSize16),
              Text(
                'Section en développement',
                style: AppStyle.heading5Medium(color: AppColor.textColor),
              ),
              SizedBox(height: AppSize.appSize8),
              Text(
                'Les équipements et services pourront être modifiés prochainement',
                textAlign: TextAlign.center,
                style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildButton() {
    return Obx(() => CommonButton(
          onPressed: controller.isSavingProperty.value
              ? null
              : () {
                  controller.savePropertyChanges();
                },
          backgroundColor: AppColor.primaryColor,
          child: controller.isSavingProperty.value
              ? SizedBox(
                  width: AppSize.appSize20,
                  height: AppSize.appSize20,
                  child: CircularProgressIndicator(
                    color: AppColor.whiteColor,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'Enregistrer les modifications',
                  style: AppStyle.heading5Medium(color: AppColor.whiteColor),
                ),
        )).paddingOnly(
      left: AppSize.appSize16,
      right: AppSize.appSize16,
      bottom: AppSize.appSize26,
      top: AppSize.appSize10,
    );
  }
}
