import 'package:flutter/services.dart';
import 'package:utm_marketplace/posting_view/model/posting.model.dart';

class PostingRepository {
  Future<PostingModel> fetchData(String itemid) async {
    await Future.delayed(const Duration(milliseconds: 1800));

    final resp =
        await rootBundle.loadString('assets/data/temp_listing_data.json');
    return postingModelFromJson(resp, itemid);
  }
}
