import 'package:flutter/foundation.dart';

import 'package:utm_marketplace/item_listing/model/listing.model.dart';
import 'package:utm_marketplace/item_listing/repository/listing_repo.dart';

import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class ListingViewModel extends LoadingViewModel {
  ListingViewModel({
    required this.repo,
  });

  final ListingRepo repo;

  ListingModel get listingModel => _listingModel;

  set listingModel(ListingModel listingModel) {
    _listingModel = listingModel;
    notifyListeners();
  }

  Future<void> fetchData() async {
    try {
      isLoading = true;

      _listingModel = await repo.fetchData();
    } catch (exc) {
      debugPrint('Error in _fetchData : ${exc.toString()}');
    }

    isLoading = false;
    notifyListeners();
  }

  ListingModel _listingModel = ListingModel();
}