import 'package:flutter/material.dart';
import 'package:utm_marketplace/profile/components/edit_profile_dialog.component.dart';

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
        backgroundImage: profilePicture != null && profilePicture!.isNotEmpty
            ? NetworkImage(profilePicture!) as ImageProvider
            : null,
        backgroundColor: const Color(0xFF11384A),
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
        ...List.generate(5, (index) {
          return Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: Colors.black,
            size: 20,
          );
        }),
        Text(' ($rating/5, $ratingCount reviews)'),
      ],
    );

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 175,
              color: const Color(0xFF11384A),
            ),
            Column(
              children: [
                profileAppBar,
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      profileImage,
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        userName,
        userEmail,
        ratingStars,
      ],
    );
  }
}
