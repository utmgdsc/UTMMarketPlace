import 'package:utm_marketplace/messages/model/message.model.dart';

class MessageRepository {
  Future<MessageModel> fetchData() async {
    // Temporary placeholder data
    await Future.delayed(const Duration(seconds: 1));
    return MessageModel();
  }
}