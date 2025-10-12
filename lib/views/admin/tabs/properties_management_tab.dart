import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/property_admin_controller.dart';

class PropertiesManagementTab extends StatelessWidget {
  PropertiesManagementTab({super.key});

  final PropertyAdminController controller = Get.put(PropertyAdminController());

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
                'Gestion des biens',
                style: AppStyle.heading4Medium(color: AppColor.textColor),
              ),
              GestureDetector(
                onTap: () {
                  controller.fetchAllProperties();
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
        SizedBox(height: AppSize.appSize12),
        // Statistiques
        Obx(() => Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.appSize16),
              child: Row(
                children: [
                  Expanded(
                    child: buildStatCard(
                      'Total',
                      controller.properties.length.toString(),
                      Icons.home_work,
                      AppColor.primaryColor,
                    ),
                  ),
                  SizedBox(width: AppSize.appSize12),
                  Expanded(
                    child: buildStatCard(
                      'Vendus',
                      controller.soldProperties.length.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            )),
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

            if (controller.properties.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_work_outlined,
                      size: AppSize.appSize80,
                      color: AppColor.descriptionColor,
                    ),
                    SizedBox(height: AppSize.appSize16),
                    Text(
                      'Aucun bien enregistré',
                      style:
                          AppStyle.heading4Medium(color: AppColor.textColor),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchAllProperties(),
              color: AppColor.primaryColor,
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: AppSize.appSize16),
                itemCount: controller.properties.length,
                itemBuilder: (context, index) {
                  final property = controller.properties[index];
                  return buildPropertyCard(property);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(AppSize.appSize12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppSize.appSize24),
          SizedBox(width: AppSize.appSize8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
              ),
              Text(
                value,
                style: AppStyle.heading4SemiBold(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPropertyCard(Map<String, dynamic> property) {
    final bool isAvailable = property['isAvailable'] ?? true;
    final bool isSold = property['isSold'] ?? false;
    final String? soldBy = property['soldBy'];

    return Container(
      margin: EdgeInsets.only(bottom: AppSize.appSize12),
      padding: EdgeInsets.all(AppSize.appSize12),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        borderRadius: BorderRadius.circular(AppSize.appSize12),
        border: Border.all(
          color: isSold
              ? Colors.green.withValues(alpha: 0.3)
              : (!isAvailable
                  ? Colors.red.withValues(alpha: 0.3)
                  : AppColor.borderColor),
          width: isSold || !isAvailable ? 2 : 1,
        ),
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
              Container(
                width: AppSize.appSize60,
                height: AppSize.appSize60,
                decoration: BoxDecoration(
                  color: AppColor.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize8),
                ),
                child: Icon(
                  Icons.home_work,
                  color: AppColor.primaryColor,
                  size: AppSize.appSize32,
                ),
              ),
              SizedBox(width: AppSize.appSize12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['title'] ?? 'Bien immobilier',
                      style: AppStyle.heading5Medium(color: AppColor.textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      property['location'] ?? 'Localisation non spécifiée',
                      style: AppStyle.heading6Regular(
                          color: AppColor.descriptionColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (property['price'] != null)
                      Text(
                        '${property['price']} FCFA',
                        style: AppStyle.heading5SemiBold(
                            color: AppColor.primaryColor),
                      ),
                  ],
                ),
              ),
              // Statut badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isSold)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.appSize8,
                        vertical: AppSize.appSize4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                      ),
                      child: Text(
                        'VENDU',
                        style: AppStyle.heading6Medium(color: Colors.green),
                      ),
                    ),
                  if (!isSold)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSize.appSize8,
                        vertical: AppSize.appSize4,
                      ),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                      ),
                      child: Text(
                        isAvailable ? 'Disponible' : 'Indisponible',
                        style: AppStyle.heading6Medium(
                          color: isAvailable ? Colors.blue : Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (isSold && soldBy != null) ...[
            SizedBox(height: AppSize.appSize8),
            Container(
              padding: EdgeInsets.all(AppSize.appSize8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppSize.appSize8),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: AppSize.appSize14, color: Colors.green),
                  SizedBox(width: AppSize.appSize4),
                  Text(
                    'Vendu par: $soldBy',
                    style: AppStyle.heading6Regular(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: AppSize.appSize12),
          Row(
            children: [
              if (!isSold) ...[
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      controller.updateAvailability(
                          property['_id'], !isAvailable);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: AppSize.appSize8),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? Colors.orange.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                        border: Border.all(
                          color: isAvailable
                              ? Colors.orange.withValues(alpha: 0.3)
                              : Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAvailable ? Icons.visibility_off : Icons.visibility,
                            size: AppSize.appSize16,
                            color: isAvailable ? Colors.orange : Colors.green,
                          ),
                          SizedBox(width: AppSize.appSize4),
                          Text(
                            isAvailable ? 'Masquer' : 'Afficher',
                            style: AppStyle.heading6Medium(
                              color: isAvailable ? Colors.orange : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSize.appSize8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      showSoldDialog(property);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: AppSize.appSize8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppSize.appSize8),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: AppSize.appSize16,
                            color: Colors.green,
                          ),
                          SizedBox(width: AppSize.appSize4),
                          Text(
                            'Marquer vendu',
                            style: AppStyle.heading6Medium(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: AppSize.appSize8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSize.appSize8),
                    ),
                    child: Center(
                      child: Text(
                        'Bien vendu ✓',
                        style: AppStyle.heading5Medium(color: Colors.green),
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(width: AppSize.appSize8),
              GestureDetector(
                onTap: () {
                  showDeleteDialog(property);
                },
                child: Container(
                  padding: EdgeInsets.all(AppSize.appSize8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSize.appSize8),
                  ),
                  child: Icon(
                    Icons.delete,
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

  void showSoldDialog(Map<String, dynamic> property) {
    final TextEditingController soldByController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: Text(
          'Marquer comme vendu',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Entrez le nom de la personne qui a vendu ce bien:',
              style: AppStyle.heading5Regular(color: AppColor.descriptionColor),
            ),
            SizedBox(height: AppSize.appSize16),
            TextField(
              controller: soldByController,
              decoration: InputDecoration(
                hintText: 'Nom du vendeur',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSize.appSize8),
                ),
              ),
            ),
          ],
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
              if (soldByController.text.trim().isEmpty) {
                Get.snackbar(
                  'Erreur',
                  'Veuillez entrer le nom du vendeur',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              Get.back();
              await controller.markAsSold(
                  property['_id'], soldByController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
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

  void showDeleteDialog(Map<String, dynamic> property) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Supprimer le bien',
          style: AppStyle.heading4Medium(color: AppColor.textColor),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer ce bien ? Cette action est irréversible.',
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
              await controller.deleteProperty(property['_id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Supprimer',
              style: AppStyle.heading5Medium(color: AppColor.whiteColor),
            ),
          ),
        ],
      ),
    );
  }
}
