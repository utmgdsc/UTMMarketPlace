import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:utm_marketplace/create_listing/model/create_listing.model.dart';
import 'package:utm_marketplace/create_listing/repository/create_listing.repository.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class CreateListingViewModel extends LoadingViewModel {
  final CreateListingRepository repo;
  
  CreateListingViewModel({required this.repo});

  String _condition = '';
  String get condition => _condition;
  
  File? _image;
  File? get image => _image;
  bool get hasImage => _image != null;

  void setImage(File image) {
    _image = image;
    notifyListeners();
  }
  
  void setCondition(String condition) {
    _condition = condition;
    notifyListeners();
  }

  Future<bool> createListing({
    required String title,
    required double price,
    String? description,
  }) async {
    try {
      isLoading = true;
      
      final listing = CreateListingModel(
        title: title,
        price: price,
        description: description,
        condition: _condition,
      );

      if (!listing.isValid) {
        return false;
      }

      return await repo.createListing(listing);
    } catch (e) {
      debugPrint('Error creating listing: $e');
      return false;
    } finally {
      isLoading = false;
    }
  }
}