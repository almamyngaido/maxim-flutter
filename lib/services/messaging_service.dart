import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luxury_real_estate_flutter_ui_kit/configs/api_config.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/conversation_model.dart';
import 'package:luxury_real_estate_flutter_ui_kit/model/message_model.dart';

class MessagingService {
  String get baseUrl => ApiConfig.baseUrl;

  /// Create or get existing conversation
  Future<Conversation> createConversation({
    required String bienImmoId,
    required String buyerId,
    String? initialMessage,
  }) async {
    try {
      print('📤 Creating conversation for property: $bienImmoId, buyer: $buyerId');

      final response = await http.post(
        Uri.parse('$baseUrl/conversations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'bienImmoId': bienImmoId,
          'buyerId': buyerId,
          if (initialMessage != null) 'initialMessage': initialMessage,
        }),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return Conversation.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create conversation: ${response.body}');
      }
    } catch (e) {
      print('❌ Error creating conversation: $e');
      rethrow;
    }
  }

  /// Get user's conversations
  Future<List<Conversation>> getUserConversations(String userId) async {
    try {
      print('📤 Getting conversations for user: $userId');

      final response = await http.get(
        Uri.parse('$baseUrl/conversations/user/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print('✅ Found ${data.length} conversations');
        return data.map((json) => Conversation.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get conversations: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting conversations: $e');
      rethrow;
    }
  }

  /// Get messages in a conversation
  Future<List<Message>> getMessages(String conversationId) async {
    try {
      print('📤 Getting messages for conversation: $conversationId');

      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$conversationId/messages'),
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print('✅ Found ${data.length} messages');
        return data.map((json) => Message.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get messages: ${response.body}');
      }
    } catch (e) {
      print('❌ Error getting messages: $e');
      rethrow;
    }
  }

  /// Send a message
  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    try {
      print('📤 Sending message in conversation: $conversationId');

      final response = await http.post(
        Uri.parse('$baseUrl/messages'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'conversationId': conversationId,
          'senderId': senderId,
          'content': content,
        }),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Message sent successfully');
        return Message.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending message: $e');
      rethrow;
    }
  }

  /// Mark conversation as read
  Future<void> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      print('📤 Marking conversation as read: $conversationId');

      final response = await http.patch(
        Uri.parse('$baseUrl/conversations/$conversationId/mark-read'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
        }),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ Conversation marked as read');
      } else {
        throw Exception('Failed to mark as read: ${response.body}');
      }
    } catch (e) {
      print('❌ Error marking as read: $e');
      rethrow;
    }
  }

  /// Get total unread count for user
  Future<int> getUnreadCount(String userId) async {
    try {
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
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0; // Return 0 on error instead of throwing
    }
  }
}
