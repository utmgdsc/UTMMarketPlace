import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:utm_marketplace/shared/components/navigation/nav_profile_image.component.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;

  const BottomNav({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        iconSize: 26,
        backgroundColor: const Color(0xFFE8E8E8),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const NavProfileImage(),
            activeIcon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
              ),
              child: const NavProfileImage(),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu_outlined),
            activeIcon: Icon(Icons.menu_open),
            label: '',
          ),
        ],
        onTap: (index) {
          if (index == currentIndex) return;
          
          switch (index) {
            case 0:
              context.replace('/profile/me');
              break;
            case 1:
              context.replace('/messages');
              break;
            case 2:
              context.replace('/marketplace');
              break;
            case 3:
              context.replace('/notifications');
              break;
            case 4:
              context.replace('/menu');
              break;
          }
        },
      ),
    );
  }
}