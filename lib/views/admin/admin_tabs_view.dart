import 'package:flutter/material.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/admin/tabs/unverified_users_tab.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/admin/tabs/verified_users_tab.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/admin/tabs/admin_roles_tab.dart';
import 'package:luxury_real_estate_flutter_ui_kit/views/admin/tabs/properties_management_tab.dart';

class AdminTabsView extends StatelessWidget {
  AdminTabsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColor.whiteColor,
        body: Column(
          children: [
            SizedBox(height: AppSize.appSize50),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSize.appSize16),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: AppColor.primaryColor,
                    size: AppSize.appSize32,
                  ),
                  SizedBox(width: AppSize.appSize12),
                  Text(
                    'Administration',
                    style: AppStyle.heading3SemiBold(color: AppColor.textColor),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSize.appSize20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: AppSize.appSize16),
              decoration: BoxDecoration(
                color: AppColor.backgroundColor,
                borderRadius: BorderRadius.circular(AppSize.appSize12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: AppColor.primaryColor,
                  borderRadius: BorderRadius.circular(AppSize.appSize12),
                ),
                labelColor: AppColor.whiteColor,
                unselectedLabelColor: AppColor.textColor,
                labelStyle: AppStyle.heading6Medium(color: AppColor.whiteColor),
                unselectedLabelStyle:
                    AppStyle.heading6Regular(color: AppColor.textColor),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: AppSize.appSize16),
                        SizedBox(width: AppSize.appSize4),
                        Flexible(
                          child: Text(
                            'Non vérifiés',
                            style: TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user, size: AppSize.appSize16),
                        SizedBox(width: AppSize.appSize4),
                        Flexible(
                          child: Text(
                            'Utilisateurs',
                            style: TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.admin_panel_settings, size: AppSize.appSize16),
                        SizedBox(width: AppSize.appSize4),
                        Flexible(
                          child: Text(
                            'Admins',
                            style: TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home_work, size: AppSize.appSize16),
                        SizedBox(width: AppSize.appSize4),
                        Flexible(
                          child: Text(
                            'Biens',
                            style: TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  UnverifiedUsersTab(),
                  VerifiedUsersTab(),
                  AdminRolesTab(),
                  PropertiesManagementTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
