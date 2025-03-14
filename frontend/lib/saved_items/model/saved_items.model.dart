import 'package:utm_marketplace/shared/models/listing_item.model.dart';

class SavedItemsModel {
  final List<ListingItem> items;

  SavedItemsModel({
    this.items = const [],
  });

  factory SavedItemsModel.fromJson(Map<String, dynamic> json) {
    return SavedItemsModel(
      items: (json['items'] as List?)
              ?.map((item) => ListingItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}
