import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:so_tay_mon_an/Models/ingredient.dart';
import 'package:so_tay_mon_an/Models/ingredient_type.dart';
import 'package:so_tay_mon_an/Models/meal.dart';
import 'package:so_tay_mon_an/Models/meal_list_notifi.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Views/create_ingredient.dart';
import 'package:so_tay_mon_an/Views/edit_ingredient.dart';
import 'package:so_tay_mon_an/Views/ingredient_detail.dart';
import 'package:so_tay_mon_an/Widgets/profile_meal_listview.dart';

class IngredientManagementPage extends StatefulWidget {
  Users user;
  IngredientManagementPage({Key? key, required this.user}) : super(key: key);

  @override
  _IngredientManagementPageState createState() =>
      _IngredientManagementPageState();
}

class _IngredientManagementPageState extends State<IngredientManagementPage> {
  CollectionReference postRef = FirebaseFirestore.instance.collection('Meals');
  CollectionReference ingredientTypeRef =
      FirebaseFirestore.instance.collection('Ingredients_Type');

  List<Meal> listOfPosts = [];
  List<IngredientType> listOfIngreType = [];

  getlist() async {
    QuerySnapshot snapshot = await postRef.get();
    setState(() {
      listOfPosts += snapshot.docs.map((e) => Meal.fromDocument(e)).toList();
    });
    QuerySnapshot snapshotIngreType = await ingredientTypeRef.get();
    setState(() {
      listOfIngreType += snapshotIngreType.docs
          .map((e) => IngredientType.fromDocument(e))
          .toList();
    });
  }

  getNameFromIngredientTypeId(String id) {
    String result = '';
    for (IngredientType ingredientType in listOfIngreType) {
      if (ingredientType.idLoaiNguyenLieu.compareTo(id) == 0) {
        result = ingredientType.tenLoaiNguyenLieu;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> _selectedStream =
        FirebaseFirestore.instance.collection('Ingredients').snapshots();
    getlist();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          title: const Text("Quản lý nguyên liệu"),
          centerTitle: true,
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
                    : Fluttertoast.showToast(
                        msg: "Bạn đã bị cấm bởi admin");
              },
              icon: const Icon(FontAwesomeIcons.plusCircle),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: StreamBuilder(
              stream: _selectedStream,
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
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
                                  ingredient: ingre,
                                  currentUser: widget.user))),
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
                                              child: Text(ingre.tenNguyenLieu
                                                  .toString()),
                                            ),
                                            Container(
                                              width: 20,
                                              child: PopupMenuButton(
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
                                                            if (value ==
                                                                'ok') {}
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
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 215,
                                        height: 65,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(9)),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 3,
                                                offset: const Offset(0, 3),
                                              )
                                            ]),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8.0, 0, 0, 0),
                                          child: Text("Xuất xứ: " +
                                              ingre.xuatXu.toString() +
                                              "\n" +
                                              "Loại nguyên liệu: " +
                                              getNameFromIngredientTypeId(ingre
                                                  .loaiNguyenLieu
                                                  .toString()) +
                                              "\n" +
                                              "Đơn vị: " +
                                              ingre.donVi.toString()),
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
              }),
        ));
  }
}
