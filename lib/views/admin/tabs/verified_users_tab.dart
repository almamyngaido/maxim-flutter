import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/verified_users_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/admin/user_details_view.dart';

class VerifiedUsersTab extends StatelessWidget {
  VerifiedUsersTab({super.key});

  final VerifiedUsersController controller = Get.put(VerifiedUsersController());

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
                'Utilisateurs vérifiés',
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () {
                  controller.fetchVerifiedUsers();
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

            if (controller.verifiedUsers.isEmpty) {
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
                      'Aucun utilisateur vérifié',
                      style:
                          AppStyle.heading4Medium(color: AppColor.textColor),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchVerifiedUsers(),
              color: AppColor.primaryColor,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: AppSize.appSize16),
                itemCount: controller.verifiedUsers.length,
                itemBuilder: (context, index) {
                  final user = controller.verifiedUsers[index];
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
    return Container(
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
            backgroundColor: Colors.green.withValues(alpha: 0.1),
            child: Text(
              _getInitials(user['nom'], user['prenom']),
              style: AppStyle.heading5SemiBold(color: Colors.green),
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
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.appSize6,
                        vertical: AppSize.appSize2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                      ),
                      child: Text(
                        'Vérifié',
                        style: AppStyle.heading6Medium(color: Colors.green),
                      ),
                    ),
                    SizedBox(width: AppSize.appSize8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.appSize6,
                        vertical: AppSize.appSize2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                      ),
                      child: Text(
                        user['role'] ?? 'user',
                        style:
                            AppStyle.heading6Medium(color: AppColor.primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => UserDetailsView(userData: user));
                },
                child: Container(
                  padding: EdgeInsets.all(AppSize.appSize8),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSize.appSize8),
                  ),
                  child: Icon(
                    Icons.visibility,
                    color: AppColor.primaryColor,
                    size: AppSize.appSize20,
                  ),
                ),
              ),
              SizedBox(width: AppSize.appSize8),
              GestureDetector(
                onTap: () {
                  showDeactivateDialog(user);
                },
                child: Container(
                  padding: EdgeInsets.all(AppSize.appSize8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSize.appSize8),
                  ),
                  child: Icon(
                    Icons.block,
                    color: Colors.red,
                    size: AppSize.appSize20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void showDeactivateDialog(Map<String, dynamic> user) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Désactiver l\'utilisateur',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        content: Text(
          'Voulez-vous vraiment désactiver ${_getFullName(user['nom'], user['prenom'])} ? Il perdra l\'accès à la plateforme.',
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
              await controller.deactivateUser(user['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Désactiver',
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
}
