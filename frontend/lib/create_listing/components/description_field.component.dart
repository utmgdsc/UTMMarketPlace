import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/create_listing/view_models/create_listing.viewmodel.dart';

class DescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const DescriptionField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateListingViewModel>(context, listen: false);
    
    final errorStyle = const TextStyle(
      color: Colors.red,
      fontSize: 12,
      height: 0.8,
    );
    
    final inputDecoration = InputDecoration(
      errorStyle: errorStyle,
      hintText: 'Description (recommended)',
      hintStyle: TextStyle(
        color: Colors.grey[600],
      ),
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
    
    final descriptionField = TextFormField(
      controller: controller,
      maxLines: null,
      minLines: 5,
      validator: (value) => viewModel.validateDescription(value),
      decoration: inputDecoration,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        descriptionField,
      ],
    );
  }
}