import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:so_tay_mon_an/Widgets/admin/add_dialog_widget.dart';
import 'package:so_tay_mon_an/Widgets/admin/enums/add_enums.dart';
import 'package:so_tay_mon_an/Widgets/admin/delete_dialog_widget.dart';
import 'package:so_tay_mon_an/Widgets/admin/enums/delete_enums.dart';
import 'package:so_tay_mon_an/Widgets/admin/enums/update_enums.dart';
import 'package:so_tay_mon_an/Widgets/admin/update_dialog_widget.dart';

class IngredientTypeManagementPage extends StatefulWidget {
  IngredientTypeManagementPage({Key? key}) : super(key: key);

  @override
  _IngredientTypeManagementPageState createState() =>
      _IngredientTypeManagementPageState();
}

class _IngredientTypeManagementPageState
    extends State<IngredientTypeManagementPage> {
  CollectionReference ingredientRef =
      FirebaseFirestore.instance.collection('Ingredients');
  CollectionReference ingredientTypeRef =
      FirebaseFirestore.instance.collection('Ingredients_Type');

  Future<bool> checkValidForDelete(String ingredientName) async {
    List<String> listOfIngredientType = [];
    await ingredientRef.get().then((QuerySnapshot snapshotvalue) {
      snapshotvalue.docs
          .forEach((f) => {listOfIngredientType.add(f['loaiNguyenLieu'])});
    });
    if (listOfIngredientType.isEmpty) {
      return true;
    }
    for (String ingre in listOfIngredientType) {
      if (ingre.compareTo(ingredientName) == 0) {
        return false;
      }
    }
    return true;
  }

  deleteIngredientType(String id) {
    ingredientTypeRef.doc(id).get().then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> _selectedStream =
        FirebaseFirestore.instance.collection('Ingredients_Type').snapshots();
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          title: const Text("Quản lý loại nguyên liệu"),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AddDialogWidget(
                        addEnums: AddEnums.addIngredientType,
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
                  DocumentSnapshot ingreType = snapshot.data!.docs[index];
                  return GestureDetector(
                    onLongPress: () async {
                      if (await checkValidForDelete(
                          ingreType['tenLoaiNguyenLieu'])) {
                        showDialog(
                            context: context,
                            builder: (context) => DeleteDialog(
                                  deleteEnums: DeleteEnums.deleteIngredientType,
                                )).then((value) {
                          if (value == "ok") {
                            deleteIngredientType(ingreType['idLoaiNguyenLieu']);
                          }
                        });
                      }
                    },
                    onDoubleTap: () => showDialog(
                        context: context,
                        builder: (context) => UpdateDialogWidget(
                            updateEnums: UpdateEnums.updateIngredientType,
                            id: ingreType['idLoaiNguyenLieu'])),
                    child: Card(
                      color: Colors.white,
                      child: Center(
                        child: Text(ingreType['tenLoaiNguyenLieu']),
                      ),
                    ),
                  );
                },
              );
            }));
  }
}
