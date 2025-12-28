import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/common_button.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/bien_immo_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';

void showContactOwnerBottomSheet(BuildContext context, BienImmo property) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return ContactOwnerBottomSheetContent(property: property);
    },
  );
}

class ContactOwnerBottomSheetContent extends StatelessWidget {
  final BienImmo property;

  const ContactOwnerBottomSheetContent({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    // Debug logging
    print('🔍 Contact Owner Bottom Sheet - Property ID: ${property.id}');
    print('🔍 Has utilisateur: ${property.utilisateur != null}');
    if (property.utilisateur != null) {
      print('👤 Owner: ${property.utilisateur!.prenom} ${property.utilisateur!.nom}');
      print('📧 Email: ${property.utilisateur!.email}');
      print('📱 Phone: ${property.utilisateur!.phoneNumber}');
    } else {
      print('⚠️ No utilisateur data available for property ${property.id}');
    }

    // Extract owner information - will be null if not included
    final ownerName = property.utilisateur != null
        ? '${property.utilisateur!.prenom} ${property.utilisateur!.nom}'.trim()
        : 'Propriétaire';
    final ownerEmail = property.utilisateur?.email ?? '';
    final ownerPhone = property.utilisateur?.phoneNumber ?? '';
    final firstLetter = ownerName.isNotEmpty ? ownerName[0].toUpperCase() : 'P';

    return Container(
      decoration: const BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSize.appSize24),
          topRight: Radius.circular(AppSize.appSize24),
        ),
      ),
      padding: const EdgeInsets.all(AppSize.appSize24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with drag indicator
          Center(
            child: Container(
              width: AppSize.appSize40,
              height: AppSize.appSize4,
              decoration: BoxDecoration(
                color: AppColor.descriptionColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSize.appSize2),
              ),
            ),
          ),
          const SizedBox(height: AppSize.appSize24),

          // Title
          Text(
            'Contacter le propriétaire',
            style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          ),
          const SizedBox(height: AppSize.appSize24),

          // Owner Card
          Container(
            padding: const EdgeInsets.all(AppSize.appSize16),
            decoration: BoxDecoration(
              color: AppColor.secondaryColor,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              border: Border.all(
                color: AppColor.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                // Owner Info Row
                Row(
                  children: [
                    // Avatar with first letter
                    Container(
                      width: AppSize.appSize60,
                      height: AppSize.appSize60,
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        borderRadius: BorderRadius.circular(AppSize.appSize30),
                      ),
                      child: Center(
                        child: Text(
                          firstLetter,
                          style: AppStyle.heading3Medium(
                              color: AppColor.whiteColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSize.appSize16),

                    // Owner Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ownerName,
                            style: AppStyle.heading4SemiBold(
                                color: AppColor.textColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSize.appSize4),
                          Text(
                            'Propriétaire',
                            style: AppStyle.heading6Regular(
                                color: AppColor.descriptionColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSize.appSize20),

                // Contact Information
                if (ownerPhone.isNotEmpty)
                  _buildContactInfoRow(
                    icon: Icons.phone,
                    label: 'Téléphone',
                    value: ownerPhone,
                    onTap: () async {
                      final Uri phoneUri = Uri(scheme: 'tel', path: ownerPhone);
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                      } else {
                        Get.snackbar(
                          'Erreur',
                          'Impossible d\'appeler ce numéro',
                          backgroundColor: AppColor.negativeColor,
                          colorText: AppColor.whiteColor,
                        );
                      }
                    },
                  ),

                if (ownerPhone.isNotEmpty && ownerEmail.isNotEmpty)
                  const SizedBox(height: AppSize.appSize12),

                if (ownerEmail.isNotEmpty)
                  _buildContactInfoRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: ownerEmail,
                    onTap: () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: ownerEmail,
                      );
                      if (await canLaunchUrl(emailUri)) {
                        await launchUrl(emailUri);
                      } else {
                        Get.snackbar(
                          'Erreur',
                          'Impossible d\'ouvrir l\'email',
                          backgroundColor: AppColor.negativeColor,
                          colorText: AppColor.whiteColor,
                        );
                      }
                    },
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSize.appSize24),

          // Action Buttons
          Row(
            children: [
              // Call Button (if phone available)
              if (ownerPhone.isNotEmpty)
                Expanded(
                  child: CommonButton(
                    onPressed: () async {
                      final Uri phoneUri = Uri(scheme: 'tel', path: ownerPhone);
                      if (await canLaunchUrl(phoneUri)) {
                        await launchUrl(phoneUri);
                        Get.back(); // Close bottom sheet
                      } else {
                        Get.snackbar(
                          'Erreur',
                          'Impossible d\'appeler ce numéro',
                          backgroundColor: AppColor.negativeColor,
                          colorText: AppColor.whiteColor,
                        );
                      }
                    },
                    backgroundColor: AppColor.primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.phone,
                          color: AppColor.whiteColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppSize.appSize8),
                        Text(
                          'Appeler',
                          style: AppStyle.heading5Medium(
                              color: AppColor.whiteColor),
                        ),
                      ],
                    ),
                  ),
                ),

              if (ownerPhone.isNotEmpty) const SizedBox(width: AppSize.appSize12),

              // Message Button
              Expanded(
                child: CommonButton(
                  onPressed: () {
                    Get.back(); // Close bottom sheet
                    // Navigate to chat
                    Get.toNamed(
                      AppRoutes.chatView,
                      arguments: {
                        'propertyId': property.id,
                        'sellerId': property.utilisateurId,
                      },
                    );
                  },
                  backgroundColor: ownerPhone.isNotEmpty
                      ? AppColor.whiteColor
                      : AppColor.primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.message,
                        color: ownerPhone.isNotEmpty
                            ? AppColor.primaryColor
                            : AppColor.whiteColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppSize.appSize8),
                      Text(
                        'Message',
                        style: AppStyle.heading5Medium(
                          color: ownerPhone.isNotEmpty
                              ? AppColor.primaryColor
                              : AppColor.whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildContactInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSize.appSize12),
        decoration: BoxDecoration(
          color: AppColor.whiteColor,
          borderRadius: BorderRadius.circular(AppSize.appSize8),
          border: Border.all(
            color: AppColor.borderColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: AppSize.appSize40,
              height: AppSize.appSize40,
              decoration: BoxDecoration(
                color: AppColor.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize8),
              ),
              child: Icon(
                icon,
                color: AppColor.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSize.appSize12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppStyle.heading7Regular(
                        color: AppColor.descriptionColor),
                  ),
                  const SizedBox(height: AppSize.appSize2),
                  Text(
                    value,
                    style: AppStyle.heading6Medium(color: AppColor.textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                color: AppColor.descriptionColor,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
