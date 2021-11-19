import 'package:flutter/cupertino.dart';
import 'package:so_tay_mon_an/Models/meal.dart';

class MealList with ChangeNotifier {
  List<Meal> data = [];

  MealList(this.data);

  deleteMeal(int index) {
    this.data.removeAt(index);
    notifyListeners();
  }

  addMeal(List<Meal> meals) {
    this.data = meals;
  }
}
