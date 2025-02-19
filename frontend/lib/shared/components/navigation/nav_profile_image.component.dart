import 'package:flutter/material.dart';

class NavProfileImage extends StatelessWidget {
  const NavProfileImage({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 13,
      backgroundImage: const AssetImage('assets/images/aubreydrakepfp.jpg'),
    );
  }
}