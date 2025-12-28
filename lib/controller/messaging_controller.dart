import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/conversation_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/message_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/messaging_service.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/session_service.dart';

class MessagingController extends GetxController {
  final MessagingService _messagingService = MessagingService();
  final storage = GetStorage();

  // Conversations list
  RxList<Conversation> conversations = <Conversation>[].obs;
  RxBool isLoadingConversations = false.obs;

  // Messages in current conversation
  RxList<Message> messages = <Message>[].obs;
  RxBool isLoadingMessages = false.obs;
  RxString currentConversationId = ''.obs;

  // Unread count
  RxInt totalUnreadCount = 0.obs;

  // Polling timer
  Timer? _pollingTimer;

  @override
  void onInit() {
    super.onInit();
    startPolling();
    refreshUnreadCount();
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  /// Get current user ID from storage
  String? get currentUserId {
    try {
      // Try to get SessionService
      if (Get.isRegistered<SessionService>()) {
        final sessionService = Get.find<SessionService>();
        final userData = sessionService.getCurrentUserData();
        return userData?['id'];
      }

      // Fallback: read directly from storage
      final userDataString = storage.read('userData');
      if (userDataString == null) return null;

      // If it's already a Map (old format)
      if (userDataString is Map) {
        return userDataString['id']?.toString();
      }

      // If it's a String (new format), parse it
      if (userDataString is String) {
        final userData = jsonDecode(userDataString) as Map<String, dynamic>;
        return userData['id']?.toString();
      }

      return null;
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  /// Start polling for new messages (every 20 seconds)
  void startPolling() {
    _pollingTimer = Timer.periodic(Duration(seconds: 20), (timer) {
      if (currentUserId != null) {
        refreshUnreadCount();
        if (currentConversationId.value.isNotEmpty) {
          refreshMessages(currentConversationId.value);
        }
      }
    });
  }

  /// Load user's conversations
  Future<void> loadConversations() async {
    if (currentUserId == null) {
      print('❌ No user ID found');
      return;
    }

    try {
      isLoadingConversations.value = true;
      conversations.value =
          await _messagingService.getUserConversations(currentUserId!);
      print('✅ Loaded ${conversations.length} conversations');
    } catch (e) {
      print('❌ Error loading conversations: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les conversations',
        backgroundColor: AppColor.negativeColor,
        colorText: AppColor.whiteColor,
      );
    } finally {
      isLoadingConversations.value = false;
    }
  }

  /// Create or open conversation
  Future<Conversation?> createConversation({
    required String propertyId,
    String? initialMessage,
  }) async {
    if (currentUserId == null) {
      print('❌ No user ID found');
      Get.snackbar(
        'Erreur',
        'Veuillez vous connecter',
        backgroundColor: AppColor.negativeColor,
        colorText: AppColor.whiteColor,
      );
      return null;
    }

    try {
      print('🚀 Creating conversation for property: $propertyId');

      final conversation = await _messagingService.createConversation(
        bienImmoId: propertyId,
        buyerId: currentUserId!,
        initialMessage: initialMessage,
      );

      print('✅ Conversation created: ${conversation.id}');

      // Refresh conversations list
      await loadConversations();

      return conversation;
    } catch (e) {
      print('❌ Error creating conversation: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de démarrer la conversation',
        backgroundColor: AppColor.negativeColor,
        colorText: AppColor.whiteColor,
      );
      return null;
    }
  }

  /// Load messages for a conversation
  Future<void> loadMessages(String conversationId) async {
    if (currentUserId == null) return;

    try {
      isLoadingMessages.value = true;
      currentConversationId.value = conversationId;
      messages.value = await _messagingService.getMessages(conversationId);

      print('✅ Loaded ${messages.length} messages');

      // Mark as read
      await _messagingService.markConversationAsRead(
        conversationId: conversationId,
        userId: currentUserId!,
      );

      // Refresh unread count
      await refreshUnreadCount();

      // Refresh conversations to update unread count
      await loadConversations();
    } catch (e) {
      print('❌ Error loading messages: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les messages',
        backgroundColor: AppColor.negativeColor,
        colorText: AppColor.whiteColor,
      );
    } finally {
      isLoadingMessages.value = false;
    }
  }

  /// Refresh messages (for polling)
  Future<void> refreshMessages(String conversationId) async {
    if (currentUserId == null) return;

    try {
      final newMessages = await _messagingService.getMessages(conversationId);
      if (newMessages.length > messages.length) {
        messages.value = newMessages;
        print('✅ Refreshed messages: ${newMessages.length} total');

        // Mark as read
        await _messagingService.markConversationAsRead(
          conversationId: conversationId,
          userId: currentUserId!,
        );
      }
    } catch (e) {
      print('❌ Error refreshing messages: $e');
    }
  }

  /// Send a message
  Future<void> sendMessage(String content) async {
    if (currentUserId == null || currentConversationId.value.isEmpty) {
      print('❌ Cannot send message: no user or conversation');
      return;
    }

    if (content.trim().isEmpty) {
      print('❌ Cannot send empty message');
      return;
    }

    try {
      print('📤 Sending message...');

      final message = await _messagingService.sendMessage(
        conversationId: currentConversationId.value,
        senderId: currentUserId!,
        content: content.trim(),
      );

      // Add message to list
      messages.add(message);
      print('✅ Message sent successfully');

      // Refresh conversations to update last message
      await loadConversations();
    } catch (e) {
      print('❌ Error sending message: $e');
      Get.snackbar(
        'Erreur',
        'Impossible d\'envoyer le message',
        backgroundColor: AppColor.negativeColor,
        colorText: AppColor.whiteColor,
      );
    }
  }

  /// Refresh unread count
  Future<void> refreshUnreadCount() async {
    if (currentUserId == null) return;

    try {
      totalUnreadCount.value =
          await _messagingService.getUnreadCount(currentUserId!);
    } catch (e) {
      print('❌ Error refreshing unread count: $e');
    }
  }

  /// Get unread count for a specific conversation
  int getConversationUnreadCount(Conversation conversation) {
    if (currentUserId == null) return 0;
    final isBuyer = conversation.participantIds.first == currentUserId;
    return isBuyer
        ? conversation.unreadCountBuyer
        : conversation.unreadCountSeller;
  }
}
