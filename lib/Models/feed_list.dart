import 'package:flutter/cupertino.dart';

import 'feed.dart';

class FeedList with ChangeNotifier {
  List<Feed> data = [];

  FeedList(this.data);

  deleteFeed(int index) {
    this.data.removeAt(index);
    notifyListeners();
  }

  addFeed(List<Feed> feeds) {
    this.data = feeds;
    notifyListeners();
  }
}
