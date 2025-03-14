import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/saved_items/repository/saved_items.repository.dart';
import 'package:utm_marketplace/shared/models/listing_item.model.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class SavedItemsViewModel extends LoadingViewModel {
  final SavedItemsRepository repo;

  SavedItemsViewModel({required this.repo});

  List<ListingItem> _items = [];
  List<ListingItem> get items => _items;

  Future<void> fetchData() async {
    try {
      isLoading = true;
      final model = await repo.fetchData();
      _items = model.items;
      notifyListeners();
    } catch (e) {
      debugPrint('Error in fetchData: ${e.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
