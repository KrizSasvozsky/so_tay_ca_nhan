import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/meal.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Views/meal_detail.dart';

class ProfileMeal extends StatelessWidget {
  Meal meal;
  Users currentUser;
  ProfileMeal({Key? key, required this.meal, required this.currentUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => MealDetailPage(
                      meal: meal,
                      currentUser: currentUser,
                    )));
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 4,
        height: MediaQuery.of(context).size.width / 4,
        child: Image(
          image: CachedNetworkImageProvider(meal.hinhAnh.toString()),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
