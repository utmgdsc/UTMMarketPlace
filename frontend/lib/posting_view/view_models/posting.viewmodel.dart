import 'package:flutter/foundation.dart';

import 'package:utm_marketplace/posting_view/model/posting.model.dart';
import 'package:utm_marketplace/posting_view/repository/posting_repo.dart';

import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class PostingViewModel extends LoadingViewModel {
  PostingViewModel({
    required this.repo,
  });

  final PostingRepo repo;

  PostingModel _postingModel = PostingModel();

  List<Item> _items = [];
  List<Item> get items => _items;
  set items(List<Item> value) {
    _items = value;
    notifyListeners();
  }

  Future<void> fetchData(String itemid) async {
    try {
      isLoading = true;

      _postingModel = await repo.fetchData(itemid);
      items = _postingModel.items;
    } catch (exc) {
      debugPrint('Error in fetchData : ${exc.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
