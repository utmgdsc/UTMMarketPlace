import 'package:flutter/material.dart';
import 'package:utm_marketplace/messages/model/message.model.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';

class MessageRepository {
  Future<MessageModel> fetchConversations(String userId) async {
    try {
      final response =
          await dio.get('/conversations', queryParameters: {'userid': userId});

      debugPrint('Response: ${response.data}');
      if (response.statusCode == 200) {
        final conversations = await Future.wait(
          (response.data['conversations'] as List).map((conv) async {
            final messages = await fetchConversation(conv['conversation_id']);
            return Conversation(
              id: conv['conversation_id'],
              userId: userId,
              userName: conv['other_user_name'],
              userImageUrl: conv['other_user_profile_picture'],
              messages: messages,
              lastMessageTime: DateTime.parse(conv['last_timestamp']),
            );
          }),
        );
        return MessageModel(conversations: conversations);
      } else {
        throw Exception('Failed to fetch conversations');
      }
    } catch (e) {
      throw Exception('Failed to fetch conversations: $e');
    }
  }

  Future<List<Message>> fetchConversation(String conversationId) async {
    try {
      final response = await dio.get('/messages',
          queryParameters: {'conversation_id': conversationId});

      debugPrint('Response: ${response.data}');
      if (response.statusCode == 200) {
        final messages = (response.data['messages'] as List)
            .map((msg) => Message.fromJson(msg))
            .toList();
        return messages;
      } else {
        throw Exception('Failed to fetch messages');
      }
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  Future<bool> sendMessage(String conversationId, String content) async {
    try {
      final response = await dio.post(
        '/messages',
        data: {
          'conversation_id': conversationId,
          'content': content,
        },
      );

      debugPrint('Response: ${response.data}');
      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
