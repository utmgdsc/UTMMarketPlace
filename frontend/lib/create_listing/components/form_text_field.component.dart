import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/create_listing/view_models/create_listing.viewmodel.dart';

class FormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPrice;

  const FormTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPrice = false,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CreateListingViewModel>(context, listen: false);
    
    final inputFormatters = isPrice
        ? [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ]
        : null;
    
    final keyboardType = isPrice 
        ? const TextInputType.numberWithOptions(decimal: true) 
        : TextInputType.text;
    
    final errorStyle = const TextStyle(
      color: Colors.red,
      fontSize: 12,
      height: 0.8,
    );
    
    final hintText = isPrice ? 'Enter price' : 'Enter $label';
    
    final prefixIcon = isPrice ? const Icon(Icons.attach_money) : null;
    
    final inputDecoration = InputDecoration(
      errorStyle: errorStyle,
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey[600],
      ),
      prefixIcon: prefixIcon,
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
    
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: (value) {
        if (isPrice) {
          return viewModel.validatePrice(value);
        } else if (label == 'Title') {
          return viewModel.validateTitle(value);
        } else if (label == 'Description') {
          return viewModel.validateDescription(value);
        }
        return null;
      },
      decoration: inputDecoration,
    );
  }
}