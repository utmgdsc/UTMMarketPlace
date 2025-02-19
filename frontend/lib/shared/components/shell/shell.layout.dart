import 'package:flutter/material.dart';
import 'package:utm_marketplace/shared/components/navigation/bottom_nav.component.dart';

class ShellLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const ShellLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNav(currentIndex: currentIndex),
    );
  }
}