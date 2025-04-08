import 'package:flutter/material.dart';

class NavProfileImage extends StatelessWidget {
  const NavProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 13,
      backgroundColor: const Color(0xFF11384A),
      child: const Icon(Icons.person, size: 13, color: Colors.white),
    );
  }
}
