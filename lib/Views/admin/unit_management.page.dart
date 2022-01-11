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

class UnitManagementPage extends StatefulWidget {
  UnitManagementPage({Key? key}) : super(key: key);

  @override
  _UnitManagementPageState createState() => _UnitManagementPageState();
}

class _UnitManagementPageState extends State<UnitManagementPage> {
  CollectionReference ingredientRef =
      FirebaseFirestore.instance.collection('Ingredients');
  CollectionReference ingredientTypeRef =
      FirebaseFirestore.instance.collection('Ingredients_Type');
  CollectionReference unitRef = FirebaseFirestore.instance.collection('Units');

  Future<bool> checkValidForDelete(String unitName) async {
    List<String> listOfIngredientType = [];
    await ingredientRef.get().then((QuerySnapshot snapshotvalue) {
      snapshotvalue.docs.forEach((f) => {listOfIngredientType.add(f['donVi'])});
    });
    if (listOfIngredientType.isEmpty) {
      return true;
    }

    for (String unit in listOfIngredientType) {
      if (unit.compareTo(unitName) == 0) {
        return false;
      }
    }
    return true;
  }

  deleteUnit(String id) {
    unitRef.doc(id).get().then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> _selectedStream =
        FirebaseFirestore.instance.collection('Units').snapshots();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          title: const Text("Quản lý đơn vị"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AddDialogWidget(
                        addEnums: AddEnums.addUnit,
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
                  DocumentSnapshot unit = snapshot.data!.docs[index];
                  return GestureDetector(
                    onLongPress: () async {
                      if (await checkValidForDelete(unit['id'])) {
                        showDialog(
                            context: context,
                            builder: (context) => DeleteDialog(
                                  deleteEnums: DeleteEnums.deleteUnit,
                                )).then((value) {
                          if (value == "ok") {
                            deleteUnit(unit['id']);
                          }
                        });
                      } else {
                        Fluttertoast.showToast(
                            msg: "Đơn vị đã tồn tại trong nguyên liệu");
                      }
                    },
                    onDoubleTap: () => showDialog(
                        context: context,
                        builder: (context) => UpdateDialogWidget(
                            updateEnums: UpdateEnums.updateUnit,
                            id: unit['id'])),
                    child: Card(
                      color: Colors.white,
                      child: Center(
                        child: Text(unit['tenDonVi']),
                      ),
                    ),
                  );
                },
              );
            }));
  }
}
