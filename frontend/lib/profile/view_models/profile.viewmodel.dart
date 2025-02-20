import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/profile/model/profile.model.dart';
import 'package:utm_marketplace/profile/repository/profile.repository.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class ProfileViewModel extends LoadingViewModel {
  final ProfileRepository repo;
  ProfileModel? _profileModel;
  bool _showListings = true;

  ProfileViewModel({required this.repo});

  ProfileModel? get profile => _profileModel;
  bool get showListings => _showListings;

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
}
