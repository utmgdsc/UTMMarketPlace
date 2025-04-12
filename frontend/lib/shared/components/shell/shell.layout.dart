import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utm_marketplace/shared/components/navigation/bottom_nav.component.dart';
import 'package:utm_marketplace/profile/view_models/profile.viewmodel.dart';

class ShellLayout extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const ShellLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  State<ShellLayout> createState() => _ShellLayoutState();
}

class _ShellLayoutState extends State<ShellLayout> {
  @override
  void initState() {
    super.initState();
    // Fetch user profile data when the shell layout is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileViewModel = context.read<ProfileViewModel>();
      profileViewModel.fetchUserProfileById('me');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNav(currentIndex: widget.currentIndex),
    );
  }
}
