import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:utm_marketplace/messages/model/message.model.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';
import 'package:utm_marketplace/shared/secure_storage/secure_storage.dart';

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

      final token = await secureStorage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('User is not authenticated');
      }

      final userId = _getUserIdFromToken(token);

      debugPrint('Response: ${response.data}');
      if (response.statusCode == 200) {
        final messages = (response.data['messages'] as List).map((msg) {
          final message = Message.fromJson(msg);
          message.isFromCurrentUser = message.senderId == userId;
          return message;
        }).toList();
        return messages;
      } else {
        throw Exception('Failed to fetch messages');
      }
    } catch (e) {
      throw Exception('Failed to fetch messages: $e');
    }
  }

  Future<bool> sendMessage(String recipientId, String content) async {
    try {
      final response = await dio.post(
        '/messages',
        data: {
          'recipient_id': recipientId,
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

  String _getUserIdFromToken(String token) {
    // Decode JWT token (format: header.payload.signature)
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token format');
    }

    // Decode the payload (middle part)
    String normalizedPayload = base64Url.normalize(parts[1]);
    final payloadMap =
        json.decode(utf8.decode(base64Url.decode(normalizedPayload)));
    final userId = payloadMap['id'];

    if (userId == null) {
      throw Exception('User ID not found in token');
    }

    return userId;
  }
}
