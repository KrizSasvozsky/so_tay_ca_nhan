import 'package:flutter/material.dart';

class ListUser with ChangeNotifier {
  List<Text> data = [Text("data")];

  changeData(List<Text> data) {
    this.data = data;
    notifyListeners();
  }
}
