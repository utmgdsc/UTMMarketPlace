import 'dart:convert';

PostingModel postingModelFromJson(String str, String itemid) =>
    PostingModel.fromJson(json.decode(str), itemid);

String postingModelToJson(PostingModel data) => json.encode(data.toJson());

class PostingModel {
  PostingModel({
    Item? item,
  }) : item = item ?? Item(name: '', price: 0.0);

  Item item;

  factory PostingModel.fromJson(Map<String, dynamic> json, String itemid) =>
      PostingModel(
        item: json["id"] == itemid
            ? Item.fromJson(json)
            : Item(name: '', price: 0.0),
      );
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
    this.condition,
    this.datePosted,
    this.campus,
    this.sellerId,
    this.sellerName,
    this.sellerEmail,
    this.pictures,
  });

  String? id;
  String name;
  double price;
  String? description;
  List<String>? imageUrl;
  String? category;
  String? condition;
  String? datePosted;
  String? campus;
  String? sellerId;
  String? sellerName;
  String? sellerEmail;
  List<String>? pictures;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        name: json["title"],
        description: json["description"],
        price: json["price"].toDouble(),
        imageUrl: (json["pictures"] != null && json["pictures"].isNotEmpty)
            ? List<String>.from(json["pictures"])
            : null,
        category: json["category"],
        condition: json["condition"],
        datePosted:
            json["date_posted"]?.substring(0, json["date_posted"].length - 17),
        campus: json["campus"],
        sellerId: json["seller_id"],
        sellerName: json["seller_name"],
        sellerEmail: json["seller_email"],
        pictures: json["pictures"] != null
            ? List<String>.from(json["pictures"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": name,
        "description": description,
        "price": price,
        "pictures": pictures,
        "category": category,
        "condition": condition,
        "date_posted": datePosted,
        "campus": campus,
        "seller_id": sellerId,
        "seller_name": sellerName,
        "seller_email": sellerEmail,
      };
}
