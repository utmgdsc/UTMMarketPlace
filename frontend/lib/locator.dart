import 'package:get_it/get_it.dart';
import 'package:utm_marketplace/item_listing/repository/listing_repo.dart';
import 'package:utm_marketplace/messages/repository/message.repository.dart';
import 'package:utm_marketplace/notifications/repository/notification.repository.dart';
import 'package:utm_marketplace/menu/repository/menu.repository.dart';
import 'package:utm_marketplace/posting_view/repository/posting.repository.dart';
import 'package:utm_marketplace/profile/repository/profile.repository.dart';
import 'package:utm_marketplace/create_listing/repository/create_listing.repository.dart';
import 'package:utm_marketplace/saved_items/repository/saved_items.repository.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // locator.registerFactory<ListingRepo>(() => ListingRepoImpl());
  // locator.registerFactory<PostingRepository>(() => PostingRepositoryImpl());
  locator.registerLazySingleton(() => MessageRepository());
  locator.registerLazySingleton(() => NotificationRepository());
  locator.registerLazySingleton(() => MenuRepository());
  locator.registerLazySingleton(() => ProfileRepository());
  locator.registerLazySingleton(() => PostingRepository());
  locator.registerLazySingleton(() => CreateListingRepository());
  locator.registerLazySingleton(() => SavedItemsRepository());
  locator.registerLazySingleton(() => ListingRepo());
}
