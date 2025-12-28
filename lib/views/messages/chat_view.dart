import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/messaging_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/gen/assets.gen.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/message_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final MessagingController messagingController = Get.find<MessagingController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String conversationId = '';
  String propertyTitle = '';

  @override
  void initState() {
    super.initState();

    // Configure timeago for French
    timeago.setLocaleMessages('fr', timeago.FrMessages());

    // Get arguments
    final args = Get.arguments as Map<String, dynamic>?;
    conversationId = args?['conversationId'] ?? '';
    propertyTitle = args?['propertyTitle'] ?? 'Conversation';

    // Load messages
    if (conversationId.isNotEmpty) {
      messagingController.loadMessages(conversationId);
    }

    // Auto-scroll to bottom when new messages arrive
    ever(messagingController.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final content = messageController.text.trim();
    if (content.isNotEmpty) {
      messagingController.sendMessage(content);
      messageController.clear();

      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: buildAppBar(),
      body: Column(
        children: [
          Expanded(child: buildMessagesList()),
          buildMessageInput(),
        ],
      ),
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
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            propertyTitle,
            style: AppStyle.heading5Medium(color: AppColor.textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Conversation',
            style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
          ),
        ],
      ),
    );
  }

  Widget buildMessagesList() {
    return Obx(() {
      if (messagingController.isLoadingMessages.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColor.primaryColor,
          ),
        );
      }

      if (messagingController.messages.isEmpty) {
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
                  'Aucun message',
                  style: AppStyle.heading5Regular(
                    color: AppColor.descriptionColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSize.appSize8),
                Text(
                  'Envoyez un message pour démarrer la conversation',
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

      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSize.appSize16,
          vertical: AppSize.appSize12,
        ),
        itemCount: messagingController.messages.length,
        itemBuilder: (context, index) {
          final message = messagingController.messages[index];
          final isCurrentUser = message.senderId == messagingController.currentUserId;
          return buildMessageBubble(message, isCurrentUser);
        },
      );
    });
  }

  Widget buildMessageBubble(Message message, bool isCurrentUser) {
    final timeAgo = timeago.format(message.timestamp, locale: 'fr');

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSize.appSize12),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Sender name (if not current user and has sender info)
          if (!isCurrentUser && message.sender != null)
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSize.appSize4,
                left: AppSize.appSize8,
              ),
              child: Text(
                message.sender!.fullName,
                style: AppStyle.heading6Regular(
                  color: AppColor.descriptionColor,
                ),
              ),
            ),

          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: Get.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSize.appSize16,
              vertical: AppSize.appSize12,
            ),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? AppColor.primaryColor
                  : AppColor.borderColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(AppSize.appSize16),
                topRight: const Radius.circular(AppSize.appSize16),
                bottomLeft: isCurrentUser
                    ? const Radius.circular(AppSize.appSize16)
                    : const Radius.circular(AppSize.appSize4),
                bottomRight: isCurrentUser
                    ? const Radius.circular(AppSize.appSize4)
                    : const Radius.circular(AppSize.appSize16),
              ),
            ),
            child: Text(
              message.content,
              style: AppStyle.heading6Regular(
                color: isCurrentUser
                    ? AppColor.whiteColor
                    : AppColor.textColor,
              ),
            ),
          ),

          // Timestamp
          Padding(
            padding: const EdgeInsets.only(
              top: AppSize.appSize4,
              left: AppSize.appSize8,
              right: AppSize.appSize8,
            ),
            child: Text(
              timeAgo,
              style: AppStyle.heading6Regular(
                color: AppColor.descriptionColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSize.appSize16,
        vertical: AppSize.appSize12,
      ),
      decoration: BoxDecoration(
        color: AppColor.whiteColor,
        border: Border(
          top: BorderSide(
            color: AppColor.borderColor,
            width: AppSize.appSize1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text input
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSize.appSize16,
                ),
                decoration: BoxDecoration(
                  color: AppColor.borderColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSize.appSize24),
                ),
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Écrivez votre message...',
                    hintStyle: AppStyle.heading6Regular(
                      color: AppColor.descriptionColor,
                    ),
                    border: InputBorder.none,
                  ),
                  style: AppStyle.heading6Regular(
                    color: AppColor.textColor,
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: AppSize.appSize12),

            // Send button
            GestureDetector(
              onTap: sendMessage,
              child: Container(
                width: AppSize.appSize44,
                height: AppSize.appSize44,
                decoration: const BoxDecoration(
                  color: AppColor.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: AppColor.whiteColor,
                  size: AppSize.appSize20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
