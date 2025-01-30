import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

import 'package:utm_marketplace/common/theme.dart';
import 'package:utm_marketplace/common/router.dart';

void main() {
  runApp(const MyApp());
}

// The main app widget, which initializes the app with the router and theme
// Router and theme are defined in the common/router.dart and common/theme.dart files
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UTM Marketplace',
      theme: appTheme,
      routerConfig: router,
    );
  }
}
