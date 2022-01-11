import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:so_tay_mon_an/Models/ingredient.dart';
import 'package:so_tay_mon_an/Models/ingredient_type.dart';
import 'package:so_tay_mon_an/Models/meal.dart';
import 'package:so_tay_mon_an/Models/meal_type.dart';
import 'package:provider/provider.dart';
import 'package:so_tay_mon_an/Models/meal_type_string.dart';
import 'package:so_tay_mon_an/Models/unit.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Views/edit_ingredient.dart';
import 'package:so_tay_mon_an/Views/ingredient_detail.dart';
import 'package:so_tay_mon_an/Views/meal_detail.dart';
import 'package:so_tay_mon_an/Widgets/circular_progress.dart';

class MealsListView extends StatefulWidget {
  Users user;
  MealsListView({Key? key, required this.user}) : super(key: key);

  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView> {
  CollectionReference ingreRef =
      FirebaseFirestore.instance.collection('Ingredients');
  CollectionReference ingredientTypeRef =
      FirebaseFirestore.instance.collection('Ingredients_Type');
  CollectionReference unitRef = FirebaseFirestore.instance.collection('Units');

  List<IngredientType> listOfIngreType = [];
  List<Unit> listOfUnit = [];

  getlist() async {
    QuerySnapshot snapshot = await ingredientTypeRef.get();
    QuerySnapshot unitSnapshot = await unitRef.get();
    setState(() {
      listOfIngreType +=
          snapshot.docs.map((e) => IngredientType.fromDocument(e)).toList();
      listOfUnit += unitSnapshot.docs.map((e) => Unit.fromDocument(e)).toList();
    });
  }

  deleteIngredient(String id) {
    ingreRef.doc(id).get().then((value) => value.reference.delete());
  }

  getNameFromIngredientTypeId(String id) {
    String result = '';
    for (IngredientType ingredientType in listOfIngreType) {
      if (ingredientType.idLoaiNguyenLieu.compareTo(id) == 0)
        result = ingredientType.tenLoaiNguyenLieu;
    }
    return result;
  }

  getNameFromUnitId(String id) {
    String result = '';
    for (Unit unit in listOfUnit) {
      if (unit.id.compareTo(id) == 0) result = unit.tenDonVi;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    getlist();
    final data = Provider.of<MealTypeString>(context).data;

    Stream<QuerySnapshot<Map<String, dynamic>>> _selectedStream =
        FirebaseFirestore.instance
            .collection('Ingredients')
            .where('loaiNguyenLieu', isEqualTo: data)
            .snapshots();

    return StreamBuilder(
        stream: _selectedStream,
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgress(),
            );
          }
          // print(snapshot.data!.docs.length);
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ingredients = snapshot.data!.docs[index];
              String hinhAnh = ingredients['hinhAnh'];
              Ingredient ingre = Ingredient.fromDocument(ingredients);
              bool isOwner = widget.user.id == ingre.nguoiDang;
              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => IngreDetailPage(
                            ingredient: ingre, currentUser: widget.user))),
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 158,
                            height: 120,
                            child: FittedBox(
                              fit: BoxFit.fill,
                              child: Image.network(
                                hinhAnh,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            child: Column(
                              children: [
                                Container(
                                  width: 215,
                                  height: 30,
                                  child: Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        width: 190,
                                        child: Text(
                                            ingre.tenNguyenLieu.toString()),
                                      ),
                                      Container(
                                        width: 20,
                                        child: isOwner
                                            ? PopupMenuButton(
                                                icon: Icon(
                                                    Icons.more_vert_sharp,
                                                    color: Colors.black),
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    child: TextButton(
                                                        onPressed: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                    context) =>
                                                                AlertDialog(
                                                              title: const Text(
                                                                  'Xóa thông báo'),
                                                              content: const Text(
                                                                  'Bạn có muốn xóa thông báo này không?'),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context,
                                                                          'notok'),
                                                                  child:
                                                                      const Text(
                                                                          "Hủy"),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        'ok');
                                                                  },
                                                                  child: Text(
                                                                      "Đồng ý"),
                                                                ),
                                                              ],
                                                            ),
                                                          ).then((value) {
                                                            if (value == 'ok') {
                                                              Navigator.pop(
                                                                  context);
                                                              deleteIngredient(ingre
                                                                  .idNguyenLieu
                                                                  .toString());
                                                            }
                                                          });
                                                        },
                                                        child: Text(
                                                            "Xóa bài viết")),
                                                    value: 1,
                                                  ),
                                                  PopupMenuItem(
                                                    child: TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                EditIngredientPage(
                                                                    ingredient:
                                                                        ingre,
                                                                    currentUser:
                                                                        widget
                                                                            .user),
                                                          ),
                                                        );
                                                      },
                                                      child: Text(
                                                          "Sửa bài viết"),
                                                    ),
                                                    value: 2,
                                                  ),
                                                ],
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 215,
                                  height: 65,
                                  decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(9)),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 3,
                                          offset: const Offset(0, 3),
                                        )
                                      ]),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                                    child: Text("Xuất xứ: " +
                                        ingre.xuatXu.toString() +
                                        "\n" +
                                        "Loại nguyên liệu: " +
                                        getNameFromIngredientTypeId(
                                            ingre.loaiNguyenLieu.toString()) +
                                        "\n" +
                                        "Đơn vị: " +
                                        getNameFromUnitId(
                                            ingre.donVi.toString())),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}
