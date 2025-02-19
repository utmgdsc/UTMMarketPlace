import 'package:get_it/get_it.dart';
import 'package:utm_marketplace/item_listing/repository/listing_repo.dart';
import 'package:utm_marketplace/messages/repository/message.repository.dart';
import 'package:utm_marketplace/notifications/repository/notification.repository.dart';
import 'package:utm_marketplace/menu/repository/menu.repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerFactory<ListingRepo>(() => ListingRepoImpl());
  locator.registerLazySingleton(() => MessageRepository());
  locator.registerLazySingleton(() => NotificationRepository());
  locator.registerLazySingleton(() => MenuRepository());
}
