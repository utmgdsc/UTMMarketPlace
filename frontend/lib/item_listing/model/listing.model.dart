import 'dart:convert';

import 'package:flutter/material.dart';

ListingModel listingModelFromJson(String str) {
  debugPrint('decoding json: $str');
  debugPrint('decoded json: ${json.decode(str)}');
  return ListingModel.fromJson(json.decode(str));
}

String listingModelToJson(ListingModel data) => json.encode(data.toJson());

class ListingModel {
  final List<Item> items;

  ListingModel({
    this.items = const [],
    this.total,
    this.nextPageToken,
  });

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
  final String id;
  final String title;
  final double price;
  final String description;
  final String sellerId;
  final List<String> pictures;
  final String category;
  final String condition;
  final String campus;
  final DateTime? datePosted;
  final String? paginationToken;

  Item({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.sellerId,
    this.pictures = const [],
    required this.category,
    required this.condition,
    required this.campus,
    this.datePosted,
    this.paginationToken,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"] as String? ?? '',
        description: json["description"] as String? ?? '',
        price: (json["price"] as num?)?.toDouble() ?? 0.0,
        category: json["category"] as String? ?? '',
        condition: json["condition"] as String? ?? '',
        datePosted: json["date_posted"] != null
            ? DateTime.tryParse(json["date_posted"])
            : null,
        campus: json["campus"] as String? ?? '',
        title: json["title"] as String? ?? '',
        sellerId: json["seller_id"] as String? ?? '',
        pictures: json["pictures"] == null
            ? []
            : List<String>.from(
                (json["pictures"] as List).map((x) => x as String)),
        paginationToken: json["paginationToken"] as String?,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "description": description,
        "price": price,
        "category": category,
        "condition": condition,
        "date_posted": datePosted?.toIso8601String(),
        "campus": campus,
        "title": title,
        "seller_id": sellerId,
        "pictures": List<dynamic>.from(pictures.map((x) => x)),
        "paginationToken": paginationToken,
      };
}
