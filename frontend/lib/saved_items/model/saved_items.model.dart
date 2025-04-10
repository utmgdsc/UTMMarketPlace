import 'package:utm_marketplace/shared/models/listing_item.model.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SavedItemsModel {
  final List<ListingItem> items;
  final int total;

  SavedItemsModel({
    this.items = const [],
    this.total = 0,
  });

  factory SavedItemsModel.fromJson(dynamic json) {
    try {
      debugPrint('SavedItemsModel.fromJson input: $json');
      
      // Handle tuple response from backend when empty
      if (json is List) {
        return SavedItemsModel(
          items: [],
          total: 0,
        );
      }

      // Handle dictionary response when there are items
      if (json is Map<String, dynamic>) {
        final List<dynamic> savedItems = json['saved_items'] ?? [];
        
        return SavedItemsModel(
          items: savedItems.map((item) => ListingItem.fromJson({
            'id': item['id'] ?? '',
            'image_url': item['pictures'] != null && item['pictures'].isNotEmpty ? item['pictures'][0] : '',
            'title': item['title'] ?? 'No Title',
            'price': (item['price'] ?? 0).toDouble(),
          })).toList(),
          total: json['total'] ?? 0,
        );
      }

      // If response is neither a list nor a map, return empty model
      debugPrint('Unexpected response type: ${json.runtimeType}');
      return SavedItemsModel(items: [], total: 0);
      
    } catch (e) {
      debugPrint('Error parsing saved items: $e');
      debugPrint('Original JSON: $json');
      return SavedItemsModel(items: [], total: 0);
    }
  }

  static Future<Response> saveItem(String itemId) async {
    try {
      final response = await dio.post(
        '/saved_items',
        data: {
          'id': itemId,
        },
      );
      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      } else {
        throw Exception('Failed to save item: ${e.message}');
      }
    }
  }

  static Future<Response> unsaveItem(String itemId) async {
    try {
      final response = await dio.delete(
        '/saved_items',
        queryParameters: {
          'saved_item_id': itemId,
        },
      );
      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      } else {
        throw Exception('Failed to unsave item: ${e.message}');
      }
    }
  }
}
