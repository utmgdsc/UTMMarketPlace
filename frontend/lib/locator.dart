import 'package:get_it/get_it.dart';
import 'package:utm_marketplace/item_listing/repository/listing_repo.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerFactory<ListingRepo>(() => ListingRepoImpl());
}