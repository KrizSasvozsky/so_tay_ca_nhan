import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:so_tay_mon_an/Widgets/admin/enums/add_enums.dart';
import 'package:so_tay_mon_an/Widgets/admin/enums/update_enums.dart';
import 'package:uuid/uuid.dart';

class UpdateDialogWidget extends StatefulWidget {
  UpdateEnums updateEnums;
  final String id;
  UpdateDialogWidget({Key? key, required this.updateEnums, required this.id})
      : super(key: key);

  @override
  _UpdateDialogWidgetState createState() => _UpdateDialogWidgetState();
}

class _UpdateDialogWidgetState extends State<UpdateDialogWidget> {
  CollectionReference ingredientTypeRef =
      FirebaseFirestore.instance.collection('Ingredients_Type');

  CollectionReference unitRef = FirebaseFirestore.instance.collection('Units');
  CollectionReference mealTypeRef =
      FirebaseFirestore.instance.collection('meal_type');

  TextEditingController textEditingController = TextEditingController();

  handleUpdate() {
    switch (widget.updateEnums) {
      case UpdateEnums.updateIngredientType:
        updateIngredientsType();
        break;
      case UpdateEnums.updateUnit:
        updateIngredientsType();
        break;
      case UpdateEnums.updateMealType:
        updateMealType();
        break;
      default:
    }
  }

  updateIngredientsType() async {
    await ingredientTypeRef.doc(widget.id).update({
      "tenLoaiNguyenLieu": textEditingController.text,
    });
    textEditingController.clear();
  }

  updateUnit() async {
    await unitRef.doc(widget.id).update({
      "tenDonvi": textEditingController.text,
    });
    textEditingController.clear();
  }

  updateMealType() async {
    await mealTypeRef.doc(widget.id).update({
      "tenLoaiMonAn": textEditingController.text,
    });
    textEditingController.clear();
  }

  Widget usecaseTitle() {
    switch (widget.updateEnums) {
      case UpdateEnums.updateIngredientType:
        return const Text(
          "Hãy nhập tên loại nguyên liệu",
          style: TextStyle(color: Colors.purple),
        );
      case UpdateEnums.updateUnit:
        return const Text(
          "Hãy nhập tên đơn vị",
          style: TextStyle(color: Colors.purple),
        );
      case UpdateEnums.updateMealType:
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
      child: SizedBox(
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
                        handleUpdate();
                      }
                    },
                    child: const Text(
                      'Cập Nhật!',
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
