import 'package:flutter/cupertino.dart';

class MealTypeString with ChangeNotifier {
  String data = 'Lẩu';
  MealTypeString(this.data);
  changeData(String data) {
    this.data = data;
    notifyListeners();
  }
}
