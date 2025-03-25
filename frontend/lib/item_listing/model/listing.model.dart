import 'dart:convert';

import 'package:flutter/material.dart';

ListingModel listingModelFromJson(String str) {
  debugPrint('decoding json: $str');
  debugPrint('decoded json: ${json.decode(str)}');
  return ListingModel.fromJson(json.decode(str));
}

String listingModelToJson(ListingModel data) => json.encode(data.toJson());

class ListingModel {
  ListingModel({
    this.items = const [],
    this.total,
    this.nextPageToken,
  });

  List<Item> items;
  int? total;
  String? nextPageToken;

  factory ListingModel.fromJson(Map<String, dynamic> json) => ListingModel(
        items: json["listings"] == null
            ? []
            : List<Item>.from(json["listings"].map((x) => Item.fromJson(x))),
        total: json["total"],
        nextPageToken: json["next_page_token"],
      );

  Map<String, dynamic> toJson() => {
        "listings": List<dynamic>.from(items.map((x) => x.toJson())),
        "total": total,
        "next_page_token": nextPageToken,
      };
}

class Item {
  Item({
    this.id,
    required this.title,
    required this.price,
    this.description,
    required this.sellerId,
    this.pictures = const [],
    required this.condition,
    this.category,
    this.datePosted,
    this.campus,
    this.paginationToken,
  });

  String? id;
  String title;
  double price;
  String? description;
  String sellerId;
  List<String> pictures;
  String condition;
  String? category;
  String? datePosted;
  String? campus;
  String? paginationToken;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        title: json["title"],
        price: (json["price"] ?? 0).toDouble(),
        description: json["description"],
        sellerId: json["seller_id"],
        pictures: json["pictures"] == null
            ? []
            : List<String>.from(json["pictures"].map((x) => x)),
        condition: json["condition"],
        category: json["category"],
        datePosted: json["date_posted"],
        campus: json["campus"],
        paginationToken: json["paginationToken"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
        "description": description,
        "seller_id": sellerId,
        "pictures": List<dynamic>.from(pictures.map((x) => x)),
        "condition": condition,
        "category": category,
        "date_posted": datePosted,
        "campus": campus,
        "paginationToken": paginationToken,
      };
}
