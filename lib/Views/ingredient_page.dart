import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:so_tay_mon_an/Models/meal_type_string.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Views/create_ingredient.dart';
import 'package:so_tay_mon_an/Widgets/main_horizontal_listview.dart';
import 'package:so_tay_mon_an/Widgets/meals_listview.dart';

class IngredientPage extends StatefulWidget {
  Users user;
  IngredientPage({Key? key, required this.user}) : super(key: key);

  @override
  _IngredientPageState createState() => _IngredientPageState();
}

class _IngredientPageState extends State<IngredientPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text("Nguyên Liệu"),
        actions: [
          IconButton(
            onPressed: () {
              !widget.user.banned!
                  ? Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateIngredientPage(
                          currentUser: widget.user,
                        ),
                      ),
                    )
                  : Fluttertoast.showToast(msg: "Bạn đã bị cấm bởi admin");
            },
            icon: const Icon(FontAwesomeIcons.plusCircle),
          ),
        ],
      ),
      body: ChangeNotifierProvider(
        create: (context) => MealTypeString("3kFIdPISzQuzpwJ98F3x"),
        child: Column(
          children: [
            MainHorizontalListView(),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 40 - 183,
                child: Container(
                  color: Colors.black,
                  child: MealsListView(user: widget.user),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
