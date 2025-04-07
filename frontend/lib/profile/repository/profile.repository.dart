import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:utm_marketplace/profile/model/profile.model.dart';

class ProfileRepository {
  Future<ProfileModel> fetchData(String userId) async {
    await Future.delayed(const Duration(milliseconds: 1500));

    final response =
        await rootBundle.loadString('assets/data/temp_profile_data.json');
    final json = jsonDecode(response);
    return ProfileModel.fromJson(json);
  }

  Future<ProfileModel> updateProfile({
    required String userId,
    String? name,
    String? imageUrl,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1500));

    // For now, just return the updated profile
    // In a real app, this would make an API call to update the profile
    final response =
        await rootBundle.loadString('assets/data/temp_profile_data.json');
    final json = jsonDecode(response);
    final profile = ProfileModel.fromJson(json);

    return ProfileModel(
      id: profile.id,
      name: name ?? profile.name,
      email: profile.email,
      imageUrl: imageUrl ?? profile.imageUrl,
      rating: profile.rating,
      reviews: profile.reviews,
      listings: profile.listings,
      savedItems: profile.savedItems,
    );
  }
}
