import 'package:utm_marketplace/menu/model/menu.model.dart';

class MenuRepository {
  Future<MenuModel> fetchData() async {
    // Simulating API call with delay
    await Future.delayed(const Duration(seconds: 1));
    return MenuModel();
  }
}