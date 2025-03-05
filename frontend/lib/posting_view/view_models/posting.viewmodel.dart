import 'package:flutter/foundation.dart';

import 'package:utm_marketplace/posting_view/model/posting.model.dart';
import 'package:utm_marketplace/posting_view/repository/posting.repository.dart';

import 'package:utm_marketplace/shared/view_models/loading.viewmodel.dart';

class PostingViewModel extends LoadingViewModel {
  PostingViewModel({
    required this.repo,
  });

  final PostingRepository repo;

  PostingModel _postingModel = PostingModel();

  Item? _item;
  Item? get item => _item;
  set item(Item? value) {
    _item = value;
    notifyListeners();
  }

  Future<void> fetchData(String itemid) async {
    try {
      isLoading = true;

      _postingModel = await repo.fetchData(itemid);
      item = _postingModel.item;
    } catch (exc) {
      debugPrint('Error in fetchData : ${exc.toString()}');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
