import 'package:flutter/material.dart';
import 'package:utm_marketplace/item_listing/model/filter_options.model.dart';
import 'package:utm_marketplace/item_listing/model/listing.model.dart';
import 'package:utm_marketplace/item_listing/repository/listing_repo.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';
import 'package:utm_marketplace/item_listing/components/filter_bottom_sheet/filter_bottom_sheet.component.dart';

class ListingViewModel extends LoadingViewModel {
  final ListingRepo repo;

  ListingViewModel({
    required this.repo,
  });

  List<Item> _allItems = [];
  List<Item> _filteredItems = [];
  ListingModel? _listingModel;

  List<Item> get items => _filteredItems;

  bool isLoadingMore = false;

  Future<void> searchForRelevantListings(String searchQuery) async {
    // TODO: implement
  }

  /// Handler to load initial listings from backend.
  Future<void> fetchInitialListings(
      {int limit = 5, String? nextPageToken, String? query}) async {
    try {
      isLoading = true;

      final response = await repo.fetchData(
          limit: limit, nextPageToken: nextPageToken, query: query);
      _listingModel = ListingModel.fromJson(response);
      _allItems = _listingModel!.items;
      _filteredItems = _allItems;
      debugPrint('Fetched ${_filteredItems.length} items');
      debugPrint('Items: ${_filteredItems.map((item) => item.title).toList()}');
      notifyListeners();
    } catch (exc) {
      debugPrint('Error in fetchData : ${exc.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Handler to load more listings from the backend. This is used to paginate the listings.
  Future<void> fetchMoreListings({int limit = 5, String? query}) async {
    if (_listingModel?.nextPageToken == null ||
        _listingModel!.nextPageToken!.isEmpty) {
      return;
    }

    try {
      isLoadingMore = true;

      final response = await repo.fetchData(
          limit: limit,
          nextPageToken: _listingModel!.nextPageToken,
          query: query);
      final newListingModel = ListingModel.fromJson(response);
      _listingModel = newListingModel;
      _allItems.addAll(newListingModel.items);
      _filteredItems = _allItems;
      notifyListeners();
    } catch (exc) {
      debugPrint('Error in fetchMoreData : ${exc.toString()}');
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  void setFilters(FilterOptions filters) {
    _filteredItems = _allItems.where((item) {
      if (filters.condition != null && item.condition != filters.condition) {
        return false;
      }
      if (filters.campus != null && item.campus != filters.campus) {
        return false;
      }
      if (filters.lowerPrice != null && item.price < filters.lowerPrice!) {
        return false;
      }
      if (filters.upperPrice != null && item.price > filters.upperPrice!) {
        return false;
      }
      if (filters.dateRange != null &&
          (item.datePosted == null ||
              item.datePosted!.isBefore(filters.dateRange!))) {
        return false;
      }
      return true;
    }).toList();

    final sortType = filters.priceType ?? 'date-recent';
    switch (sortType) {
      case 'price-low-to-high':
        _filteredItems.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price-high-to-low':
        _filteredItems.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'date-recent':
        _filteredItems.sort((a, b) => (b.datePosted ?? DateTime.now())
            .compareTo(a.datePosted ?? DateTime.now()));
        break;
    }

    notifyListeners();
  } 
}
