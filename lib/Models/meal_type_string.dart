import 'package:flutter/cupertino.dart';

class MealTypeString with ChangeNotifier {
  String data = 'Lẩu';

  changeData(String data) {
    this.data = data;
    notifyListeners();
  }
}
