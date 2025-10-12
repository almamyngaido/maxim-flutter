import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/admin_users_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';

class UserDetailsView extends StatelessWidget {
  final Map<String, dynamic> userData;

  UserDetailsView({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    final adminUsersController = Get.find<AdminUsersController>();

    // Utiliser 'verified' du modèle backend
    final bool isVerified = userData['verified'] ?? false;
    final String userId = userData['id'] ?? '';

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildUserDetailsBody(isVerified, userId, adminUsersController),
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
        'Détails utilisateur',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildUserDetailsBody(
      bool isVerified, String userId, AdminUsersController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSize.appSize16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile section
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: AppSize.appSize60,
                  backgroundColor: AppColor.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    _getInitials(userData['nom'], userData['prenom']),
                    style: AppStyle.heading1(color: AppColor.primaryColor),
                  ),
                ),
                SizedBox(height: AppSize.appSize16),
                Text(
                  _getFullName(userData['nom'], userData['prenom']),
                  style: AppStyle.heading3SemiBold(color: AppColor.textColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSize.appSize8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.appSize16,
                    vertical: AppSize.appSize8,
                  ),
                  decoration: BoxDecoration(
                    color: isVerified
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSize.appSize20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVerified
                            ? Icons.check_circle
                            : Icons.warning_amber_rounded,
                        size: AppSize.appSize16,
                        color: isVerified ? Colors.green : Colors.orange,
                      ),
                      SizedBox(width: AppSize.appSize6),
                      Text(
                        isVerified ? 'Vérifié' : 'Non vérifié',
                        style: AppStyle.heading5Medium(
                          color: isVerified ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSize.appSize32),

          // Information section
          Text(
            'Informations',
            style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          ),
          SizedBox(height: AppSize.appSize16),

          if (userData['email'] != null)
            buildInfoCard(
              icon: Icons.email_outlined,
              label: 'Email',
              value: userData['email'],
            ),

          if (userData['phoneNumber'] != null)
            buildInfoCard(
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              value: userData['phoneNumber'],
            ),

          buildInfoCard(
            icon: Icons.person_outline,
            label: 'Rôle',
            value: userData['role'] ?? 'user',
          ),

          if (userData['dateInscription'] != null)
            buildInfoCard(
              icon: Icons.calendar_today_outlined,
              label: 'Date d\'inscription',
              value: _formatDate(userData['dateInscription']),
            ),

          SizedBox(height: AppSize.appSize32),

          // Verification toggle section
          Text(
            'Actions administrateur',
            style: AppStyle.heading3SemiBold(color: AppColor.textColor),
          ),
          SizedBox(height: AppSize.appSize16),

          Container(
            padding: EdgeInsets.all(AppSize.appSize16),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              borderRadius: BorderRadius.circular(AppSize.appSize12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: AppSize.appSizePoint1,
                  blurRadius: AppSize.appSize4,
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statut de vérification',
                          style: AppStyle.heading5Medium(
                              color: AppColor.textColor),
                        ),
                        SizedBox(height: AppSize.appSize4),
                        Text(
                          'Autoriser l\'accès complet',
                          style: AppStyle.heading6Regular(
                              color: AppColor.descriptionColor),
                        ),
                      ],
                    ),
                    Obx(() => Switch(
                          value: isVerified,
                          onChanged: controller.isLoading.value
                              ? null
                              : (value) {
                                  showVerificationDialog(
                                      value, userId, controller);
                                },
                          activeTrackColor: Colors.green,
                        )),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: AppSize.appSize20),
        ],
      ),
    );
  }

  Widget buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSize.appSize12),
      padding: EdgeInsets.all(AppSize.appSize16),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            spreadRadius: AppSize.appSizePoint1,
            blurRadius: AppSize.appSize4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSize.appSize10),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSize.appSize8),
            ),
            child: Icon(
              icon,
              size: AppSize.appSize20,
              color: AppColor.primaryColor,
            ),
          ),
          SizedBox(width: AppSize.appSize12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor),
                ),
                SizedBox(height: AppSize.appSize2),
                Text(
                  value,
                  style: AppStyle.heading5Medium(color: AppColor.textColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showVerificationDialog(
      bool newValue, String userId, AdminUsersController controller) {
    Get.dialog(
      AlertDialog(
        title: Text(
          newValue ? 'Vérifier l\'utilisateur' : 'Retirer la vérification',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        content: Text(
          newValue
              ? 'Voulez-vous vraiment vérifier cet utilisateur ? Il aura accès à toutes les fonctionnalités.'
              : 'Voulez-vous vraiment retirer la vérification de cet utilisateur ?',
          style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'Annuler',
              style: AppStyle.heading5Medium(color: AppColor.descriptionColor),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await controller.updateUserVerification(userId, newValue);
              Get.back(); // Retour à la liste après mise à jour
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newValue ? Colors.green : AppColor.primaryColor,
            ),
            child: Text(
              'Confirmer',
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
          ),
        ],
      ),
    );
  }

  String _getFullName(String? nom, String? prenom) {
    final parts = <String>[];
    if (nom != null && nom.isNotEmpty) parts.add(nom);
    if (prenom != null && prenom.isNotEmpty) parts.add(prenom);
    return parts.isEmpty ? 'Nom non disponible' : parts.join(' ');
  }

  String _getInitials(String? nom, String? prenom) {
    String initials = '';
    if (nom != null && nom.isNotEmpty) initials += nom[0];
    if (prenom != null && prenom.isNotEmpty) initials += prenom[0];
    return initials.isEmpty ? 'U' : initials.toUpperCase();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
