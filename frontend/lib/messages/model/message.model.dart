import 'package:flutter/material.dart';

class MessageModel {
  final List<Conversation> conversations;

  MessageModel({this.conversations = const []});

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      conversations: (json['conversations'] as List?)
              ?.map(
                  (conv) => Conversation.fromJson(conv as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Conversation {
  final String id;
  final String userId;
  final String userName;
  final String userImageUrl;
  List<Message> messages;
  final DateTime lastMessageTime;
  final bool isUnread;

  Conversation({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    required this.messages,
    required this.lastMessageTime,
    this.isUnread = false,
  });

  String get lastMessagePreview {
    debugPrint('Last message preview: $messages');
    if (messages.isEmpty) return '';
    return messages.last.content.length > 30
        ? '${messages.last.content.substring(0, 30)}...'
        : messages.last.content;
  }

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'],
      userImageUrl: json['user_image_url'],
      messages: (json['messages'] as List?)
              ?.map((msg) => Message.fromJson(msg as Map<String, dynamic>))
              .toList() ??
          [],
      lastMessageTime: DateTime.parse(json['last_message_time']),
      isUnread: json['is_unread'] == true,
    );
  }
}

class Message {
  final String id;
  final String content;
  final DateTime timestamp;
  final String senderId;
  final String recipientId;
  bool isFromCurrentUser;

  Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.senderId,
    required this.recipientId,
    required this.isFromCurrentUser,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['message_id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      senderId: json['sender_id'],
      recipientId: json['recipient_id'],
      isFromCurrentUser: json['is_from_current_user'] == true,
    );
  }
}
