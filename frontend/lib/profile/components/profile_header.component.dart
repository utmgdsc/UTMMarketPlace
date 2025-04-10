import 'package:flutter/material.dart';
import 'package:utm_marketplace/profile/components/edit_profile_dialog.component.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';

class ProfileHeader extends StatelessWidget {
  final String displayName;
  final String email;
  final String? profilePicture;
  final double rating;
  final int ratingCount;
  final bool isOwnProfile;

  const ProfileHeader({
    super.key,
    required this.displayName,
    required this.email,
    this.profilePicture,
    required this.rating,
    required this.ratingCount,
    required this.isOwnProfile,
  });

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
    final profileAppBar = AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: const Text(
        'Profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: isOwnProfile
          ? IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => EditProfileDialog(
                    currentName: displayName,
                    currentImageUrl: profilePicture,
                  ),
                );
              },
            )
          : null,
      actions: isOwnProfile
          ? [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {},
              ),
            ]
          : null,
    );

    final profileImage = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: CircleAvatar(
        radius: 65,
        backgroundImage: _getImageProvider(profilePicture),
        backgroundColor: const Color(0xFF1E3765),
        child: profilePicture == null || profilePicture!.isEmpty
            ? const Icon(Icons.person, size: 65, color: Colors.white)
            : null,
      ),
    );

    final userName = Text(
      displayName,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );

    final userEmail = Text(
      email,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
    );

    final ratingStars = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($ratingCount)',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ],
    );

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 200,
              color: const Color(0xFF1E3765),
            ),
            Column(
              children: [
                profileAppBar,
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      profileImage,
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 2),
        userName,
        const SizedBox(height: 4),
        userEmail,
        const SizedBox(height: 8),
        ratingStars,
      ],
    );
  }
}
