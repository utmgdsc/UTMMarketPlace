import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/profile/view_models/profile.viewmodel.dart';
import 'package:image_picker/image_picker.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';
import 'dart:io';

class EditProfileDialog extends StatefulWidget {
  final String currentName;
  final String? currentImageUrl;

  const EditProfileDialog({
    super.key,
    required this.currentName,
    this.currentImageUrl,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late TextEditingController _nameController;
  File? _imageFile;
  final _imagePicker = ImagePicker();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, // Reasonable size for profile pictures
      maxHeight: 800,
      imageQuality: 85, // Good quality while keeping size reasonable
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    final viewModel = context.read<ProfileViewModel>();
    final currentContext = context;

    try {
      // Get the current user ID from the profile model
      final userId = viewModel.profile?.id ?? 'me';

      final success = await viewModel.updateProfile(
        userId: userId,
        displayName: _nameController.text,
        profilePicture: _imageFile,
      );

      if (currentContext.mounted) {
        if (success) {
          Navigator.pop(currentContext);
        } else {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(
              content: Text('Failed to update profile. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (currentContext.mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? getImageProvider() {
      if (_imageFile != null) {
        return FileImage(_imageFile!);
      } else if (widget.currentImageUrl != null && widget.currentImageUrl!.isNotEmpty) {
        // Prepend the base URL if it's a static file path
        final imageUrl = widget.currentImageUrl!.startsWith('/static/')
            ? '${dio.options.baseUrl}${widget.currentImageUrl}'
            : widget.currentImageUrl!;
        return NetworkImage(imageUrl);
      }
      return null;
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _isSaving ? null : _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: getImageProvider(),
                    backgroundColor: const Color(0xFF1E3765),
                    child: (_imageFile == null && (widget.currentImageUrl == null || widget.currentImageUrl!.isEmpty))
                        ? const Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E3765),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              enabled: !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3765),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
