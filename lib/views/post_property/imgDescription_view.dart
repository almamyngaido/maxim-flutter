import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // For XFile
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/bottom_bar_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/imgDescription.controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/post_bien_immo_service.dart';

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
  Widget buildImageItem(XFile imageFile, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSize.appSize8),
        border: Border.all(color: AppColor.descriptionColor.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSize.appSize8),
            child: kIsWeb
                ? // Pour Flutter Web - utiliser Image.network avec l'URL blob
                Image.network(
                    imageFile.path, // Le path est déjà une URL blob sur web
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Erreur chargement image Web: $error');
                      return Container(
                        color: AppColor.descriptionColor.withOpacity(0.3),
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColor.descriptionColor,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColor.descriptionColor.withOpacity(0.1),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColor.primaryColor,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  )
                : // Pour les plateformes mobiles - utiliser Image.file
                Image.file(
                    File(imageFile.path),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Erreur chargement image Mobile: $error');
                      return Container(
                        color: AppColor.descriptionColor.withOpacity(0.3),
                        child: Icon(
                          Icons.image_not_supported,
                          color: AppColor.descriptionColor,
                        ),
                      );
                    },
                  ),
          ),

          // Bouton de suppression
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

          // Badge "Principale" pour la première image
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
      // Récupérer le gestionnaire de données central
      final PropertyDataManager? dataManager = Get.find<PropertyDataManager>();
      if (dataManager == null) {
        throw Exception('PropertyDataManager non trouvé');
      }

      // Sauvegarder les données de description et images dans le gestionnaire
      final descriptionData = controller.getDescriptionData();
      final imageFiles = controller.getSelectedImageFiles();

      // Vérifier que les méthodes retournent des valeurs valides
      if (descriptionData.isEmpty) {
        throw Exception('Données de description manquantes');
      }

      print('📝 Description data: $descriptionData');
      print('📷 Image files: ${imageFiles.length}');

      // Mettre à jour le gestionnaire avec les dernières données
      dataManager.updateDescriptionAndImages(descriptionData, imageFiles);

      // Afficher un indicateur de chargement
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColor.whiteColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColor.primaryColor),
                  const SizedBox(height: 16),
                  Text(
                    'Publication en cours...',
                    style: AppStyle.heading6Medium(color: AppColor.textColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Veuillez patienter',
                    style: AppStyle.heading7Regular(
                        color: AppColor.descriptionColor),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Utiliser le système existant pour soumettre la propriété
      print('');
      print('🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥');
      print('🔥 ABOUT TO CALL submitProperty()');
      print('🔥 Image files to upload: ${imageFiles.length}');
      for (int i = 0; i < imageFiles.length; i++) {
        print('   🔥 Image ${i + 1}: ${imageFiles[i].path}');
      }
      print('🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥');
      print('');

      final success = await dataManager.submitProperty();

      // Fermer le dialog de chargement - avec vérification
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      // Dans imgDescription_view.dart, modifiez la partie navigation de _createBienImmo() :

      if (success) {
        print('✅ Property submitted successfully!');

        // CLEAR ALL FORM DATA for next property
        print('🧹 Clearing form data for next property...');
        dataManager.clearAllData();

        // Clear local controller data
        controller.titreController.clear();
        controller.annonceController.clear();
        controller.selectedImages.clear();
        print('✅ Form cleared successfully');

        // Attendre un peu pour que les snackbars se ferment
        await Future.delayed(const Duration(milliseconds: 500));

        // NOUVELLE REDIRECTION : Naviguer vers l'onglet ActivityView (index 1)
        try {
          // Méthode 1: Naviguer vers BottomBarView avec l'index 1 (ActivityView)
          Get.offAllNamed(AppRoutes.bottomBarView,
              arguments: {'initialIndex': 1});

          // Alternative si la route ci-dessus ne fonctionne pas:
          // Get.offAll(() => BottomBarView(initialIndex: 1));
        } catch (navError) {
          print('⚠️ Navigation error: $navError');

          // Fallback: Si la navigation échoue, essayer d'autres options
          try {
            // Option 2: Aller à la page d'accueil et naviguer vers l'onglet 1
            Get.offAllNamed('/');

            // Puis naviguer vers l'onglet ActivityView
            Future.delayed(const Duration(milliseconds: 200), () {
              final bottomBarController = Get.find<BottomBarController>();
              bottomBarController.updateIndex(1);
            });
          } catch (fallbackError) {
            print('⚠️ Fallback navigation error: $fallbackError');
            // Dernier recours: juste fermer la page actuelle
            Get.back();
          }
        }
      } else {
        print('❌ Property submission failed');
      }
    } catch (e) {
      print('💥 Exception in _createBienImmo: $e');

      // Fermer le dialog de chargement si ouvert
      if (Get.isDialogOpen == true) {
        try {
          Get.back();
        } catch (closeError) {
          print('⚠️ Could not close dialog: $closeError');
        }
      }

      // Afficher l'erreur à l'utilisateur
      try {
        Get.snackbar(
          'Erreur',
          'Une erreur s\'est produite: ${e.toString()}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: AppColor.whiteColor,
          duration: const Duration(seconds: 5),
        );
      } catch (snackError) {
        print('⚠️ Could not show error snackbar: $snackError');
      }
    }
  }
}
