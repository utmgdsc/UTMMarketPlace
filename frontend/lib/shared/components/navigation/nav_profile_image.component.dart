import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/profile/view_models/profile.viewmodel.dart';
import 'package:utm_marketplace/profile/repository/profile.repository.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';

class NavProfileImage extends StatefulWidget {
  const NavProfileImage({super.key});

  @override
  NavProfileImageState createState() => NavProfileImageState();
}

class NavProfileImageState extends State<NavProfileImage> {
  ImageProvider? _cachedImageProvider;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final profileViewModel =
        Provider.of<ProfileViewModel>(context, listen: false);
    final profilePicture = profileViewModel.profile?.profilePicture;

    if (profilePicture == null || profilePicture.isEmpty) {
      return;
    }

    final imageVersion = profileViewModel.imageVersion;
    final fullImageUrl = profilePicture.startsWith('/static/')
        ? '${dio.options.baseUrl}$profilePicture?v=$imageVersion'
        : '$profilePicture?v=$imageVersion';

    setState(() {
      _isLoading = true;
    });

    try {
      final imageProvider = await Provider.of<ProfileRepository>(
        context,
        listen: false,
      ).fetchImageProvider(fullImageUrl);

      setState(() {
        _cachedImageProvider = imageProvider;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
    }

    if (_hasError || _cachedImageProvider == null) {
      return CircleAvatar(
        radius: 13,
        backgroundColor: const Color(0xFF1E3765),
        child: const Icon(Icons.person, size: 13, color: Colors.white),
      );
    }

    return CircleAvatar(
      radius: 13,
      backgroundImage: _cachedImageProvider,
      backgroundColor: const Color(0xFF1E3765),
    );
  }
}
