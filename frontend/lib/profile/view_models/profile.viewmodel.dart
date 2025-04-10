import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/profile/model/profile.model.dart';
import 'package:utm_marketplace/profile/repository/profile.repository.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

class ProfileViewModel extends LoadingViewModel {
  final ProfileRepository repo;
  ProfileModel? _profileModel;
  bool _showListings = true;
  bool _isUpdating = false;
  String? _errorMessage;

  ProfileViewModel({required this.repo});

  ProfileModel? get profile => _profileModel;
  bool get showListings => _showListings;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;

  void toggleView() {
    _showListings = !_showListings;
    notifyListeners();
  }

  Future<void> fetchData(String userId) async {
    try {
      _errorMessage = null;
      isLoading = true;
      notifyListeners();
      
      final result = await repo.fetchData(userId);
      _profileModel = result;
      notifyListeners();
    } catch (e) {
      debugPrint('Error in fetchData: ${e.toString()}');
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String userId,
    String? displayName,
    File? profilePicture,
    String? location,
  }) async {
    if (_profileModel == null) return false;

    try {
      _errorMessage = null;
      _isUpdating = true;
      notifyListeners();

      String? profilePictureBase64;
      if (profilePicture != null) {
        try {
          final bytes = await profilePicture.readAsBytes();
          profilePictureBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        } catch (e) {
          debugPrint('Error converting profile picture to base64: ${e.toString()}');
          return false;
        }
      }

      // Create optimistic update
      final updatedProfile = ProfileModel(
        id: _profileModel!.id,
        displayName: displayName ?? _profileModel!.displayName,
        email: _profileModel!.email,
        profilePicture: profilePictureBase64 ?? _profileModel!.profilePicture,
        rating: _profileModel!.rating,
        ratingCount: _profileModel!.ratingCount,
        location: location ?? _profileModel!.location,
        savedPosts: _profileModel!.savedPosts,
        reviews: _profileModel!.reviews,
        listings: _profileModel!.listings,
      );

      // Update UI immediately
      _profileModel = updatedProfile;
      notifyListeners();

      // Make API call
      final result = await repo.updateProfile(
        userId: userId,
        displayName: displayName,
        profilePicture: profilePictureBase64,
        location: location,
      );

      // Update with server response
      _profileModel = result;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error in updateProfile: ${e.toString()}');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }
}
