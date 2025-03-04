import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/messages/model/message.model.dart';
import 'package:utm_marketplace/messages/repository/message.repository.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class MessageViewModel extends LoadingViewModel {
  final MessageRepository repo;

  MessageViewModel({required this.repo});

  MessageModel _messageModel = MessageModel();
  MessageModel get messages => _messageModel;
  
  List<Conversation> _sortedConversations = [];
  List<Conversation> get sortedConversations => _sortedConversations;

  Conversation? _currentConversation;
  Conversation? get currentConversation => _currentConversation;

  String _messageText = '';
  String get messageText => _messageText;
  
  set messageText(String value) {
    _messageText = value;
    notifyListeners();
  }

  Future<void> fetchData() async {
    try {
      isLoading = true;
      _messageModel = await repo.fetchData();
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

  Future<void> fetchConversation(String conversationId) async {
    try {
      isLoading = true;
      _currentConversation = await repo.fetchConversation(conversationId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error in fetchConversation: ${e.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage() async {
    if (_messageText.trim().isEmpty || _currentConversation == null) {
      return false;
    }

    try {
      final success = await repo.sendMessage(
        _currentConversation!.id,
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
}