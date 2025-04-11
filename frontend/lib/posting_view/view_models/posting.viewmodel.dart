import 'package:flutter/foundation.dart';

import 'package:utm_marketplace/posting_view/model/posting.model.dart';
import 'package:utm_marketplace/posting_view/repository/posting.repository.dart';
import 'package:utm_marketplace/saved_items/repository/saved_items.repository.dart';

import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class PostingViewModel extends LoadingViewModel {
  PostingViewModel({
    required this.repo,
    required this.savedItemsRepo,
  });

  final PostingRepository repo;
  final SavedItemsRepository savedItemsRepo;
  final Set<String> _savedItemIds = {};

  bool isSavedItem(String itemId) => _savedItemIds.contains(itemId);

  Future<void> toggleSaved(String itemId) async {
    if (_savedItemIds.contains(itemId)) {
      final success = await savedItemsRepo.unsaveItem(itemId);
      if (success) {
        _savedItemIds.remove(itemId);
        notifyListeners();
      }
    } else {
      final success = await savedItemsRepo.saveItem(itemId);
      if (success) {
        _savedItemIds.add(itemId);
        notifyListeners();
      }
    }
  }

  PostingModel _postingModel = PostingModel();

  Item? _item;
  Item? get item => _item;
  set item(Item? value) {
    _item = value;
    notifyListeners();
  }

  Future<void> fetchData(String itemid) async {
    try {
      isLoading = true;

      _postingModel = await repo.fetchData(itemid);
      item = _postingModel.item;

      // Check if this item is saved
      try {
        final savedItems = await savedItemsRepo.fetchData();
        _savedItemIds.clear();
        for (var savedItem in savedItems.items) {
          _savedItemIds.add(savedItem.id);
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error fetching saved items: ${e.toString()}');
      }
    } catch (exc) {
      debugPrint('Error in fetchData : ${exc.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
