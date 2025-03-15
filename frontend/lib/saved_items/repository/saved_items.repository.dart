import 'package:flutter/services.dart';
import 'package:utm_marketplace/saved_items/model/saved_items.model.dart';
import 'dart:convert';

class SavedItemsRepository {
  Future<SavedItemsModel> fetchData() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // Load mock data from assets
    final response =
        await rootBundle.loadString('assets/data/temp_saved_items.json');
    return SavedItemsModel.fromJson(json.decode(response));
  }
}
