import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:utm_marketplace/create_listing/model/create_listing.model.dart';
import 'package:utm_marketplace/create_listing/repository/create_listing.repository.dart';
import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class CreateListingViewModel extends LoadingViewModel {
  final CreateListingRepository repo;
  CreateListingViewModel({required this.repo});

  String _condition = '';
  String get condition => _condition;
  final List<XFile> _images = [];
  List<XFile> get images => _images;
  bool get hasImages => _images.isNotEmpty;

  bool _showValidationErrors = false;
  bool get showValidationErrors => _showValidationErrors;

  void addMedia(XFile image) {
    _images.add(image);
    notifyListeners();
  }

  void setCondition(String condition) {
    _condition = condition;
    notifyListeners();
  }

  void clearCondition() {
    _condition = '';
  }

  void setShowValidationErrors(bool value) {
    _showValidationErrors = value;
    notifyListeners();
  }

  void clearImages() {
    _images.clear();
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

    return isFormValid && hasImages && hasConditionSelected;
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
      debugPrint('Creating listing with title: $title, price: $price, description: $description, condition: $_condition');
      final listing = CreateListingModel(
        title: title,
        price: price,
        description: description,
        condition: _condition,
        // TODO: Change encryption method for images when backend is ready
        images: await Future.wait(_images.map((image) async {
          final bytes = await image.readAsBytes();
          return base64Encode(bytes);
        }).toList()),
      );

      if (!listing.isValid) {
        debugPrint('Listing is not valid');
        return false;
      }

      final result = await repo.createListing(listing);
      return result;
    } catch (e) {
      debugPrint('Error creating listing: $e');
      return false;
    } finally {
      isLoading = false;
    }
  }
}
