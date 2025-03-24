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
  final String title;
  final double price;
  final String? imageUrl;
  final String condition;
  final DateTime? datePosted;

  Item({
    required this.id,
    required this.title,
    required this.price,
    this.imageUrl,
    required this.condition,
    this.datePosted,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      title: json['title'],
      price: json['price'].toDouble(),
      imageUrl: json['image_url'],
      condition: json['condition'],
      datePosted: json['date_posted'] != null 
          ? DateTime.parse(json['date_posted']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
        "image_url": imageUrl,
        "condition": condition,
        "date_posted": datePosted?.toIso8601String(),
      };
}
