import 'package:flutter/material.dart';
import 'package:utm_marketplace/item_listing/model/filter_options.model.dart';
import 'package:utm_marketplace/item_listing/model/listing.model.dart';
import 'package:utm_marketplace/item_listing/repository/listing_repo.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class ListingViewModel extends LoadingViewModel {
  final ListingRepo repo;

  ListingViewModel({
    required this.repo,
  });

  List<Item> _allItems = [];
  String _currentSearchQuery = "";
  FilterOptions? _filterOptionsSelected;
  String nextPageToken = "";

  List<Item> get items => _allItems;

  bool isLoadingMore = false;

  // ========== SETTERS ==============

  /// Set the current filters and restart the search results based on new filters.
  void setFiltersAndGetResults(FilterOptions filters) {
    _filterOptionsSelected = filters;
    searchForRelevantListings().then((_) => notifyListeners());
  }

  /// Set the current search query and restart the search results based on new search query.
  void setSearchQueryAndGetResults(String searchQuery) {
    _currentSearchQuery = searchQuery;
    searchForRelevantListings().then((_) => notifyListeners());
  }

  // ========= SEARCHING AND PAGINATION =========
  /// Searches for relevant listings based on the current search query and filter options.
  ///
  /// Defaults to a limit of 5 results.
  Future<void> searchForRelevantListings({int limit = 5}) async {
    isLoading = true;
    isLoadingMore = false;
    notifyListeners();

    final ListingModel results = await repo.getSearchResults(
      searchQuery: _currentSearchQuery,
      limit: limit,
      filterOptions: _filterOptionsSelected,
    );

    isLoading = false;
    _allItems = results.items;
    nextPageToken = results.nextPageToken ?? "";
    notifyListeners();
  }

  /// Loads more results based on the current search query and filter options.
  ///
  /// Defaults to a limit of 5 (more) results.
  /// If `nextPageToken` is empty, nothing will be done.
  Future<void> loadMoreListingsBasedOnCurrentSearchParams(
      {int limit = 5}) async {
    if (nextPageToken.isEmpty || isLoadingMore) {
      return;
    }

    try {
      isLoading = false;
      isLoadingMore = true;
      notifyListeners();

      final ListingModel results = await repo.getSearchResults(
        searchQuery: _currentSearchQuery,
        nextPageToken: nextPageToken,
        limit: limit,
        filterOptions: _filterOptionsSelected,
      );

      // no need to notify listeners as we are already notifying in `finally`
      _allItems.addAll(results.items);
      nextPageToken = results.nextPageToken ?? "";
    } catch (exc) {
      debugPrint('Error in fetchMoreData : ${exc.toString()}');
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }
}
