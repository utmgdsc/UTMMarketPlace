import 'package:go_router/go_router.dart';
import 'package:utm_marketplace/login/view/login.dart';
import 'package:utm_marketplace/profile/view/profile.dart';
import 'package:utm_marketplace/item_listing/view/listing.view.dart';

// TODO: These are temporary imports for testing purposes, remove when no longer needed
import 'package:utm_marketplace/temp_view/view/temp_view.view.dart';
import 'package:utm_marketplace/temp_view/view_models/temp_model.viewmodel.dart';
import 'package:utm_marketplace/home/view/home.dart';

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
      path: '/item_listing',
      builder: (context, state) => const ListingView(),
    ),
    GoRoute(
      path: '/profile/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId'] ?? '';
        final isOwnProfile = userId == 'me';
        return Profile(userId: userId, isOwnProfile: isOwnProfile);
      },
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
