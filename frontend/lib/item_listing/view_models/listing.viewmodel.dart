import 'package:flutter/material.dart';
import 'package:utm_marketplace/item_listing/model/filter_options.model.dart';
import 'package:utm_marketplace/item_listing/model/listing.model.dart';
import 'package:utm_marketplace/item_listing/repository/listing_repo.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';
import 'package:utm_marketplace/item_listing/components/filter_bottom_sheet/filter_bottom_sheet.component.dart';

class ListingViewModel extends LoadingViewModel {
  ListingViewModel({
    required this.repo,
  });

  final ListingRepo repo;
  List<Item> _allItems = [];
  List<Item> _filteredItems = [];

  List<Item> get items => _filteredItems;

  Future<void> fetchData() async {
    try {
      isLoading = true;
      final model = await repo.fetchData();
      _allItems = model.items;
      _filteredItems = _allItems;
      notifyListeners();
    } catch (exc) {
      debugPrint('Error in fetchData : ${exc.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void applyFilters(FilterOptions filters) {
    _filteredItems = List.from(_allItems);

    if (filters.condition != null) {
      _filteredItems = _filteredItems
          .where((item) => item.condition == filters.condition)
          .toList();
    }

    if (filters.campus != null) {
      _filteredItems = _filteredItems
          .where((item) => item.campus == filters.campus)
          .toList();
    }

    if (filters.minPrice != null) {
      _filteredItems = _filteredItems
          .where((item) => item.price >= filters.minPrice!)
          .toList();
    }

    if (filters.maxPrice != null) {
      _filteredItems = _filteredItems
          .where((item) => item.price <= filters.maxPrice!)
          .toList();
    }

    if (filters.dateFrom != null) {
      _filteredItems = _filteredItems
          .where((item) => item.datePosted?.isAfter(filters.dateFrom!) ?? false)
          .toList();
    }

    if (filters.sortOrder != null) {
      switch (filters.sortOrder) {
        case SortOrder.priceLowToHigh:
          _filteredItems.sort((a, b) => a.price.compareTo(b.price));
          break;
        case SortOrder.priceHighToLow:
          _filteredItems.sort((a, b) => b.price.compareTo(a.price));
          break;
        case SortOrder.dateRecent:
          _filteredItems.sort((a, b) => (b.datePosted ?? DateTime.now())
              .compareTo(a.datePosted ?? DateTime.now()));
          break;
        default:
          break;
      }
    }

    notifyListeners();
  }

  void showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: const FilterBottomSheet(),
        ),
      ),
    );
  }
}
