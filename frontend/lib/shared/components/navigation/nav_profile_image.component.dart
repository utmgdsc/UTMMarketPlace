import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/profile/view_models/profile.viewmodel.dart';
import 'package:utm_marketplace/profile/repository/profile.repository.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';

class NavProfileImage extends StatelessWidget {
  const NavProfileImage({super.key});

  Widget _buildProfileImage(BuildContext context, String? profilePicture) {
    final imageVersion =
        Provider.of<ProfileViewModel>(context, listen: false).imageVersion;

    if (profilePicture == null || profilePicture.isEmpty) {
      return CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xFF1E3765),
        child: const Icon(Icons.person, size: 13, color: Colors.white),
      );
    }

    // Prepend the base URL if it's a static file path
    final fullImageUrl = profilePicture.startsWith('/static/')
        ? '${dio.options.baseUrl}$profilePicture?v=$imageVersion'
        : '$profilePicture?v=$imageVersion';

    return FutureBuilder<ImageProvider>(
      future: Provider.of<ProfileRepository>(context, listen: false)
          .fetchImageProvider(fullImageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: 13,
            backgroundColor: const Color(0xFF1E3765),
            child: const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return CircleAvatar(
            radius: 13,
            backgroundColor: const Color(0xFF1E3765),
            child: const Icon(Icons.error, size: 13, color: Colors.white),
          );
        } else {
          return CircleAvatar(
            radius: 13,
            backgroundImage: snapshot.data,
            backgroundColor: const Color(0xFF1E3765),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileViewModel>(
      builder: (context, profileViewModel, _) {
        final profilePicture = profileViewModel.profile?.profilePicture;
        return _buildProfileImage(context, profilePicture);
      },
    );
  }
}
