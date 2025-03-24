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

  // Helper method to format date for display
  String get formattedDateFrom {
    if (dateFrom == null) return 'All time';
    return '${dateFrom!.month}/${dateFrom!.day}/${dateFrom!.year}';
  }

  // Copy with method for immutability
  FilterOptions copyWith({
    SortOrder? sortOrder,
    DateTime? dateFrom,
    String? condition,
    double? minPrice,
    double? maxPrice,
  }) {
    return FilterOptions(
      sortOrder: sortOrder ?? this.sortOrder,
      dateFrom: dateFrom ?? this.dateFrom,
      condition: condition ?? this.condition,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }

  // Clear all filters
  FilterOptions clear() {
    return FilterOptions();
  }
}
