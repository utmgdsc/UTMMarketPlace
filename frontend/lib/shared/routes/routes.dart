import 'package:go_router/go_router.dart';
import 'package:utm_marketplace/login/view/login.view.dart';
import 'package:utm_marketplace/profile/view/profile.view.dart';
import 'package:utm_marketplace/item_listing/view/listing.view.dart';
import 'package:utm_marketplace/posting_view/view/posting.view.dart';

import 'package:utm_marketplace/shared/components/shell/shell.layout.dart';
import 'package:utm_marketplace/messages/view/messages.view.dart';
import 'package:utm_marketplace/messages/view/conversation_detail.view.dart';
import 'package:utm_marketplace/notifications/view/notifications.view.dart';
import 'package:utm_marketplace/menu/view/menu.view.dart';
import 'package:utm_marketplace/create_listing/view/create_listing.view.dart';
import 'package:utm_marketplace/signup/view/signup.view.dart';
import 'package:utm_marketplace/saved_items/view/saved_items.view.dart';

final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const Login(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUp(),
    ),
    GoRoute(
      path: '/create-listing',
      builder: (context, state) => const CreateListingView(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.path;
        int currentIndex;

        if (location.startsWith('/profile')) {
          currentIndex = 0;
        } else if (location.startsWith('/messages')) {
          currentIndex = 1;
        } else if (location.startsWith('/marketplace')) {
          currentIndex = 2;
        } else if (location.startsWith('/notifications')) {
          currentIndex = 3;
        } else {
          currentIndex = 4;
        }

        return ShellLayout(
          currentIndex: currentIndex,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/marketplace',
          builder: (context, state) => const ListingView(),
        ),
        GoRoute(
          path: '/profile/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId'] ?? '';
            final isOwnProfile = userId == 'me';
            return Profile(
              userId: userId,
              isOwnProfile: isOwnProfile,
            );
          },
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessagesView(),
        ),
        GoRoute(
          path: '/messages/:conversationId',
          builder: (context, state) {
            final conversationId = state.pathParameters['conversationId'] ?? '';
            return ConversationDetailView(
              conversationId: conversationId,
            );
          },
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsView(),
        ),
        GoRoute(
          path: '/menu',
          builder: (context, state) => const MenuView(),
        ),
        GoRoute(
          path: '/item/:itemId',
          builder: (context, state) {
            final itemId = state.pathParameters['itemId'] ?? '';
            return PostingView(itemId: itemId);
          },
        ),
        GoRoute(
          path: '/saved-items',
          builder: (context, state) => const SavedItemsView(),
        ),
      ],
    ),
  ],
);
