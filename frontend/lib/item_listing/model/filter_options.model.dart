enum SortOrder {
  priceLowToHigh,
  priceHighToLow,
  dateRecent
}

class FilterOptions {
  final String? priceType;
  final DateTime? dateRange;
  final String? condition;
  final double? lowerPrice;
  final double? upperPrice;
  final String? campus;

  FilterOptions({
    this.priceType,
    this.dateRange,
    this.condition,
    this.lowerPrice,
    this.upperPrice,
    this.campus,
  });

  bool get hasFilters =>
      priceType != null ||
      dateRange != null ||
      condition != null ||
      lowerPrice != null ||
      upperPrice != null ||
      campus != null;

  // Helper method to format date for display
  String get formattedDateFrom {
    if (dateRange == null) return 'All time';
    return '${dateRange!.month}/${dateRange!.day}/${dateRange!.year}';
  }

  // Convert SortOrder to backend price_type
  static String? sortOrderToPriceType(SortOrder? order) {
    if (order == null) return null;
    switch (order) {
      case SortOrder.priceLowToHigh:
        return 'price-low-to-high';
      case SortOrder.priceHighToLow:
        return 'price-high-to-low';
      case SortOrder.dateRecent:
        return 'date-recent';
    }
  }

  // Copy with method for immutability
  FilterOptions copyWith({
    String? priceType,
    DateTime? dateRange,
    String? condition,
    double? lowerPrice,
    double? upperPrice,
    String? campus,
  }) {
    return FilterOptions(
      priceType: priceType ?? this.priceType,
      dateRange: dateRange ?? this.dateRange,
      condition: condition ?? this.condition,
      lowerPrice: lowerPrice ?? this.lowerPrice,
      upperPrice: upperPrice ?? this.upperPrice,
      campus: campus ?? this.campus,
    );
  }

  // Clear all filters
  FilterOptions clear() {
    return FilterOptions();
  }
}
