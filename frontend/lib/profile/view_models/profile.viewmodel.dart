import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/profile/model/profile.model.dart';
import 'package:utm_marketplace/profile/repository/profile.repository.dart';
import 'package:utm_marketplace/shared/secure_storage/secure_storage.dart';
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
  int _imageVersion = 0;
  String profileName = '';
  String profileImageUrl = '';
  String profileId = '';
  String conversationId = '';

  ProfileViewModel({required this.repo});

  ProfileModel? get profile => _profileModel;
  bool get showListings => _showListings;
  bool get isUpdating => _isUpdating;
  String? get errorMessage => _errorMessage;
  int get imageVersion => _imageVersion;

  void toggleView() {
    _showListings = !_showListings;
    notifyListeners();
  }

  String _getUserIdFromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token format');
    }

    String normalizedPayload = base64Url.normalize(parts[1]);
    final payloadMap =
        json.decode(utf8.decode(base64Url.decode(normalizedPayload)));
    final userId = payloadMap['id'];

    if (userId == null) {
      throw Exception('User ID not found in token');
    }

    return userId;
  }

  Future<void> fetchUserProfileById(String userId) async {
    try {
      final token = await secureStorage.read(key: 'jwt_token');

      if (token == null) {
        throw Exception('User is not authenticated');
      }

      final currentUserId = _getUserIdFromToken(token);

      _errorMessage = null;
      isLoading = true;
      notifyListeners();
      final result = await repo.fetchUserProfileById(userId);

      final reviews = await repo.fetchReviews(userId);
      result.fetchReviews(reviews);
      _profileModel = result;
      profileName = _profileModel?.displayName ?? '';
      profileImageUrl = _profileModel?.profilePicture ?? '';
      profileId = _profileModel?.id ?? '';

      final sortedIds = [currentUserId, userId];
      sortedIds.sort((a, b) => a.compareTo(b));
      conversationId = sortedIds.join('_');
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

  Future<void> refreshUserData() async {
    if (_profileModel == null) return;

    try {
      _imageVersion++;

      await fetchUserProfileById(_profileModel!.id);

      final reviews = await repo.fetchReviews(_profileModel!.id);
      _profileModel?.fetchReviews(reviews);
    } catch (e) {
      debugPrint('Error refreshing user data: ${e.toString()}');
    }
  }

  Future<void> submitReview(String review, int rating) async {
    if (_profileModel == null) return;
    int result = 0;

    try {
      _errorMessage = null;
      isLoading = true;
      notifyListeners();

      result = await repo.submitReview(_profileModel!.id, review, rating);
      if (result == 403) {
        _errorMessage = "You must have spoken to the seller to leave a review.";
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error in submitReview: ${e.toString()} $result');
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
          profilePictureBase64 =
              'data:image/jpeg;base64,${base64Encode(bytes)}';
        } catch (e) {
          debugPrint(
              'Error converting profile picture to base64: ${e.toString()}');
          return false;
        }
      }

      if (profilePicture != null) {
        final previewProfile = ProfileModel(
          id: _profileModel!.id,
          displayName: displayName ?? _profileModel!.displayName,
          email: _profileModel!.email,
          profilePicture: _profileModel!.profilePicture,
          rating: _profileModel!.rating,
          ratingCount: _profileModel!.ratingCount,
          location: location ?? _profileModel!.location,
          savedPosts: _profileModel!.savedPosts,
          reviews: _profileModel!.reviews,
          listings: _profileModel!.listings,
        );

        _profileModel = previewProfile;
        notifyListeners();
      } else if (displayName != null || location != null) {
        final updatedProfile = ProfileModel(
          id: _profileModel!.id,
          displayName: displayName ?? _profileModel!.displayName,
          email: _profileModel!.email,
          profilePicture: _profileModel!.profilePicture,
          rating: _profileModel!.rating,
          ratingCount: _profileModel!.ratingCount,
          location: location ?? _profileModel!.location,
          savedPosts: _profileModel!.savedPosts,
          reviews: _profileModel!.reviews,
          listings: _profileModel!.listings,
        );

        _profileModel = updatedProfile;
        notifyListeners();
      }

      final result = await repo.updateProfile(
        userId: userId,
        displayName: displayName,
        profilePicture: profilePictureBase64,
        location: location,
      );

      _imageVersion++;

      _profileModel = result;
      profileName = result.displayName;
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
