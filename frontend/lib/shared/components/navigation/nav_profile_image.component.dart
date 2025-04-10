import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/profile/view_models/profile.viewmodel.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';

class NavProfileImage extends StatelessWidget {
  const NavProfileImage({super.key});

  ImageProvider? _getImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }
    
    // Prepend the base URL if it's a static file path
    final fullImageUrl = imageUrl.startsWith('/static/')
        ? '${dio.options.baseUrl}$imageUrl'
        : imageUrl;
    return NetworkImage(fullImageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, profileViewModel, _) {
        final profilePicture = profileViewModel.profile?.profilePicture;
        
        return CircleAvatar(
          radius: 13,
          backgroundImage: _getImageProvider(profilePicture),
          backgroundColor: const Color(0xFF1E3765),
          child: profilePicture == null || profilePicture.isEmpty
              ? const Icon(Icons.person, size: 13, color: Colors.white)
              : null,
        );
      },
    );
  }
}
