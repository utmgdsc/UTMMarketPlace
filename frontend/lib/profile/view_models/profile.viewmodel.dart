import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/profile/model/profile.model.dart';
import 'package:utm_marketplace/profile/repository/profile.repository.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class ProfileViewModel extends LoadingViewModel {
  final ProfileRepository repo;
  ProfileModel? _profileModel;
  bool _showListings = true;
  bool _isUpdating = false;

  ProfileViewModel({required this.repo});

  ProfileModel? get profile => _profileModel;
  bool get showListings => _showListings;
  bool get isUpdating => _isUpdating;

  void toggleView() {
    _showListings = !_showListings;
    notifyListeners();
  }

  Future<void> fetchData(String userId) async {
    try {
      isLoading = true;
      _profileModel = await repo.fetchData(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error in fetchData: ${e.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? imageUrl,
  }) async {
    if (_profileModel == null) return false;
    
    try {
      _isUpdating = true;
      notifyListeners();

      // Create optimistic update
      final updatedProfile = ProfileModel(
        id: _profileModel!.id,
        name: name ?? _profileModel!.name,
        email: _profileModel!.email,
        imageUrl: imageUrl ?? _profileModel!.imageUrl,
        rating: _profileModel!.rating,
        reviews: _profileModel!.reviews,
        listings: _profileModel!.listings,
        savedItems: _profileModel!.savedItems,
      );

      // Update UI immediately
      _profileModel = updatedProfile;
      notifyListeners();

      // Make API call
      final result = await repo.updateProfile(
        userId: userId,
        name: name,
        imageUrl: imageUrl,
      );

      // Update with server response
      _profileModel = result;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error in updateProfile: ${e.toString()}');
      return false;
    } finally {
      _isUpdating = false;
    }
  }
}
