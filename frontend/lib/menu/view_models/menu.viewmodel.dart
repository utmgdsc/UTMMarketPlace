import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/menu/model/menu.model.dart';
import 'package:utm_marketplace/menu/repository/menu.repository.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class MenuViewModel extends LoadingViewModel {
  final MenuRepository repo;

  MenuViewModel({required this.repo});

  MenuModel _menuModel = MenuModel();
  MenuModel get menu => _menuModel;

  Future<void> fetchData() async {
    try {
      isLoading = true;
      _menuModel = await repo.fetchData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error in fetchData: ${e.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
