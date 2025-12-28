# Flutter Messaging Implementation Guide

## ✅ Backend Testing Results

All messaging endpoints have been tested and are working perfectly:

### Test Summary
1. ✅ **Create Conversation** - Creates new conversation or returns existing
2. ✅ **Send Messages** - Messages sent successfully with timestamps
3. ✅ **Get User Conversations** - Returns conversations with property details and unread counts
4. ✅ **Get Messages** - Returns all messages in conversation with sender info
5. ✅ **Mark as Read** - Marks messages as read and updates unread counts
6. ✅ **Unread Count** - Returns total unread messages across all conversations

**Backend API Base URL:** `http://192.168.1.4:3000`

---

## 🚀 Flutter Implementation Steps

### Step 1: Create Message Models

Create `lib/models/conversation_model.dart`:
```dart
class Conversation {
  final String id;
  final String bienImmoId;
  final List<String> participantIds;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final int unreadCountBuyer;
  final int unreadCountSeller;
  final String? lastMessagePreview;
  final BienImmo? bienImmo;

  Conversation({
    required this.id,
    required this.bienImmoId,
    required this.participantIds,
    required this.createdAt,
    required this.lastMessageAt,
    required this.unreadCountBuyer,
    required this.unreadCountSeller,
    this.lastMessagePreview,
    this.bienImmo,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      bienImmoId: json['bienImmoId'],
      participantIds: List<String>.from(json['participantIds']),
      createdAt: DateTime.parse(json['createdAt']),
      lastMessageAt: DateTime.parse(json['lastMessageAt']),
      unreadCountBuyer: json['unreadCountBuyer'] ?? 0,
      unreadCountSeller: json['unreadCountSeller'] ?? 0,
      lastMessagePreview: json['lastMessagePreview'],
      bienImmo: json['bienImmo'] != null
          ? BienImmo.fromJson(json['bienImmo'])
          : null,
    );
  }
}
```

Create `lib/models/message_model.dart`:
```dart
class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final DateTime? readAt;
  final UserSender? sender;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.readAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      sender: json['sender'] != null
          ? UserSender.fromJson(json['sender'])
          : null,
    );
  }
}

class UserSender {
  final String id;
  final String nom;
  final String prenom;
  final String email;

  UserSender({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  factory UserSender.fromJson(Map<String, dynamic> json) {
    return UserSender(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'] ?? '',
      email: json['email'],
    );
  }

  String get fullName => '$prenom $nom'.trim();
}
```

---

### Step 2: Create Messaging Service

Create `lib/services/messaging_service.dart`:
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/models/conversation_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/models/message_model.dart';

class MessagingService {
  String get baseUrl => ApiConfig.baseUrl;

  /// Create or get existing conversation
  Future<Conversation> createConversation({
    required String bienImmoId,
    required String buyerId,
    String? initialMessage,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/conversations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'bienImmoId': bienImmoId,
        'buyerId': buyerId,
        if (initialMessage != null) 'initialMessage': initialMessage,
      }),
    );

    if (response.statusCode == 200) {
      return Conversation.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create conversation: ${response.body}');
    }
  }

  /// Get user's conversations
  Future<List<Conversation>> getUserConversations(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/user/$userId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Conversation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get conversations: ${response.body}');
    }
  }

  /// Get messages in a conversation
  Future<List<Message>> getMessages(String conversationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/$conversationId/messages'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get messages: ${response.body}');
    }
  }

  /// Send a message
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/messages'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversationId': conversationId,
        'senderId': senderId,
        'content': content,
      }),
    );

    if (response.statusCode == 200) {
      return Message.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }

  /// Mark conversation as read
  Future<void> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/conversations/$conversationId/mark-read'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark as read: ${response.body}');
    }
  }

  /// Get total unread count for user
  Future<int> getUnreadCount(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/conversations/user/$userId/unread-count'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['totalUnread'] ?? 0;
    } else {
      throw Exception('Failed to get unread count: ${response.body}');
    }
  }
}
```

---

### Step 3: Create Messaging Controller

Create `lib/controller/messaging_controller.dart`:
```dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:luxury_real_estate_flutter_ui_kit/models/conversation_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/models/message_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/services/messaging_service.dart';

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
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  /// Get current user ID from storage
  String? get currentUserId => storage.read('userId');

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
    if (currentUserId == null) return;

    try {
      isLoadingConversations.value = true;
      conversations.value =
          await _messagingService.getUserConversations(currentUserId!);
    } catch (e) {
      print('Error loading conversations: $e');
      Get.snackbar('Erreur', 'Impossible de charger les conversations');
    } finally {
      isLoadingConversations.value = false;
    }
  }

  /// Create or open conversation
  Future<Conversation?> createConversation({
    required String propertyId,
    String? initialMessage,
  }) async {
    if (currentUserId == null) return null;

    try {
      final conversation = await _messagingService.createConversation(
        bienImmoId: propertyId,
        buyerId: currentUserId!,
        initialMessage: initialMessage,
      );

      // Refresh conversations list
      await loadConversations();

      return conversation;
    } catch (e) {
      print('Error creating conversation: $e');
      Get.snackbar('Erreur', 'Impossible de démarrer la conversation');
      return null;
    }
  }

  /// Load messages for a conversation
  Future<void> loadMessages(String conversationId) async {
    try {
      isLoadingMessages.value = true;
      currentConversationId.value = conversationId;
      messages.value = await _messagingService.getMessages(conversationId);

      // Mark as read
      if (currentUserId != null) {
        await _messagingService.markConversationAsRead(
          conversationId: conversationId,
          userId: currentUserId!,
        );
        // Refresh unread count
        await refreshUnreadCount();
      }
    } catch (e) {
      print('Error loading messages: $e');
      Get.snackbar('Erreur', 'Impossible de charger les messages');
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
        // Mark as read
        await _messagingService.markConversationAsRead(
          conversationId: conversationId,
          userId: currentUserId!,
        );
      }
    } catch (e) {
      print('Error refreshing messages: $e');
    }
  }

  /// Send a message
  Future<void> sendMessage(String content) async {
    if (currentUserId == null || currentConversationId.value.isEmpty) return;
    if (content.trim().isEmpty) return;

    try {
      final message = await _messagingService.sendMessage(
        conversationId: currentConversationId.value,
        senderId: currentUserId!,
        content: content.trim(),
      );

      // Add message to list
      messages.add(message);

      // Refresh conversations to update last message
      await loadConversations();
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar('Erreur', 'Impossible d\\'envoyer le message');
    }
  }

  /// Refresh unread count
  Future<void> refreshUnreadCount() async {
    if (currentUserId == null) return;

    try {
      totalUnreadCount.value =
          await _messagingService.getUnreadCount(currentUserId!);
    } catch (e) {
      print('Error refreshing unread count: $e');
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
```

---

### Step 4: Create Conversations List View

Create `lib/views/messages/conversations_list_view.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/common/cached_network_image_widget.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/messaging_controller.dart';
import 'package:luxury_real_estate_flutter_ui_kit/routes/app_routes.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsListView extends StatelessWidget {
  ConversationsListView({super.key});

  final MessagingController controller = Get.put(MessagingController());

  @override
  Widget build(BuildContext context) {
    controller.loadConversations();

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        title: Text('Messages', style: AppStyle.heading3SemiBold(color: AppColor.textColor)),
        backgroundColor: AppColor.whiteColor,
      ),
      body: Obx(() {
        if (controller.isLoadingConversations.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: AppColor.descriptionColor),
                SizedBox(height: 16),
                Text('Aucune conversation', style: AppStyle.heading4Medium(color: AppColor.textColor)),
                Text('Commencez par contacter un propriétaire',
                     style: AppStyle.heading6Regular(color: AppColor.descriptionColor)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.conversations.length,
          itemBuilder: (context, index) {
            final conversation = controller.conversations[index];
            final property = conversation.bienImmo;
            final unreadCount = controller.getConversationUnreadCount(conversation);

            return ListTile(
              leading: Container(
                width: 56,
                height: 56,
                child: PropertyImageWidget(
                  imageUrl: property?.listeImages?.isNotEmpty == true
                      ? '${ApiConfig.baseUrl}/${property!.listeImages!.first}'
                      : null,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              title: Text(
                property?.description?.titre ?? 'Propriété',
                style: AppStyle.heading5SemiBold(color: AppColor.textColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                conversation.lastMessagePreview ?? '',
                style: AppStyle.heading6Regular(color: AppColor.descriptionColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeago.format(conversation.lastMessageAt, locale: 'fr'),
                    style: AppStyle.heading7Regular(color: AppColor.descriptionColor),
                  ),
                  if (unreadCount > 0) ...[
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              onTap: () {
                Get.toNamed(AppRoutes.chatView, arguments: conversation.id);
              },
            );
          },
        );
      }),
    );
  }
}
```

---

### Step 5: Create Chat View

Create `lib/views/messages/chat_view.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_color.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_size.dart';
import 'package:luxury_real_estate_flutter_ui_kit/configs/app_style.dart';
import 'package:luxury_real_estate_flutter_ui_kit/controller/messaging_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatView extends StatelessWidget {
  ChatView({super.key});

  final MessagingController controller = Get.find<MessagingController>();
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final String conversationId = Get.arguments as String;
    controller.loadMessages(conversationId);

    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      appBar: AppBar(
        title: Text('Chat', style: AppStyle.heading4SemiBold(color: AppColor.textColor)),
        backgroundColor: AppColor.whiteColor,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              if (controller.isLoadingMessages.value) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return Center(child: Text('Aucun message'));
              }

              // Auto-scroll to bottom
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  scrollController.jumpTo(scrollController.position.maxScrollExtent);
                }
              });

              return ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  final isMe = message.senderId == controller.currentUserId;
                  final sender = message.sender;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: isMe ? AppColor.primaryColor : AppColor.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe && sender != null)
                            Text(
                              sender.fullName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          SizedBox(height: 4),
                          Text(
                            message.content,
                            style: TextStyle(color: isMe ? Colors.white : AppColor.textColor),
                          ),
                          SizedBox(height: 4),
                          Text(
                            timeago.format(message.timestamp, locale: 'fr'),
                            style: TextStyle(
                              fontSize: 10,
                              color: isMe ? Colors.white70 : AppColor.descriptionColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Message input
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Écrivez un message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: AppColor.borderColor),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (messageController.text.trim().isNotEmpty) {
                      controller.sendMessage(messageController.text);
                      messageController.clear();
                    }
                  },
                  icon: Icon(Icons.send, color: AppColor.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### Step 6: Add "Contact Owner" Button to Property Details

In `lib/views/post_property/show_property_details_view.dart`, update the contact button:

```dart
// In _buildContactOwnerSection()
CommonButton(
  onPressed: () async {
    // Get current user ID
    final userId = storage.read('userId');
    if (userId == null) {
      Get.snackbar('Erreur', 'Veuillez vous connecter');
      return;
    }

    // Get property ID
    final propertyId = Get.arguments as String?;
    if (propertyId == null) return;

    // Create controller
    final messagingController = Get.put(MessagingController());

    // Create or get conversation
    final conversation = await messagingController.createConversation(
      propertyId: propertyId,
      initialMessage: 'Bonjour, je suis intéressé par ce bien.',
    );

    if (conversation != null) {
      // Navigate to chat
      Get.toNamed(AppRoutes.chatView, arguments: conversation.id);
    }
  },
  backgroundColor: AppColor.primaryColor,
  child: Text(
    'Contacter le propriétaire',
    style: AppStyle.heading5Medium(color: AppColor.whiteColor),
  ),
),
```

---

### Step 7: Add Unread Badge to Bottom Navigation

In your bottom navigation bar, add an unread badge:

```dart
final MessagingController messagingController = Get.put(MessagingController());

// In your bottom bar items
BottomNavigationBarItem(
  icon: Obx(() {
    final unreadCount = messagingController.totalUnreadCount.value;
    return Stack(
      children: [
        Icon(Icons.chat_bubble_outline),
        if (unreadCount > 0)
          Positioned(
            right: 0,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unreadCount',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
      ],
    );
  }),
  label: 'Messages',
),
```

---

### Step 8: Add Routes

In `lib/routes/app_routes.dart`:
```dart
static const String conversationsListView = '/conversations';
static const String chatView = '/chat';
```

In your route configuration:
```dart
GetPage(name: AppRoutes.conversationsListView, page: () => ConversationsListView()),
GetPage(name: AppRoutes.chatView, page: () => ChatView()),
```

---

### Step 9: Add Dependencies

Add to `pubspec.yaml`:
```yaml
dependencies:
  timeago: ^3.6.1  # For relative timestamps (e.g., "2 minutes ago")
```

---

## 🎯 Features Implemented

✅ **Conversation List**
- Shows all user's conversations
- Property image and title
- Last message preview
- Unread count badge
- Relative timestamps ("2 minutes ago")

✅ **Chat View**
- Real-time-like messaging with polling (every 20 seconds)
- Message bubbles (different colors for sender/receiver)
- Sender names
- Timestamps
- Auto-scroll to bottom
- Auto mark-as-read when opening chat

✅ **Property Integration**
- "Contact Owner" button on property details
- Creates conversation with initial message
- Opens chat directly

✅ **Unread Notifications**
- Badge on bottom navigation
- Badge on each conversation
- Auto-updates via polling

---

## 📱 User Flow

1. User views property → Clicks "Contacter le propriétaire"
2. App creates conversation (or opens existing)
3. User is taken to chat view
4. User sends messages
5. Messages appear in real-time (20s polling)
6. Owner receives notification (future: email/SMS)
7. Both parties can chat back and forth
8. Unread count updates automatically

---

## 🔄 Polling Strategy

Messages refresh every 20 seconds when:
- User is on conversations list
- User is in a chat view
- App checks for new messages and unread count

This provides a near-real-time experience without WebSockets!

---

## 🚀 Next Steps

1. **Test on mobile** - Run the app and test messaging
2. **Add email notifications** - Send email when user receives message
3. **Add SMS notifications** - Optional for urgent messages
4. **Image attachments** - Allow sending photos
5. **WebSocket upgrade** - For true real-time (optional)

---

## 📞 Support

- Backend documentation: `MESSAGING_API_DOCUMENTATION.md`
- Backend server: `http://192.168.1.4:3000`
- API Explorer: `http://192.168.1.4:3000/explorer`
