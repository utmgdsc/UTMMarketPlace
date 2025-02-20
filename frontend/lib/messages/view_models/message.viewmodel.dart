import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/messages/model/message.model.dart';
import 'package:utm_marketplace/messages/repository/message.repository.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class MessageViewModel extends LoadingViewModel {
  final MessageRepository repo;

  MessageViewModel({required this.repo});

  MessageModel _messageModel = MessageModel();
  MessageModel get messages => _messageModel;

  Future<void> fetchData() async {
    try {
      isLoading = true;
      _messageModel = await repo.fetchData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error in fetchData: ${e.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}