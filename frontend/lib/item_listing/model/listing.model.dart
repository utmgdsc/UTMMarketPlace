import 'dart:convert';

ListingModel listingModelFromJson(String str) =>
    ListingModel.fromJson(json.decode(str));

String listingModelToJson(ListingModel data) => json.encode(data.toJson());

class ListingModel {
  ListingModel({
    this.items = const [],
  });

  List<Item> items;

  factory ListingModel.fromJson(Map<String, dynamic> json) => ListingModel(
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Item {
  Item({
    this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.category,
  });

  String? id;
  String name;
  double price;
  String? imageUrl;
  String? category;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        name: json["name"],
        price: json["price"].toDouble(),
        imageUrl: json["image_url"],
        category: json["category"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "image_url": imageUrl,
        "category": category,
      };
}
