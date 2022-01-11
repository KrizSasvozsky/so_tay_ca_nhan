import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:so_tay_mon_an/Widgets/admin/add_dialog_widget.dart';
import 'package:so_tay_mon_an/Widgets/admin/enums/add_enums.dart';
import 'package:so_tay_mon_an/Widgets/admin/delete_dialog_widget.dart';
import 'package:so_tay_mon_an/Widgets/admin/enums/delete_enums.dart';
import 'package:so_tay_mon_an/Widgets/admin/enums/update_enums.dart';
import 'package:so_tay_mon_an/Widgets/admin/update_dialog_widget.dart';

class MealTypeManagementPage extends StatefulWidget {
  MealTypeManagementPage({Key? key}) : super(key: key);

  @override
  _MealTypeManagementPageState createState() => _MealTypeManagementPageState();
}

class _MealTypeManagementPageState extends State<MealTypeManagementPage> {
  CollectionReference mealRef = FirebaseFirestore.instance.collection('Meals');
  CollectionReference mealTypeRef =
      FirebaseFirestore.instance.collection('meal_type');

  Future<bool> checkValidForDelete(String tenLoaiMonAn) async {
    List<String> listOfMealType = [];
    await mealRef.get().then((QuerySnapshot snapshotvalue) {
      snapshotvalue.docs.forEach((f) => {listOfMealType.add(f['loaiMonAn'])});
    });
    if (listOfMealType.isEmpty) {
      return true;
    }
    for (String mealType in listOfMealType) {
      if (mealType.compareTo(tenLoaiMonAn) == 0) {
        return false;
      }
    }
    return true;
  }

  deleteMealType(String id) {
    mealTypeRef.doc(id).get().then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> _selectedStream =
        FirebaseFirestore.instance.collection('meal_type').snapshots();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          title: const Text("Quản lý loại món ăn"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AddDialogWidget(
                        addEnums: AddEnums.addMealType,
                      )),
              icon: const Icon(FontAwesomeIcons.plusCircle),
            ),
          ],
        ),
        body: StreamBuilder(
            stream: _selectedStream,
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot mealType = snapshot.data!.docs[index];
                  return GestureDetector(
                    onLongPress: () async {
                      if (await checkValidForDelete(mealType['id'])) {
                        showDialog(
                            context: context,
                            builder: (context) => DeleteDialog(
                                  deleteEnums: DeleteEnums.deleteMealType,
                                )).then((value) {
                          if (value == "ok") {
                            deleteMealType(mealType['id']);
                          }
                        });
                      } else {
                        Fluttertoast.showToast(
                            msg: "loại món ăn đã tồn tại trong món ăn");
                      }
                    },
                    onDoubleTap: () => showDialog(
                        context: context,
                        builder: (context) => UpdateDialogWidget(
                            updateEnums: UpdateEnums.updateMealType,
                            id: mealType['id'])),
                    child: Card(
                      color: Colors.white,
                      child: Center(
                        child: Text(mealType['tenLoaiMonAn']),
                      ),
                    ),
                  );
                },
              );
            }));
  }
}
