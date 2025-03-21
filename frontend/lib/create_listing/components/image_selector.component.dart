import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
        final bool showError = !model.hasImages && showValidationErrors;
        final ImagePicker picker = ImagePicker();

        final imageContent = model.images.isNotEmpty
            ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FutureBuilder<List<File>>(
                future: Future.value(model.images.map((xfile) => File(xfile.path)).toList()),
                builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                  return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return Image.file(
                    snapshot.data![index],
                    fit: BoxFit.cover,
                    );
                  },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
                },
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
            final List<XFile> images =
                await picker.pickMultiImage();
            if (images.isNotEmpty) {
              for (var image in images) {
                model.addMedia(image);
              }
            }
          },
          child: imageContainer,
        );
      },
    );
  }
}
