import 'package:flutter/material.dart';

class NavProfileImage extends StatelessWidget {
  const NavProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'profile-image',
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('assets/images/aubreydrakepfp.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}