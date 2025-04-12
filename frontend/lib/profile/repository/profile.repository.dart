import 'package:utm_marketplace/profile/model/profile.model.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';
import 'package:utm_marketplace/shared/secure_storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter/material.dart';

class ProfileRepository {
  // Helper method to extract user ID from JWT token
  String _getUserIdFromToken(String token) {
    // Decode JWT token (format: header.payload.signature)
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token format');
    }

    // Decode the payload (middle part)
    String normalizedPayload = base64Url.normalize(parts[1]);
    final payloadMap =
        json.decode(utf8.decode(base64Url.decode(normalizedPayload)));
    final userId = payloadMap['id'];

    if (userId == null) {
      throw Exception('User ID not found in token');
    }

    return userId;
  }

  // Method to fetch an image and return it as a MemoryImage
  Future<ImageProvider> fetchImageProvider(String imageUrl) async {
    try {
      final response = await dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      return MemoryImage(response.data);
    } catch (e) {
      debugPrint('Error fetching image: $e');
      throw Exception('Failed to load image');
    }
  }

  Future<ProfileModel> fetchUserProfileById(String userId) async {
    try {
      // Get the JWT token from secure storage
      final token = await secureStorage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('User is not authenticated');
      }

      // If userId is "me", get the user ID from the token
      String targetUserId = userId;
      if (userId == 'me') {
        targetUserId = _getUserIdFromToken(token);
      }

      // Make API call with authenticated headers
      final response = await dio.get(
        '/user/$targetUserId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      // Convert response to profile model
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<ProfileModel> updateProfile({
    required String userId,
    String? displayName,
    String? profilePicture,
    String? location,
  }) async {
    try {
      // Get the JWT token from secure storage
      final token = await secureStorage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('User is not authenticated');
      }

      // If userId is "me", get the user ID from the token
      String targetUserId = userId;
      if (userId == 'me') {
        targetUserId = _getUserIdFromToken(token);
      }

      // Prepare update data
      final updateData = {};
      if (displayName != null) {
        updateData['display_name'] = displayName;
      }
      if (profilePicture != null) {
        updateData['profile_picture'] = profilePicture;
      }
      if (location != null) {
        updateData['location'] = location;
      }

      // Make API call
      final response = await dio.put(
        '/user/$targetUserId',
        data: updateData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      // Convert response to profile model
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
