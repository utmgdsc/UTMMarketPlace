enum SortOrder {
  priceLowToHigh,
  priceHighToLow,
  dateRecent
}

class FilterOptions {
  final SortOrder? sortOrder;
  final DateTime? dateFrom;
  final String? condition;
  final double? minPrice;
  final double? maxPrice;

  FilterOptions({
    this.sortOrder,
    this.dateFrom,
    this.condition,
    this.minPrice,
    this.maxPrice,
  });

  bool get hasFilters =>
      sortOrder != null ||
      dateFrom != null ||
      condition != null ||
      minPrice != null ||
      maxPrice != null;
}
