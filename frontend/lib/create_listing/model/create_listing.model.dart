class CreateListingModel {
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 1000;
  static const double maxPrice = 999999.99;

  final String? title;
  final double? price;
  final String? description;
  final String condition;
  final List<String> images;

  CreateListingModel({
    this.title,
    this.price,
    this.description,
    this.condition = 'New',
    this.images = const [],
  });

  bool get isValid {
    return title != null &&
        title!.isNotEmpty &&
        title!.length <= maxTitleLength &&
        price != null &&
        price! > 0 &&
        price! <= maxPrice &&
        images.isNotEmpty &&
        (description == null || description!.length <= maxDescriptionLength);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'price': price,
      'description': description,
      'condition': condition,
      'images': images,
    };
  }
}

enum ListingCondition {
  New,
  AlmostNew,
  Used,
  Fair,
}