import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/price_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';

class PricingView extends StatelessWidget {
  PricingView({super.key});

  final PricingController pricingController = Get.put(PricingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildPricingFields(),
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
        'Prix du bien',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildPricingFields() {
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
                  'Informations financières',
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ),
                const SizedBox(height: AppSize.appSize8),
                Text(
                  'Prix et conditions de vente du bien immobilier',
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSize.appSize24),

          // Prix HAI (required)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionTitle(
                    'Prix principal', 'Tarif affiché aux acquéreurs'),
                const SizedBox(height: AppSize.appSize16),
                buildCurrencyField(
                  controller: pricingController.haiController,
                  focusNode: pricingController.haiFocusNode,
                  label: 'Prix HAI (Honoraires Acquéreur Inclus)',
                  hint: 'Ex: 350000',
                  hasInput: pricingController.haiHasInput,
                  required: true,
                  suffix: '€',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSize.appSize32),

          // Honoraires section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionTitle('Honoraires d\'agence',
                    'Commission de l\'intermédiaire (optionnel)'),
                const SizedBox(height: AppSize.appSize16),

                // Honoraires en pourcentage
                buildCurrencyField(
                  controller: pricingController.honorairePourcentageController,
                  focusNode: pricingController.honorairePourcentageFocusNode,
                  label: 'Taux d\'honoraires',
                  hint: 'Ex: 5,00',
                  hasInput: pricingController.honorairePourcentageHasInput,
                  required: false,
                  suffix: '%',
                ),

                const SizedBox(height: AppSize.appSize16),

                // Honoraires en euros
                buildCurrencyField(
                  controller: pricingController.honoraireEurosController,
                  focusNode: pricingController.honoraireEurosFocusNode,
                  label: 'Montant des honoraires',
                  hint: 'Ex: 17500',
                  hasInput: pricingController.honoraireEurosHasInput,
                  required: false,
                  suffix: '€',
                ),

                // Info about automatic calculation
                Container(
                  margin: const EdgeInsets.only(top: AppSize.appSize12),
                  padding: const EdgeInsets.all(AppSize.appSize12),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSize.appSize8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColor.primaryColor,
                        size: AppSize.appSize16,
                      ),
                      const SizedBox(width: AppSize.appSize8),
                      Expanded(
                        child: Text(
                          'Les champs se calculent automatiquement entre eux',
                          style: AppStyle.heading7Regular(
                              color: AppColor.textColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSize.appSize32),

          // Net vendeur et charges
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionTitle(
                    'Montants nets', 'Répartition financière (optionnel)'),
                const SizedBox(height: AppSize.appSize16),

                // Net vendeur
                buildCurrencyField(
                  controller: pricingController.netVendeurController,
                  focusNode: pricingController.netVendeurFocusNode,
                  label: 'Net vendeur',
                  hint: 'Montant net perçu par le vendeur',
                  hasInput: pricingController.netVendeurHasInput,
                  required: false,
                  suffix: '€',
                ),

                const SizedBox(height: AppSize.appSize16),

                // Charges acheteur/vendeur
                buildDropdownField(
                  label: 'Répartition des charges',
                  hint: 'Qui paie les frais annexes ?',
                  value: pricingController.selectedChargesType,
                  options: pricingController.chargesTypeOptions,
                  onChanged: pricingController.updateChargesType,
                  required: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSize.appSize32),

          // Charges de copropriété
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSectionTitle(
                    'Charges de copropriété', 'Coûts annuels (optionnel)'),
                const SizedBox(height: AppSize.appSize16),
                buildCurrencyField(
                  controller:
                      pricingController.chargesAnnuellesCoproprieteController,
                  focusNode:
                      pricingController.chargesAnnuellesCoproprieteeFocusNode,
                  label: 'Charges annuelles',
                  hint: 'Ex: 1200 (par an)',
                  hasInput:
                      pricingController.chargesAnnuellesCoproprieteHasInput,
                  required: false,
                  suffix: '€/an',
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSize.appSize24),

          // Pricing summary
          buildPricingSummary(),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title, String description) {
    return Column(
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
      ],
    );
  }

  Widget buildCurrencyField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required RxBool hasInput,
    required bool required,
    String suffix = '',
  }) {
    return Obx(() => Container(
          padding: EdgeInsets.only(
            top: hasInput.value ? AppSize.appSize6 : AppSize.appSize14,
            bottom: hasInput.value ? AppSize.appSize8 : AppSize.appSize14,
            left: AppSize.appSize16,
            right: AppSize.appSize16,
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      cursorColor: AppColor.primaryColor,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      style:
                          AppStyle.heading4Regular(color: AppColor.textColor),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        hintText:
                            (hasInput.value || focusNode.hasFocus) ? '' : hint,
                        hintStyle: AppStyle.heading4Regular(
                            color: AppColor.descriptionColor),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (suffix.isNotEmpty) ...[
                    const SizedBox(width: AppSize.appSize8),
                    Text(
                      suffix,
                      style:
                          AppStyle.heading5Medium(color: AppColor.primaryColor),
                    ),
                  ],
                ],
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

  Widget buildPricingSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      padding: const EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
      ),
      child: Obx(() {
        // Watch the reactive boolean variables to trigger rebuilds
        final hasHaiInput = pricingController.haiHasInput.value;
        final hasHonoraireInput =
            pricingController.honoraireEurosHasInput.value;
        final hasNetVendeurInput = pricingController.netVendeurHasInput.value;

        // Get text values after ensuring reactivity
        final haiText = pricingController.haiController.text;
        final honorairesText = pricingController.honoraireEurosController.text;
        final netVendeurText = pricingController.netVendeurController.text;

        final hai = pricingController.parseCurrency(haiText);
        final honoraires = pricingController.parseCurrency(honorairesText);
        final netVendeur = pricingController.parseCurrency(netVendeurText);

        if (hai == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif financier',
              style: AppStyle.heading5Medium(color: AppColor.textColor),
            ),
            const SizedBox(height: AppSize.appSize12),

            // Prix HAI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Prix HAI',
                  style: AppStyle.heading6Regular(color: AppColor.textColor),
                ),
                Text(
                  '${pricingController.formatCurrency(hai)} €',
                  style: AppStyle.heading6Medium(color: AppColor.primaryColor),
                ),
              ],
            ),

            // Honoraires if provided
            if (honoraires != null) ...[
              const SizedBox(height: AppSize.appSize8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Honoraires',
                    style: AppStyle.heading6Regular(color: AppColor.textColor),
                  ),
                  Text(
                    '- ${pricingController.formatCurrency(honoraires)} €',
                    style: AppStyle.heading6Regular(
                        color: AppColor.descriptionColor),
                  ),
                ],
              ),
            ],

            // Net vendeur if provided
            if (netVendeur != null) ...[
              const Divider(height: AppSize.appSize16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Net vendeur',
                    style: AppStyle.heading6Medium(color: AppColor.textColor),
                  ),
                  Text(
                    '${pricingController.formatCurrency(netVendeur)} €',
                    style: AppStyle.heading6Medium(color: Colors.green),
                  ),
                ],
              ),
            ],
          ],
        );
      }),
    );
  }

  Widget buildButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CommonButton(
        onPressed: () {
          final error = pricingController.getValidationError();
          if (error == null) {
            // AJOUT: Sauvegarde explicite des données de prix
            final pricingData = pricingController.getPricingData();
            final dataManager = Get.find<PropertyDataManager>();
            dataManager.updatePricing(pricingData);

            print('💰 Prix sauvegardés avant navigation: $pricingData');

            // Navigate to next page (Description & Images)
            Get.toNamed(AppRoutes.imgdesc);
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
