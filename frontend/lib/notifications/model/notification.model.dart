class NotificationModel {
  final List<Notification> notifications;

  NotificationModel({this.notifications = const []});
}

class Notification {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  Notification({
    required this.id,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });
}