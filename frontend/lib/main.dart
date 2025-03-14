import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utm_marketplace/shared/themes/theme.dart';
import 'package:utm_marketplace/shared/routes/routes.dart';
import 'package:utm_marketplace/item_listing/repository/listing_repo.dart';
import 'package:utm_marketplace/item_listing/view_models/listing.viewmodel.dart';
import 'package:utm_marketplace/locator.dart';
import 'package:utm_marketplace/messages/repository/message.repository.dart';
import 'package:utm_marketplace/messages/view_models/message.viewmodel.dart';
import 'package:utm_marketplace/notifications/repository/notification.repository.dart';
import 'package:utm_marketplace/notifications/view_models/notification.viewmodel.dart';
import 'package:utm_marketplace/menu/repository/menu.repository.dart';
import 'package:utm_marketplace/menu/view_models/menu.viewmodel.dart';
import 'package:utm_marketplace/profile/repository/profile.repository.dart';
import 'package:utm_marketplace/profile/view_models/profile.viewmodel.dart';
import 'package:utm_marketplace/posting_view/repository/posting.repository.dart';
import 'package:utm_marketplace/posting_view/view_models/posting.viewmodel.dart';
import 'package:utm_marketplace/create_listing/repository/create_listing.repository.dart';
import 'package:utm_marketplace/create_listing/view_models/create_listing.viewmodel.dart';
import 'package:utm_marketplace/signup/view_models/signup.viewmodel.dart';
import 'package:utm_marketplace/shared/dio/dio.dart';
import 'package:utm_marketplace/saved_items/view_models/saved_items.viewmodel.dart';
import 'package:utm_marketplace/saved_items/repository/saved_items.repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();
  configureDio();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SignUpViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ListingViewModel(repo: locator<ListingRepo>()),
        ),
        ChangeNotifierProvider(
          create: (_) => MessageViewModel(repo: locator<MessageRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              NotificationViewModel(repo: locator<NotificationRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => MenuViewModel(repo: locator<MenuRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(repo: locator<ProfileRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => PostingViewModel(repo: locator<PostingRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CreateListingViewModel(repo: locator<CreateListingRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SavedItemsViewModel(repo: locator<SavedItemsRepository>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

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
