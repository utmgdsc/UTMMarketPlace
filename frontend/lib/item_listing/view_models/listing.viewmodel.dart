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
    _filteredItems = _allItems.where((item) {
      if (filters.condition != null && item.condition != filters.condition) {
        return false;
      }
      if (filters.campus != null && item.campus != filters.campus) {
        return false;
      }
      if (filters.minPrice != null && item.price < filters.minPrice!) {
        return false;
      }
      if (filters.maxPrice != null && item.price > filters.maxPrice!) {
        return false;
      }
      if (filters.dateFrom != null && 
          (item.datePosted == null || item.datePosted!.isBefore(filters.dateFrom!))) {
        return false;
      }
      return true;
    }).toList();

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
