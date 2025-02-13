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

  Future<void> fetchData() async {
    try {
      isLoading = true;

      _listingModel = await repo.fetchData();
      items = _listingModel.items;
    } catch (exc) {
      debugPrint('Error in fetchData : ${exc.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
