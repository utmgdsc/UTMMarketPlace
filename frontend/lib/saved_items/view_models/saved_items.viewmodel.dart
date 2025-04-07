import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/saved_items/repository/saved_items.repository.dart';
import 'package:utm_marketplace/shared/models/listing_item.model.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class SavedItemsViewModel extends LoadingViewModel {
  final SavedItemsRepository repo;

  SavedItemsViewModel({required this.repo});

  List<ListingItem> _items = [];
  List<ListingItem> get items => _items;
  
  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  Future<void> fetchData() async {
    try {
      _errorMessage = '';
      isLoading = true;
      notifyListeners();
      
      debugPrint('SavedItemsViewModel: Fetching saved items...');
      final model = await repo.fetchData();
      
      debugPrint('SavedItemsViewModel: Received ${model.items.length} saved items');
      _items = model.items;
    } catch (e) {
      _errorMessage = 'Failed to load saved items: $e';
      debugPrint('Error in fetchData: ${e.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveItem(String itemId) async {
    try {
      debugPrint('SavedItemsViewModel: Saving item $itemId...');
      final result = await repo.saveItem(itemId);
      
      if (result) {
        debugPrint('SavedItemsViewModel: Item saved successfully, refreshing list');
        await fetchData(); // Refresh the list after saving
      } else {
        debugPrint('SavedItemsViewModel: Failed to save item');
      }
      
      return result;
    } catch (e) {
      debugPrint('Error in saveItem: ${e.toString()}');
      return false;
    }
  }

  Future<bool> unsaveItem(String itemId) async {
    try {
      debugPrint('SavedItemsViewModel: Removing item $itemId...');
      final result = await repo.unsaveItem(itemId);
      
      if (result) {
        debugPrint('SavedItemsViewModel: Item removed successfully');
        // Remove the item from the local list without fetching again
        _items.removeWhere((item) => item.id == itemId);
        notifyListeners();
      } else {
        debugPrint('SavedItemsViewModel: Failed to remove item');
      }
      
      return result;
    } catch (e) {
      debugPrint('Error in unsaveItem: ${e.toString()}');
      return false;
    }
  }
}
