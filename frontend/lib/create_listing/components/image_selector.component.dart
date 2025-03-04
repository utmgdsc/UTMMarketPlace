import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/create_listing/view_models/create_listing.viewmodel.dart';

class ImageSelector extends StatelessWidget {
  final bool showValidationErrors;

  const ImageSelector({
    super.key,
    required this.showValidationErrors,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateListingViewModel>(
      builder: (_, model, __) {
        final bool showError = !model.hasImage && showValidationErrors;

        final imageContent = model.image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  model.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color:
                        showError ? const Color(0xFFFF5252) : Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add photos / video',
                    style: TextStyle(
                      color: showError
                          ? const Color(0xFFFF5252)
                          : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  if (showError)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        'Add a photo to continue.',
                        style: TextStyle(
                          color: Color(0xFFFF5252),
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              );

        final imageContainer = Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: showError ? const Color(0xFFFF5252) : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: imageContent,
        );

        return GestureDetector(
          onTap: () async {
            // Your existing image selection logic
          },
          child: imageContainer,
        );
      },
    );
  }
}
