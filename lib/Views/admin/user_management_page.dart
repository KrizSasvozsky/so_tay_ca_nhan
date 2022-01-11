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
import 'package:so_tay_mon_an/Views/edit_ingredient.dart';
import 'package:so_tay_mon_an/Views/ingredient_detail.dart';
import 'package:so_tay_mon_an/Widgets/admin/delete_dialog_widget.dart';
import 'package:so_tay_mon_an/Widgets/admin/enums/delete_enums.dart';
import 'package:so_tay_mon_an/Widgets/profile_meal_listview.dart';
import 'package:so_tay_mon_an/Widgets/user_result.dart';

class UserManagementPage extends StatefulWidget {
  Users user;
  UserManagementPage({Key? key, required this.user}) : super(key: key);

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  CollectionReference userRef = FirebaseFirestore.instance.collection('Users');
  CollectionReference ingredientTypeRef =
      FirebaseFirestore.instance.collection('Ingredients_Type');

  updateUserPermission(String id, bool result) async {
    await userRef.doc(id).update({'banned': result});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> _selectedStream =
        FirebaseFirestore.instance.collection('Users').snapshots();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          title: const Text("Quản lý người dùng"),
          centerTitle: true,
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
                    DocumentSnapshot userDoc = snapshot.data!.docs[index];
                    Users user = Users.fromDocument(userDoc);
                    return GestureDetector(
                        onLongPress: () {
                          !user.banned!
                              ? showDialog(
                                      context: context,
                                      builder: (context) => DeleteDialog(
                                          deleteEnums: DeleteEnums.banUser))
                                  .then((value) {
                                  if (value == "ok" && !user.quyenHan!) {
                                    updateUserPermission(user.id!, true);
                                  } else {}
                                })
                              : showDialog(
                                      context: context,
                                      builder: (context) => DeleteDialog(
                                          deleteEnums: DeleteEnums.unbanUser))
                                  .then((value) {
                                  if (value == "ok" && !user.quyenHan!) {
                                    updateUserPermission(user.id!, false);
                                  } else {}
                                });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          alignment: Alignment.center,
                          child: widget.user.id != user.id
                              ? UserResult(
                                  user: user,
                                  currentUser: widget.user,
                                  isAdmin: true,
                                )
                              : Container(),
                        ));
                  },
                );
              }),
        ));
  }
}
