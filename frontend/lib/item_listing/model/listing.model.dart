import 'dart:convert';

ListingModel listingModelFromJson(String str) =>
    ListingModel.fromJson(json.decode(str));

String listingModelToJson(ListingModel data) => json.encode(data.toJson());

class ListingModel {
  final List<Item> items;

  ListingModel({
    this.items = const [],
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      items: List<Item>.from(json['items'].map((x) => Item.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Item {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? imageUrl;
  final String category;
  final String condition;
  final DateTime? datePosted;
  final String? campus;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    this.condition = 'Used',
    this.datePosted,
    this.campus,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] is int)
          ? (json['price'] as int).toDouble()
          : json['price'].toDouble(),
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String,
      condition: json['condition'] as String? ?? 'Used',
      datePosted: DateTime.now(),
      campus: json['campus'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "image_url": imageUrl,
        "category": category,
        "condition": condition,
        "date_posted": datePosted?.toIso8601String(),
        "campus": campus,
      };
}
