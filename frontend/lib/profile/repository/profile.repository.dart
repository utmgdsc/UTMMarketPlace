import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:utm_marketplace/profile/model/profile.model.dart';

class ProfileRepository {
  Future<ProfileModel> fetchData(String userId) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final response = await rootBundle.loadString('assets/data/temp_profile_data.json');
    final json = jsonDecode(response);
    return ProfileModel.fromJson(json);
  }
}
