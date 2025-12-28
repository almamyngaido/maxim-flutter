import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/admin_users_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/admin/user_details_view.dart';

class AdminUsersView extends StatelessWidget {
  AdminUsersView({super.key});

  final AdminUsersController adminUsersController =
      Get.put(AdminUsersController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppSize.appSize50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Utilisateurs non vérifiés',
              style: AppStyle.heading3SemiBold(color: AppColor.textColor),
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
        ).paddingOnly(
          left: AppSize.appSize16,
          right: AppSize.appSize16,
        ),
        SizedBox(height: AppSize.appSize20),
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
                    SizedBox(height: AppSize.appSize20),
                    ElevatedButton(
                      onPressed: () {
                        adminUsersController.fetchUnverifiedUsers();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primaryColor,
                      ),
                      child: Text(
                        'Réessayer',
                        style:
                            AppStyle.heading5Medium(color: AppColor.whiteColor),
                      ),
                    ),
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
                      style: AppStyle.heading4Medium(color: AppColor.textColor),
                    ),
                    SizedBox(height: AppSize.appSize8),
                    Text(
                      'Tous les utilisateurs sont vérifiés',
                      style: AppStyle.heading5Regular(
                          color: AppColor.descriptionColor),
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
        margin: EdgeInsets.only(bottom: AppSize.appSize16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: AppSize.appSize30,
                  backgroundColor: AppColor.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    (user['name']?[0] ?? 'U').toUpperCase(),
                    style:
                        AppStyle.heading3SemiBold(color: AppColor.primaryColor),
                  ),
                ),
                SizedBox(width: AppSize.appSize12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] ?? 'Nom non disponible',
                        style:
                            AppStyle.heading4Medium(color: AppColor.textColor),
                      ),
                      SizedBox(height: AppSize.appSize4),
                      if (user['email'] != null)
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: AppSize.appSize14,
                              color: AppColor.descriptionColor,
                            ),
                            SizedBox(width: AppSize.appSize4),
                            Expanded(
                              child: Text(
                                user['email'],
                                style: AppStyle.heading6Regular(
                                    color: AppColor.descriptionColor),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (user['phone'] != null)
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: AppSize.appSize14,
                              color: AppColor.descriptionColor,
                            ),
                            SizedBox(width: AppSize.appSize4),
                            Text(
                              user['phone'],
                              style: AppStyle.heading6Regular(
                                  color: AppColor.descriptionColor),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColor.primaryColor,
                  size: AppSize.appSize24,
                ),
              ],
            ),
            SizedBox(height: AppSize.appSize12),
            Divider(height: 1, color: AppColor.borderColor),
            SizedBox(height: AppSize.appSize12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rôle',
                      style: AppStyle.heading6Regular(
                          color: AppColor.descriptionColor),
                    ),
                    Text(
                      user['role'] ?? 'user',
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSize.appSize12,
                    vertical: AppSize.appSize6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSize.appSize20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: AppSize.appSize14,
                        color: Colors.orange,
                      ),
                      SizedBox(width: AppSize.appSize4),
                      Text(
                        'Non vérifié',
                        style: AppStyle.heading6Medium(color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
