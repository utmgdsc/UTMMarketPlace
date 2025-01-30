import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';

import 'package:utm_marketplace/common/theme.dart';
import 'package:utm_marketplace/views/login.dart';

// TODO: These are just for testing, remove when done/replace with actual views
import 'package:utm_marketplace/views/model_view.dart';
import 'package:utm_marketplace/models/model.dart';

void main() {
  runApp(const MyApp());
}

GoRouter router() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const Login(),
      ),
      GoRoute(
        path: '/temp_view',
        builder: (context, state) => ModelView(model: Model(attribute1: 'Attribute 1', attribute2: 2)),
      ),
    ],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UTM Marketplace',
      theme: appTheme,
      routerConfig: router(),
    );
  }
}
