import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:utm_marketplace/messages/model/message.model.dart';

class MessageRepository {
  Future<MessageModel> fetchData() async {
    await Future.delayed(const Duration(seconds: 1));

    final jsonString = await rootBundle.loadString('assets/data/messages.json');
    final jsonData = json.decode(jsonString);
    return MessageModel.fromJson(jsonData);
  }

  Future<Conversation> fetchConversation(String conversationId) async {
    await Future.delayed(const Duration(seconds: 1));

    final jsonString = await rootBundle.loadString('assets/data/messages.json');
    final jsonData = json.decode(jsonString);

    final conversations = (jsonData['conversations'] as List)
        .map((conv) => Conversation.fromJson(conv))
        .toList();

    return conversations.firstWhere((conv) => conv.id == conversationId);
  }

  Future<bool> sendMessage(String conversationId, String content) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
