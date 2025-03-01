import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:utm_marketplace/posting_view/model/posting.model.dart';

abstract class PostingRepo {
  Future<PostingModel> fetchData(String itemid);
}

class PostingRepoImpl extends PostingRepo {
  @override
  Future<PostingModel> fetchData(String itemid) async {
    await Future.delayed(const Duration(milliseconds: 1800));

    final resp =
        await rootBundle.loadString('assets/data/temp_listing_data.json');
    final List<dynamic> data = json.decode(resp);

    final item = data.firstWhere((element) => element['itemid'] == itemid, orElse: () => null);
    if (item != null) {
      return PostingModel.fromJson(item);
    } else {
      throw Exception('Item not found');
    }
  }
}
