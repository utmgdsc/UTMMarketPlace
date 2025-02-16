import 'package:flutter/services.dart';
import 'package:utm_marketplace/item_listing/model/listing.model.dart';

abstract class ListingRepo {
  Future<ListingModel> fetchData();
}

class ListingRepoImpl extends ListingRepo {
  @override
  Future<ListingModel> fetchData() async {
    await Future.delayed(const Duration(milliseconds: 1800));

    final resp =
        await rootBundle.loadString('assets/data/temp_listing_data.json');
    return listingModelFromJson(resp);
  }
}
