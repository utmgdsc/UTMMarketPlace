class MessageModel {
  final List<Message> messages;

  MessageModel({this.messages = const []});
}

class Message {
  final String id;
  final String content;

  Message({
    required this.id,
    required this.content,
  });
}