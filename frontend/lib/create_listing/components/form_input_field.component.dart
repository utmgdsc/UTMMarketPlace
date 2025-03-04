import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ValidationCallback = String? Function(String? value);

class FormInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final ValidationCallback validator;
  final bool isPrice;
  final bool isMultiline;
  final int? minLines;
  final int? maxLines;

  const FormInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.validator,
    this.hintText = '',
    this.isPrice = false,
    this.isMultiline = false,
    this.minLines,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          keyboardType: _getKeyboardType(),
          inputFormatters: isPrice
              ? [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ]
              : null,
          validator: validator,
          maxLines: isMultiline ? maxLines : 1,
          minLines: isMultiline ? minLines : 1,
          decoration: InputDecoration(
            errorStyle: const TextStyle(
              color: Colors.red,
              fontSize: 12,
              height: 0.8,
            ),
            hintText: hintText.isNotEmpty ? hintText : 'Enter $label',
            hintStyle: TextStyle(
              color: Colors.grey[600],
            ),
            prefixIcon: isPrice ? const Icon(Icons.attach_money) : null,
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
          ),
        ),
      ],
    );
  }

  TextInputType _getKeyboardType() {
    if (isPrice) {
      return const TextInputType.numberWithOptions(decimal: true);
    } else if (isMultiline) {
      return TextInputType.multiline;
    } else {
      return TextInputType.text;
    }
  }
}
