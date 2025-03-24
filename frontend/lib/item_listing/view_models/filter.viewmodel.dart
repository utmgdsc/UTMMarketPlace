import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/item_listing/model/filter_options.model.dart';
import 'package:utm_marketplace/item_listing/view_models/listing.viewmodel.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class FilterViewModel extends LoadingViewModel {
  SortOrder? _sortOrder;
  DateTime? _dateFrom;
  String? _condition;
  double? _minPrice;
  double? _maxPrice;

  SortOrder? get sortOrder => _sortOrder;
  DateTime? get dateFrom => _dateFrom;
  String? get condition => _condition;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

  void setSortOrder(SortOrder? value) {
    _sortOrder = value;
    notifyListeners();
  }

  void setDateFrom(DateTime? value) {
    _dateFrom = value;
    notifyListeners();
  }

  void setCondition(String? value) {
    _condition = value;
    notifyListeners();
  }

  void setMinPrice(double? value) {
    _minPrice = value;
    notifyListeners();
  }

  void setMaxPrice(double? value) {
    _maxPrice = value;
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
      setDateFrom(picked);
    }
  }

  void clearFilters() {
    _sortOrder = null;
    _dateFrom = null;
    _condition = null;
    _minPrice = null;
    _maxPrice = null;
    notifyListeners();
  }

  void applyFilters(BuildContext context) {
    final listingViewModel = Provider.of<ListingViewModel>(context, listen: false);
    final filters = FilterOptions(
      sortOrder: _sortOrder,
      dateFrom: _dateFrom,
      condition: _condition,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    );
    listingViewModel.applyFilters(filters);
  }
}