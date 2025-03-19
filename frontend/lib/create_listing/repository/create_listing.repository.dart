import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:utm_marketplace/create_listing/model/create_listing.model.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';
import 'package:utm_marketplace/shared/secure_storage/secure_storage.dart';

class CreateListingRepository {
  Future<bool> createListing(CreateListingModel listing) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      final token = await secureStorage.read(key: 'jwt_token');
      debugPrint('Creating listing with data: ${listing.toJson()}');
      final response = await dio.post(
        '/listings',
        data: listing.toJson(),
        // TODO: Remove this authorization once auth interceptor is deployed
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      debugPrint('Response received: ${response.statusCode}');

      return response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('Error response: ${e.response?.data}');
        return false;
      } else {
        debugPrint('Failed to create listing: ${e.message}');
        throw Exception('Failed to create listing: ${e.message}');
      }
    }
  }
}
