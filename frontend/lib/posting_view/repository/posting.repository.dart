import 'package:flutter/material.dart';
import 'package:utm_marketplace/posting_view/model/posting.model.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';

class PostingRepository {
  Future<PostingModel> fetchData(String itemid) async {
    try {
      final response = await dio.get('/listing/$itemid');

      debugPrint("Item ID: $itemid");
      debugPrint("Response: ${response.data}");

      if (response.statusCode == 200) {
        return PostingModel.fromJson(response.data, itemid);
      } else {
        throw Exception('Failed to load listings');
      }
    } catch (e) {
      throw Exception('Failed to load listings: $e');
    }
  }
}
