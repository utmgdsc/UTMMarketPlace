import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/messages/model/message.model.dart';
import 'package:utm_marketplace/messages/repository/message.repository.dart';
import 'package:utm_marketplace/shared/secure_storage/secure_storage.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class MessageViewModel extends LoadingViewModel {
  final MessageRepository repo;

  MessageViewModel({required this.repo});

  MessageModel _messageModel = MessageModel();
  MessageModel get messages => _messageModel;

  List<Conversation> _sortedConversations = [];
  List<Conversation> get sortedConversations => _sortedConversations;

  List<Message>? _currentConversation;
  List<Message>? get currentConversation => _currentConversation;

  String _messageText = '';
  String get messageText => _messageText;

  set messageText(String value) {
    _messageText = value;
    notifyListeners();
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

  Future<void> fetchData() async {
    try {
      final token = await secureStorage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('User is not authenticated');
      }

      final targetUserId = _getUserIdFromToken(token);

      isLoading = true;
      _messageModel = await repo.fetchConversations(targetUserId);
      _sortConversations();
      notifyListeners();
    } catch (e) {
      debugPrint('Error in fetchData: ${e.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _sortConversations() {
    _sortedConversations = List<Conversation>.from(_messageModel.conversations)
      ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
  }

  Future<void> fetchConversation(String conversationId, bool pauseLoad) async {
    try {
      if (!pauseLoad) {
        isLoading = true;
      }
      _currentConversation =
          await repo.fetchConversation(conversationId) as List<Message>?;
      notifyListeners();
    } catch (e) {
      debugPrint(
          'Error in fetchConversation: ${e.toString()} conversationId: $conversationId');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String recipientId) async {
    if (_messageText.trim().isEmpty) {
      return false;
    }

    debugPrint('Sending message: $_messageText to recipient: $recipientId');

    try {
      final success = await repo.sendMessage(
        recipientId,
        _messageText.trim(),
      );

      if (success) {
        _messageText = '';
        notifyListeners();
      }

      return success;
    } catch (e) {
      debugPrint('Error in sendMessage: ${e.toString()}');
      return false;
    }
  }

  String getRecipientId(Conversation conversation) {
    final userId = conversation.userId;
    final parts = conversation.id.split('_');
    final recipientId = parts.first == userId ? parts.last : parts.first;
    debugPrint(
        'Recipient ID: $recipientId, User ID: $userId, Conversation ID: ${conversation.id}');
    return recipientId;
  }

  // Future<bool> sendMessage() async {
  // if (_messageText.trim().isEmpty || _currentConversation == null) {
  //   debugPrint('Message text is empty or no current conversation selected.');
  //   return false;
  // }

  // try {
  //   // Find the conversation ID
  //   debugPrint('Current conversation: $_currentConversation');
  //   debugPrint('Sorted conversations: $_sortedConversations');
  //   final conversation = _sortedConversations.firstWhere(
  //     (conv) => conv.messages.map((msg) => msg.id).toSet().containsAll(
  //       _currentConversation!.map((msg) => msg.id),
  //       ),
  //     orElse: () {
  //     debugPrint('No matching conversation found for the current messages.');
  //     return Conversation(
  //       id: '',
  //       messages: [],
  //       lastMessageTime: DateTime.now(),
  //       userId: '',
  //       userName: '',
  //       userImageUrl: '',
  //     );
  //     },
  //   );

  //   final conversationId = conversation.id;

  //   // Send the message
  //   final success = await repo.sendMessage(
  //     conversationId,
  //     _messageText.trim(),
  //   );

  //   if (success) {
  //     _messageText = '';
  //     notifyListeners();
  //   }

  //   return success;
  // } catch (e) {
  //   debugPrint('Error in sendMessage: ${e.toString()}');
  //   return false;
  // }
  // }
}
