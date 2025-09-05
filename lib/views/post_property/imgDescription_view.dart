import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/imgDescription.controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/price_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class PhotosDescriptionView extends StatelessWidget {
  PhotosDescriptionView({super.key});

  final PhotosDescriptionController controller =
      Get.put(PhotosDescriptionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildContent(),
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
        'Photos et description',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildContent() {
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
                  'Finalisation de l\'annonce',
                  style: AppStyle.heading4Medium(color: AppColor.textColor),
                ),
                const SizedBox(height: AppSize.appSize8),
                Text(
                  'Ajoutez des photos et rédigez la description de votre bien',
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSize.appSize24),

          // Photos section
          buildPhotosSection(),

          const SizedBox(height: AppSize.appSize32),

          // Description section
          buildDescriptionSection(),
        ],
      ),
    );
  }

  Widget buildPhotosSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionTitle(
            'Photos du bien',
            'Ajoutez jusqu\'à ${controller.maxImages} photos (optionnel)',
          ),
          const SizedBox(height: AppSize.appSize16),

          // Photo selection buttons
          Row(
            children: [
              Expanded(
                child: buildPhotoButton(
                  'Prendre photo',
                  Icons.camera_alt,
                  controller.pickImageFromCamera,
                ),
              ),
              const SizedBox(width: AppSize.appSize12),
              Expanded(
                child: buildPhotoButton(
                  'Galerie',
                  Icons.photo_library,
                  controller.pickImageFromGallery,
                ),
              ),
              const SizedBox(width: AppSize.appSize12),
              Expanded(
                child: buildPhotoButton(
                  'Multiple',
                  Icons.photo_library_outlined,
                  controller.pickMultipleImages,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSize.appSize16),

          // Selected images grid
          Obx(() => controller.selectedImages.isNotEmpty
              ? buildImageGrid()
              : buildEmptyImageState()),
        ],
      ),
    );
  }

  Widget buildPhotoButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSize.appSize12,
          horizontal: AppSize.appSize8,
        ),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSize.appSize8),
          border: Border.all(color: AppColor.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColor.primaryColor, size: AppSize.appSize20),
            const SizedBox(height: AppSize.appSize4),
            Text(
              label,
              style: AppStyle.heading7Regular(color: AppColor.primaryColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${controller.selectedImages.length}/${controller.maxImages} photos',
              style: AppStyle.heading6Medium(color: AppColor.textColor),
            ),
            Text(
              'Maintenez pour réorganiser',
              style: AppStyle.heading7Regular(color: AppColor.descriptionColor),
            ),
          ],
        ),
        const SizedBox(height: AppSize.appSize12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSize.appSize8,
            mainAxisSpacing: AppSize.appSize8,
            childAspectRatio: 1,
          ),
          itemCount: controller.selectedImages.length,
          itemBuilder: (context, index) {
            return buildImageItem(controller.selectedImages[index], index);
          },
        ),
      ],
    );
  }

  Widget buildImageItem(File imageFile, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.appSize8),
        border: Border.all(color: AppColor.descriptionColor.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSize.appSize8),
            child: Image.file(
              imageFile,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: AppSize.appSize4,
            right: AppSize.appSize4,
            child: GestureDetector(
              onTap: () => controller.removeImage(index),
              child: Container(
                padding: const EdgeInsets.all(AppSize.appSize4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: AppSize.appSize16,
                ),
              ),
            ),
          ),
          if (index == 0)
            Positioned(
              bottom: AppSize.appSize4,
              left: AppSize.appSize4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.appSize6,
                  vertical: AppSize.appSize2,
                ),
                decoration: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize4),
                ),
                child: Text(
                  'Principale',
                  style: AppStyle.heading8Regular(color: AppColor.whiteColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildEmptyImageState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSize.appSize32),
      decoration: BoxDecoration(
        color: AppColor.descriptionColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(
          color: AppColor.descriptionColor.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_camera_outlined,
            size: AppSize.appSize48,
            color: AppColor.descriptionColor,
          ),
          const SizedBox(height: AppSize.appSize12),
          Text(
            'Aucune photo sélectionnée',
            style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
          ),
          const SizedBox(height: AppSize.appSize4),
          Text(
            'Ajoutez des photos pour rendre votre annonce plus attractive',
            style: AppStyle.heading7Regular(color: AppColor.descriptionColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSize.appSize16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildSectionTitle(
            'Description de l\'annonce',
            'Titre et description détaillée du bien',
          ),
          const SizedBox(height: AppSize.appSize16),

          // Title field
          buildTextField(
            controller: controller.titreController,
            focusNode: controller.titreFocusNode,
            label: 'Titre de l\'annonce',
            hint: 'Ex: Magnifique appartement avec vue sur mer',
            hasInput: controller.titreHasInput,
            required: true,
            maxLines: 2,
            maxLength: 100,
            characterCount: controller.titreCharacterDisplay,
          ),

          const SizedBox(height: AppSize.appSize16),

          // Description field
          buildTextField(
            controller: controller.annonceController,
            focusNode: controller.annonceFocusNode,
            label: 'Description détaillée',
            hint:
                'Décrivez votre bien en détail: situation, aménagements, atouts...',
            hasInput: controller.annonceHasInput,
            required: true,
            maxLines: 6,
            maxLength: 2000,
            characterCount: controller.annonceCharacterDisplay,
          ),
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

  Widget buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required RxBool hasInput,
    required bool required,
    int maxLines = 1,
    int? maxLength,
    String? characterCount,
  }) {
    return Obx(() => Container(
          padding: EdgeInsets.only(
            top: hasInput.value || focusNode.hasFocus
                ? AppSize.appSize6
                : AppSize.appSize14,
            bottom: hasInput.value || focusNode.hasFocus
                ? AppSize.appSize8
                : AppSize.appSize14,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    ),
                    if (characterCount != null)
                      Text(
                        characterCount,
                        style: AppStyle.heading7Regular(
                            color: AppColor.descriptionColor),
                      ),
                  ],
                ).paddingOnly(bottom: AppSize.appSize2),
              TextFormField(
                controller: controller,
                focusNode: focusNode,
                cursorColor: AppColor.primaryColor,
                maxLines: maxLines,
                maxLength: maxLength,
                style: AppStyle.heading4Regular(color: AppColor.textColor),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  hintText: (hasInput.value || focusNode.hasFocus) ? '' : hint,
                  hintStyle: AppStyle.heading4Regular(
                      color: AppColor.descriptionColor),
                  border: InputBorder.none,
                  counterText: '', // Hide default counter
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
      child: CommonButton(
        onPressed: () async {
          final error = controller.getValidationError();
          if (error == null) {
            // All data is valid, now create the complete BienImmo
            await _createBienImmo();
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
          'Publier l\'annonce',
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

  Future<void> _createBienImmo() async {
    try {
      // Get all the data from previous steps (you'll need to pass this data somehow)
      // For now, I'll show the structure you need to send to your API

      final bienImmoData = {
        // From location step (you'll need to implement this)
        'localisation': {
          'numero': '123',
          'rue': 'Rue de la Paix',
          'codePostal': '75001',
          'ville': 'Paris',
          'departement': 'Paris',
        },

        // From property details step (you'll need to implement this)
        'typeBien': 'appartement',
        'nombrePiecesTotal': 4,

        // From surfaces step (you'll need to implement this)
        'surfaces': {
          'habitable': 85.5,
          'terrain': null,
        },

        // From pricing step - get from PricingController
        'prix': Get.find<PricingController>().getPricingData(),

        // From current step
        'description': controller.getDescriptionData(),
        'listeImages': controller.getImagePaths(),

        // Required fields
        'datePublication': DateTime.now().toIso8601String(),
        'statut': 'brouillon',
        'utilisateurId': 'user-id-here', // You'll need to get this from auth
      };

      print('Creating BienImmo with data: $bienImmoData');

      // TODO: Send to your LoopBack API
      // final response = await ApiService.post('/bien-immos', bienImmoData);

      // For now, show success message
      Get.snackbar(
        'Succès',
        'Votre annonce a été créée avec succès!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: AppColor.whiteColor,
        duration: const Duration(seconds: 3),
      );

      // Navigate to property list or detail page
      Get.offAllNamed('/properties'); // Update with your actual route
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de créer l\'annonce: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: AppColor.whiteColor,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
