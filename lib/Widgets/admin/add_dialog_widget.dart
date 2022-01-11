import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:so_tay_mon_an/Widgets/admin/enums/add_enums.dart';
import 'package:uuid/uuid.dart';

class AddDialogWidget extends StatefulWidget {
  AddEnums addEnums;
  AddDialogWidget({Key? key, required this.addEnums}) : super(key: key);

  @override
  _AddDialogWidgetState createState() => _AddDialogWidgetState();
}

class _AddDialogWidgetState extends State<AddDialogWidget> {
  CollectionReference ingredientTypeRef =
      FirebaseFirestore.instance.collection('Ingredients_Type');
  CollectionReference unitRef = FirebaseFirestore.instance.collection('Units');
  CollectionReference mealTypeRef =
      FirebaseFirestore.instance.collection('meal_type');

  TextEditingController textEditingController = TextEditingController();

  handleAdd() {
    switch (widget.addEnums) {
      case AddEnums.addIngredientType:
        addIngredientsType();
        break;
      case AddEnums.addUnit:
        addUnit();
        break;
      case AddEnums.addMealType:
        addMealType();
        break;
      default:
    }
  }

  addIngredientsType() async {
    String postID = const Uuid().v4();
    await ingredientTypeRef.doc(postID).set({
      "idLoaiNguyenLieu": postID,
      "tenLoaiNguyenLieu": textEditingController.text,
    });
    textEditingController.clear();
  }

  addUnit() async {
    String postID = const Uuid().v4();
    await unitRef.doc(postID).set({
      "id": postID,
      "tenDonVi": textEditingController.text,
    });
    textEditingController.clear();
  }

  addMealType() async {
    String postID = const Uuid().v4();
    await mealTypeRef.doc(postID).set({
      "id": postID,
      "tenLoaiMonAn": textEditingController.text,
    });
    textEditingController.clear();
  }

  Widget usecaseTitle() {
    switch (widget.addEnums) {
      case AddEnums.addIngredientType:
        return const Text(
          "Hãy nhập tên loại nguyên liệu",
          style: TextStyle(color: Colors.purple),
        );
      case AddEnums.addUnit:
        return const Text(
          "Hãy nhập tên đơn vị",
          style: TextStyle(color: Colors.purple),
        );
      case AddEnums.addMealType:
        return const Text(
          "Hãy nhập tên loại món ăn",
          style: TextStyle(color: Colors.purple),
        );
      default:
    }
    return const Text("404 Not Found!");
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        height: 250.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            usecaseTitle(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: textEditingController,
              ),
            ),
            const Padding(padding: EdgeInsets.only(top: 50.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop("fail");
                    },
                    child: const Text(
                      'Hủy!',
                      style: TextStyle(color: Colors.red, fontSize: 18.0),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if (textEditingController.text.trim().isEmpty) {
                        Fluttertoast.showToast(
                            msg: "Vui lập nhập thông tin!",
                            textColor: Colors.black,
                            backgroundColor: Colors.amber);
                      } else {
                        handleAdd();
                      }
                    },
                    child: const Text(
                      'Thêm!',
                      style: TextStyle(color: Colors.blue, fontSize: 18.0),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
