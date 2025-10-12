import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/admin_users_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/admin/user_details_view.dart';

class UnverifiedUsersTab extends StatelessWidget {
  UnverifiedUsersTab({super.key});

  final AdminUsersController adminUsersController =
      Get.put(AdminUsersController());

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
                'Utilisateurs non vérifiés',
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () {
                  adminUsersController.fetchUnverifiedUsers();
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
            if (adminUsersController.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColor.primaryColor,
                ),
              );
            }

            if (adminUsersController.errorMessage.value.isNotEmpty) {
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
                      adminUsersController.errorMessage.value,
                      style: AppStyle.heading5Regular(color: Colors.red),
                      textAlign: TextAlign.center,
                    ).paddingSymmetric(horizontal: AppSize.appSize32),
                  ],
                ),
              );
            }

            if (adminUsersController.unverifiedUsers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: AppSize.appSize80,
                      color: AppColor.primaryColor,
                    ),
                    SizedBox(height: AppSize.appSize16),
                    Text(
                      'Aucun utilisateur non vérifié',
                      style:
                          AppStyle.heading4Medium(color: AppColor.textColor),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => adminUsersController.fetchUnverifiedUsers(),
              color: AppColor.primaryColor,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: AppSize.appSize16),
                itemCount: adminUsersController.unverifiedUsers.length,
                itemBuilder: (context, index) {
                  final user = adminUsersController.unverifiedUsers[index];
                  return buildUserCard(context, user);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildUserCard(BuildContext context, Map<String, dynamic> user) {
    return GestureDetector(
      onTap: () {
        Get.to(() => UserDetailsView(userData: user));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSize.appSize12),
        padding: EdgeInsets.all(AppSize.appSize12),
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
            CircleAvatar(
              radius: AppSize.appSize24,
              backgroundColor: AppColor.primaryColor.withValues(alpha: 0.1),
              child: Text(
                _getInitials(user['nom'], user['prenom']),
                style: AppStyle.heading5SemiBold(color: AppColor.primaryColor),
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
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSize.appSize8,
                vertical: AppSize.appSize4,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
              child: Text(
                'Non vérifié',
                style: AppStyle.heading6Medium(color: Colors.orange),
              ),
            ),
          ],
        ),
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
}
