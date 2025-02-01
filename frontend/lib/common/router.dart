import 'package:go_router/go_router.dart';
import 'package:utm_marketplace/views/login.dart';
import 'package:utm_marketplace/views/profile.dart';

// TODO: These are temporary imports for testing purposes, remove when no longer needed
import 'package:utm_marketplace/views/model_view.dart';
import 'package:utm_marketplace/models/model.dart';
import 'package:utm_marketplace/views/home.dart';

// Define the router as a top-level global variable
final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const Login(),
    ),
    GoRoute(
      path: '/temp_view',
      builder: (context, state) =>
          ModelView(model: Model(attribute1: 'Attribute 1', attribute2: 2)),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const Profile(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);

