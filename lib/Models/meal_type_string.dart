import 'package:flutter/cupertino.dart';

class MealTypeString with ChangeNotifier {
  String data = '3kFIdPISzQuzpwJ98F3x';
  MealTypeString(this.data);
  changeData(String data) {
    this.data = data;
    notifyListeners();
  }
}
