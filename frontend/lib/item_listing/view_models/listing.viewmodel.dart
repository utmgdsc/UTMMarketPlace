import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/item_listing/model/listing.model.dart';
import 'package:utm_marketplace/item_listing/repository/listing_repo.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class ListingViewModel extends LoadingViewModel {
  ListingViewModel({
    required this.repo,
  });

  final ListingRepo repo;

  ListingModel _listingModel = ListingModel();

  List<Item> _items = [];
  List<Item> get items => _items;
  set items(List<Item> value) {
    _items = value;
    notifyListeners();
  }

  bool isLoadingMore = false;

  Future<void> fetchData({int limit = 5, String? nextPageToken, String? query}) async {
    try {
      isLoading = true;

      final response = await repo.fetchData(limit: limit, nextPageToken: nextPageToken, query: query);
      _listingModel = ListingModel.fromJson(response);
      items = _listingModel.items;
    } catch (exc) {
      debugPrint('Error in fetchData : ${exc.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMoreData({int limit = 5, String? query}) async {
    if (_listingModel.nextPageToken == null || _listingModel.nextPageToken!.isEmpty) {
      return;
    }

    try {
      isLoadingMore = true;

      final response = await repo.fetchData(limit: limit, nextPageToken: _listingModel.nextPageToken, query: query);
      final newListingModel = ListingModel.fromJson(response);
      _listingModel = newListingModel;
      items = [...items, ...newListingModel.items];
    } catch (exc) {
      debugPrint('Error in fetchMoreData : ${exc.toString()}');
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }
}
