import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_string.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/messaging_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationView extends StatelessWidget {
  NotificationView({super.key});

  final MessagingController messagingController = Get.put(MessagingController());

  @override
  Widget build(BuildContext context) {
    // Configure timeago for French
    timeago.setLocaleMessages('fr', timeago.FrMessages());

    // Load conversations to show unread messages
    messagingController.loadConversations();

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildNotificationsList(),
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
        AppString.notifications,
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
    );
  }

  Widget buildNotificationsList() {
    return Obx(() {
      if (messagingController.isLoadingConversations.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(AppSize.appSize50),
            child: CircularProgressIndicator(
              color: AppColor.primaryColor,
            ),
          ),
        );
      }

      // Filter conversations with unread messages
      final unreadConversations = messagingController.conversations
          .where((conv) =>
              messagingController.getConversationUnreadCount(conv) > 0)
          .toList();

      if (unreadConversations.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSize.appSize20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: AppSize.appSize64,
                  color: AppColor.descriptionColor,
                ),
                const SizedBox(height: AppSize.appSize16),
                Text(
                  'Aucune notification',
                  style: AppStyle.heading5Regular(
                    color: AppColor.descriptionColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSize.appSize8),
                Text(
                  'Vous n\'avez pas de nouveaux messages',
                  style: AppStyle.heading6Regular(
                    color: AppColor.descriptionColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => messagingController.loadConversations(),
        color: AppColor.primaryColor,
        child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(
            left: AppSize.appSize16,
            right: AppSize.appSize16,
            top: AppSize.appSize10,
            bottom: AppSize.appSize20,
          ),
          physics: const ClampingScrollPhysics(),
          itemCount: unreadConversations.length,
          itemBuilder: (context, index) {
            final conversation = unreadConversations[index];
            final unreadCount =
                messagingController.getConversationUnreadCount(conversation);
            final propertyTitle =
                conversation.bienImmo?.titre ?? 'Propriété';
            final timeAgo = timeago.format(
              conversation.lastMessageAt,
              locale: 'fr',
            );

            return GestureDetector(
              onTap: () {
                Get.toNamed(
                  AppRoutes.chatView,
                  arguments: {
                    'conversationId': conversation.id,
                    'propertyTitle': propertyTitle,
                  },
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Nouveau message - $propertyTitle',
                          style: AppStyle.heading5Medium(
                            color: AppColor.textColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSize.appSize8,
                          vertical: AppSize.appSize4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.primaryColor,
                          borderRadius:
                              BorderRadius.circular(AppSize.appSize10),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: AppStyle.heading6Medium(
                            color: AppColor.whiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (conversation.lastMessagePreview != null)
                    Text(
                      conversation.lastMessagePreview!,
                      style: AppStyle.heading5Regular(
                        color: AppColor.descriptionColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ).paddingOnly(top: AppSize.appSize6),
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      timeAgo,
                      style: AppStyle.heading6Regular(
                        color: AppColor.descriptionColor,
                      ),
                    ).paddingOnly(top: AppSize.appSize6),
                  ),
                  if (index < unreadConversations.length - 1) ...[
                    Divider(
                      color: AppColor.descriptionColor
                          .withValues(alpha: AppSize.appSizePoint50),
                      thickness: AppSize.appSizePoint7,
                      height: AppSize.appSize0,
                    ).paddingOnly(
                        top: AppSize.appSize16, bottom: AppSize.appSize16),
                  ],
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
