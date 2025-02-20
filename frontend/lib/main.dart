import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:utm_marketplace/shared/themes/theme.dart';
import 'package:utm_marketplace/shared/routes/routes.dart';
import 'package:utm_marketplace/item_listing/repository/listing_repo.dart';
import 'package:utm_marketplace/item_listing/view_models/listing.viewmodel.dart';
import 'package:utm_marketplace/locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupLocator();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ListingViewModel(repo: locator<ListingRepo>()),
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
