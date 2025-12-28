import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/cached_network_image_widget.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/messaging_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/conversation_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsListView extends StatelessWidget {
  ConversationsListView({super.key});

  final MessagingController messagingController = Get.put(MessagingController());

  @override
  Widget build(BuildContext context) {
    // Configure timeago for French
    timeago.setLocaleMessages('fr', timeago.FrMessages());

    // Load conversations when view is built
    messagingController.loadConversations();

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: buildConversationsList(),
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
        'Messages',
        style: AppStyle.heading4Medium(color: AppColor.textColor),
      ),
      actions: [
        Obx(() {
          if (messagingController.totalUnreadCount.value > 0) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSize.appSize16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSize.appSize12,
                    vertical: AppSize.appSize6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.primaryColor,
                    borderRadius: BorderRadius.circular(AppSize.appSize12),
                  ),
                  child: Text(
                    '${messagingController.totalUnreadCount.value}',
                    style: AppStyle.heading6Medium(color: AppColor.whiteColor),
                  ),
                ),
              ),
            );
          }
          return const SizedBox();
        }),
      ],
    );
  }

  Widget buildConversationsList() {
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

      if (messagingController.conversations.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSize.appSize20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: AppSize.appSize64,
                  color: AppColor.descriptionColor,
                ),
                const SizedBox(height: AppSize.appSize16),
                Text(
                  'Aucune conversation',
                  style: AppStyle.heading5Regular(
                    color: AppColor.descriptionColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSize.appSize8),
                Text(
                  'Contactez un propriétaire pour démarrer une conversation',
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
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            vertical: AppSize.appSize16,
          ),
          itemCount: messagingController.conversations.length,
          separatorBuilder: (context, index) => const Divider(
            height: AppSize.appSize1,
            color: AppColor.borderColor,
          ),
          itemBuilder: (context, index) {
            final conversation = messagingController.conversations[index];
            return buildConversationItem(conversation);
          },
        ),
      );
    });
  }

  Widget buildConversationItem(Conversation conversation) {
    final unreadCount =
        messagingController.getConversationUnreadCount(conversation);
    final hasUnread = unreadCount > 0;

    // Get property image URL
    String propertyImageUrl = '';
    final listeImages = conversation.bienImmo?.listeImages;
    if (listeImages != null && listeImages.isNotEmpty) {
      final imagePath = listeImages.first;
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        propertyImageUrl = imagePath;
      } else {
        propertyImageUrl = '${ApiConfig.baseUrl}/$imagePath';
      }
    }

    // Get property title
    final propertyTitle = conversation.bienImmo?.titre ?? 'Propriété';

    // Format timestamp
    final timeAgo = timeago.format(
      conversation.lastMessageAt,
      locale: 'fr',
    );

    return InkWell(
      onTap: () {
        Get.toNamed(
          AppRoutes.chatView,
          arguments: {
            'conversationId': conversation.id,
            'propertyTitle': propertyTitle,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSize.appSize16,
          vertical: AppSize.appSize12,
        ),
        color: hasUnread ? AppColor.primaryColor.withValues(alpha: 0.05) : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSize.appSize8),
              child: PropertyImageWidget(
                imageUrl: propertyImageUrl,
                width: AppSize.appSize60,
                height: AppSize.appSize60,
                borderRadius: BorderRadius.circular(AppSize.appSize8),
              ),
            ),
            const SizedBox(width: AppSize.appSize12),

            // Conversation details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property title
                  Text(
                    propertyTitle,
                    style: hasUnread
                        ? AppStyle.heading5Medium(color: AppColor.textColor)
                        : AppStyle.heading5Regular(color: AppColor.textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSize.appSize4),

                  // Last message preview
                  if (conversation.lastMessagePreview != null)
                    Text(
                      conversation.lastMessagePreview!,
                      style: hasUnread
                          ? AppStyle.heading6Medium(
                              color: AppColor.descriptionColor)
                          : AppStyle.heading6Regular(
                              color: AppColor.descriptionColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSize.appSize8),

            // Time and unread badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Timestamp
                Text(
                  timeAgo,
                  style: AppStyle.heading6Regular(
                    color: AppColor.descriptionColor,
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(height: AppSize.appSize6),
                  // Unread badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSize.appSize8,
                      vertical: AppSize.appSize4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: BorderRadius.circular(AppSize.appSize10),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: AppStyle.heading6Medium(
                        color: AppColor.whiteColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
