import 'dart:io';
import 'package:flutter/material.dart';
import 'package:utm_marketplace/create_listing/model/create_listing.model.dart';
import 'package:utm_marketplace/create_listing/repository/create_listing.repository.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class CreateListingViewModel extends LoadingViewModel {
  final CreateListingRepository repo;
  CreateListingViewModel({required this.repo});

  String _condition = '';
  String get condition => _condition;

  String? _campus;
  String? get campus => _campus;

  File? _image;
  File? get image => _image;
  bool get hasImage => _image != null;

  bool _showValidationErrors = false;
  bool get showValidationErrors => _showValidationErrors;

  void setImage(File image) {
    _image = image;
    notifyListeners();
  }

  void setCondition(String condition) {
    _condition = condition;
    notifyListeners();
  }

  void setCampus(String? campus) {
    _campus = campus;
    notifyListeners();
  }

  void setShowValidationErrors(bool value) {
    _showValidationErrors = value;
    notifyListeners();
  }

  // Validation methods
  String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length > CreateListingModel.maxTitleLength) {
      return 'Title must be less than ${CreateListingModel.maxTitleLength} characters';
    }
    return null;
  }

  String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }

    try {
      final price = double.parse(value);
      if (price <= 0) {
        return 'Price must be greater than zero';
      }
      if (price > CreateListingModel.maxPrice) {
        return 'Price cannot exceed ${CreateListingModel.maxPrice}';
      }
    } catch (e) {
      return 'Please enter a valid price';
    }

    return null;
  }

  String? validateDescription(String? value) {
    if (value != null) {
      if (value.length > CreateListingModel.maxDescriptionLength) {
        return 'Description must be less than ${CreateListingModel.maxDescriptionLength} characters';
      }
      if (value.isNotEmpty && value.trim().isEmpty) {
        return 'Description cannot be only whitespace';
      }
    }
    return null;
  }

  bool validateForm(GlobalKey<FormState> formKey) {
    setShowValidationErrors(true);

    final isFormValid = formKey.currentState?.validate() ?? false;
    final hasConditionSelected = condition.isNotEmpty;
    final hasCampusSelected = campus != null;

    return isFormValid && hasImage && hasConditionSelected && hasCampusSelected;
  }

  Future<bool> submitForm({
    required GlobalKey<FormState> formKey,
    required String title,
    required String price,
    required String description,
  }) async {
    if (!validateForm(formKey)) {
      return false;
    }
    try {
      return await createListing(
        title: title.trim(),
        price: double.parse(price),
        description: description.trim(),
      );
    } catch (e) {
      debugPrint('Error submitting form: $e');
      return false;
    }
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
        campus: _campus,
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
