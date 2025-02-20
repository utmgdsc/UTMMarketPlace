import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/notifications/model/notification.model.dart';
import 'package:utm_marketplace/notifications/repository/notification.repository.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class NotificationViewModel extends LoadingViewModel {
  final NotificationRepository repo;

  NotificationViewModel({required this.repo});

  NotificationModel _notificationModel = NotificationModel();
  NotificationModel get notifications => _notificationModel;

  Future<void> fetchData() async {
    try {
      isLoading = true;
      _notificationModel = await repo.fetchData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error in fetchData: ${e.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
