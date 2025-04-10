import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/saved_items/model/saved_items.model.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';
import 'package:dio/dio.dart';

class SavedItemsRepository {
  Future<SavedItemsModel> fetchData() async {
    try {
      final response = await dio.get('/saved_items');
      
      debugPrint('SavedItemsRepository response status: ${response.statusCode}');
      debugPrint('SavedItemsRepository response data: ${response.data}');
      
      if (response.statusCode == 200) {
        // Handle both empty and non-empty responses
        return SavedItemsModel.fromJson(response.data);
      } else {
        debugPrint('Failed to load saved items: ${response.statusMessage}');
        throw Exception('Failed to load saved items: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      debugPrint('DioException in fetchData: ${e.message}');
      if (e.response != null) {
        debugPrint('Response data: ${e.response?.data}');
        debugPrint('Response status: ${e.response?.statusCode}');
        // Try to parse the response even if it's an error
        if (e.response?.statusCode == 200) {
          return SavedItemsModel.fromJson(e.response?.data);
        }
      }
      throw Exception('Failed to load saved items: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error in fetchData: $e');
      throw Exception('Failed to load saved items: $e');
    }
  }

  Future<bool> saveItem(String itemId) async {
    try {
      final response = await SavedItemsModel.saveItem(itemId);
      debugPrint('SaveItem response status: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error in saveItem: $e');
      return false;
    }
  }

  Future<bool> unsaveItem(String itemId) async {
    try {
      final response = await SavedItemsModel.unsaveItem(itemId);
      debugPrint('UnsaveItem response status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error in unsaveItem: $e');
      return false;
    }
  }
}
