import 'package:utm_marketplace/create_listing/model/create_listing.model.dart';

class CreateListingRepository {
  Future<bool> createListing(CreateListingModel listing) async {
    // TODO: Implement API call to create listing
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
