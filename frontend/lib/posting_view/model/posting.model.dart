import 'dart:convert';

PostingModel postingModelFromJson(String str, String itemid) =>
    PostingModel.fromJson(json.decode(str), itemid);

String postingModelToJson(PostingModel data) => json.encode(data.toJson());

class PostingModel {
  PostingModel({
    Item? item,
  }) : item = item ?? Item(name: '', price: 0.0);

  Item item;

  factory PostingModel.fromJson(Map<String, dynamic> json, String itemid) {
    List<Item> items =
        List<Item>.from(json["items"].map((x) => Item.fromJson(x)));
    Item? foundItem = items.firstWhere((item) => item.id == itemid,
        orElse: () => Item(name: '', price: 0.0));
    return PostingModel(item: foundItem);
  }
  Map<String, dynamic> toJson() => {
        "item": item.toJson(),
      };
}

class Item {
  Item({
    this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.category,
  });

  String? id;
  String name;
  double price;
  String? description;
  String? imageUrl;
  String? category;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        name: json["name"],
        description: json["description"],
        price: json["price"].toDouble(),
        imageUrl: json["image_url"],
        category: json["category"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "description": description,
        "price": price,
        "image_url": imageUrl,
        "category": category,
      };
}
