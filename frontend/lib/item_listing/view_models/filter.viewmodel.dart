import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/item_listing/model/filter_options.model.dart';
import 'package:utm_marketplace/item_listing/view_models/listing.viewmodel.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class FilterViewModel extends LoadingViewModel {
  SortOrder? _sortOrder;
  DateTime? _dateRange;
  String? _condition;
  double? _lowerPrice;
  double? _upperPrice;
  String? _campus;

  SortOrder? get sortOrder => _sortOrder;
  DateTime? get dateRange => _dateRange;
  String? get condition => _condition;
  double? get lowerPrice => _lowerPrice;
  double? get upperPrice => _upperPrice;
  String? get campus => _campus;

  void setSortOrder(SortOrder? value) {
    _sortOrder = value;
    notifyListeners();
  }

  void setDateRange(DateTime? value) {
    _dateRange = value;
    notifyListeners();
  }

  void setCondition(String? value) {
    _condition = value;
    notifyListeners();
  }

  void setLowerPrice(double? value) {
    _lowerPrice = value;
    notifyListeners();
  }

  void setUpperPrice(double? value) {
    _upperPrice = value;
    notifyListeners();
  }

  void setCampus(String? value) {
    _campus = value;
    notifyListeners();
  }

  Future<void> openDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setDateRange(picked);
    }
  }

  void clearFilters() {
    _sortOrder = null;
    _dateRange = null;
    _condition = null;
    _lowerPrice = null;
    _upperPrice = null;
    _campus = null;
    notifyListeners();
  }

  void applyFilters(BuildContext context) {
    final listingViewModel =
        Provider.of<ListingViewModel>(context, listen: false);
    final filters = FilterOptions(
      priceType: FilterOptions.sortOrderToPriceType(_sortOrder),
      dateRange: _dateRange,
      condition: _condition,
      lowerPrice: _lowerPrice,
      upperPrice: _upperPrice,
      campus: _campus,
    );
    listingViewModel.setFiltersAndGetResults(filters);
  }
}
