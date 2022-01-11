import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:so_tay_mon_an/Widgets/admin/enums/add_enums.dart';
import 'package:so_tay_mon_an/Widgets/admin/enums/delete_enums.dart';
import 'package:uuid/uuid.dart';

class DeleteDialog extends StatefulWidget {
  DeleteEnums deleteEnums;
  DeleteDialog({Key? key, required this.deleteEnums}) : super(key: key);

  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  CollectionReference ingredientTypeRef =
      FirebaseFirestore.instance.collection('Ingredients_Type');

  TextEditingController textEditingController = TextEditingController();

  Widget usecaseTitle() {
    switch (widget.deleteEnums) {
      case DeleteEnums.deleteIngredientType:
        return const Text(
          "bạn có muốn xóa loại nguyên liệu này?",
          style: TextStyle(color: Colors.purple),
        );
      case DeleteEnums.banUser:
        return const Text(
          "bạn có muốn cấm người dùng này?",
          style: TextStyle(color: Colors.purple),
        );
      case DeleteEnums.unbanUser:
        return const Text(
          "bạn có muốn hủy cấm người dùng này?",
          style: TextStyle(color: Colors.purple),
        );
      case DeleteEnums.deleteUnit:
        return const Text(
          "bạn có muốn xóa đơn vị này?",
          style: TextStyle(color: Colors.purple),
        );
      case DeleteEnums.deleteMealType:
        return const Text(
          "bạn có muốn xóa loại món ăn này?",
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
        height: 200.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            usecaseTitle(),
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
                      Navigator.of(context).pop("ok");
                    },
                    child: const Text(
                      'Đồng ý!',
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
