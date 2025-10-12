import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/admin_roles_controller.dart';

class AdminRolesTab extends StatelessWidget {
  AdminRolesTab({super.key});

  final AdminRolesController controller = Get.put(AdminRolesController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: AppSize.appSize16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSize.appSize16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gestion des rôles',
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () {
                  controller.fetchAllUsers();
                },
                child: Icon(
                  Icons.refresh,
                  color: AppColor.primaryColor,
                  size: AppSize.appSize24,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSize.appSize16),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColor.primaryColor,
                ),
              );
            }

            if (controller.errorMessage.value.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: AppSize.appSize50,
                      color: Colors.red,
                    ),
                    SizedBox(height: AppSize.appSize16),
                    Text(
                      controller.errorMessage.value,
                      style: AppStyle.heading5Regular(color: Colors.red),
                      textAlign: TextAlign.center,
                    ).paddingSymmetric(horizontal: AppSize.appSize32),
                  ],
                ),
              );
            }

            if (controller.allUsers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: AppSize.appSize80,
                      color: AppColor.descriptionColor,
                    ),
                    SizedBox(height: AppSize.appSize16),
                    Text(
                      'Aucun utilisateur',
                      style:
                          AppStyle.heading4Medium(color: AppColor.textColor),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchAllUsers(),
              color: AppColor.primaryColor,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: AppSize.appSize16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Administrateurs
                    Row(
                      children: [
                        Icon(
                          Icons.admin_panel_settings,
                          color: AppColor.primaryColor,
                          size: AppSize.appSize20,
                        ),
                        SizedBox(width: AppSize.appSize8),
                        Text(
                          'Administrateurs (${controller.adminUsers.length})',
                          style: AppStyle.heading5SemiBold(
                              color: AppColor.textColor),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSize.appSize12),
                    ...controller.adminUsers.map((user) => buildUserCard(user, true)),

                    SizedBox(height: AppSize.appSize24),

                    // Section Utilisateurs
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          color: AppColor.descriptionColor,
                          size: AppSize.appSize20,
                        ),
                        SizedBox(width: AppSize.appSize8),
                        Text(
                          'Utilisateurs (${controller.regularUsers.length})',
                          style: AppStyle.heading5SemiBold(
                              color: AppColor.textColor),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSize.appSize12),
                    ...controller.regularUsers.map((user) => buildUserCard(user, false)),

                    SizedBox(height: AppSize.appSize20),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildUserCard(Map<String, dynamic> user, bool isAdmin) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSize.appSize12),
      padding: EdgeInsets.all(AppSize.appSize12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(
          color: isAdmin
              ? AppColor.primaryColor.withValues(alpha: 0.3)
              : AppColor.borderColor,
          width: isAdmin ? 2 : 1,
        ),
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
          CircleAvatar(
            radius: AppSize.appSize24,
            backgroundColor: isAdmin
                ? AppColor.primaryColor.withValues(alpha: 0.1)
                : AppColor.backgroundColor,
            child: Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: isAdmin ? AppColor.primaryColor : AppColor.textColor,
              size: AppSize.appSize24,
            ),
          ),
          SizedBox(width: AppSize.appSize12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getFullName(user['nom'], user['prenom']),
                  style: AppStyle.heading5Medium(color: AppColor.textColor),
                ),
                if (user['email'] != null)
                  Text(
                    user['email'],
                    style: AppStyle.heading6Regular(
                        color: AppColor.descriptionColor),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              showRoleChangeDialog(user, isAdmin);
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.appSize12,
                vertical: AppSize.appSize6,
              ),
              decoration: BoxDecoration(
                color: isAdmin
                    ? AppColor.primaryColor
                    : AppColor.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize20),
              ),
              child: Row(
                children: [
                  Text(
                    isAdmin ? 'Admin' : 'Promouvoir',
                    style: AppStyle.heading6Medium(
                      color: isAdmin
                          ? AppColor.whiteColor
                          : AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(width: AppSize.appSize4),
                  Icon(
                    isAdmin ? Icons.arrow_downward : Icons.arrow_upward,
                    size: AppSize.appSize14,
                    color: isAdmin
                        ? AppColor.whiteColor
                        : AppColor.primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showRoleChangeDialog(Map<String, dynamic> user, bool isCurrentlyAdmin) {
    Get.dialog(
      AlertDialog(
        title: Text(
          isCurrentlyAdmin ? 'Retirer le rôle Admin' : 'Promouvoir en Admin',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        content: Text(
          isCurrentlyAdmin
              ? 'Voulez-vous retirer les privilèges d\'administrateur à ${_getFullName(user['nom'], user['prenom'])} ?'
              : 'Voulez-vous promouvoir ${_getFullName(user['nom'], user['prenom'])} en tant qu\'administrateur ? Il aura accès à toutes les fonctionnalités d\'administration.',
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
              final newRole = isCurrentlyAdmin ? 'user' : 'admin';
              await controller.updateRole(user['id'], newRole);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCurrentlyAdmin
                  ? Colors.orange
                  : AppColor.primaryColor,
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
}
