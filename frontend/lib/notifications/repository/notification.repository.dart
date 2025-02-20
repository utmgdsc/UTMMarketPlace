import 'package:utm_marketplace/notifications/model/notification.model.dart';

class NotificationRepository {
  Future<NotificationModel> fetchData() async {
    // Temporary placeholder data
    await Future.delayed(const Duration(seconds: 1));
    return NotificationModel();
  }
}
