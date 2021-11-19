import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:so_tay_mon_an/Models/ingredient.dart';
import 'package:so_tay_mon_an/Models/material.dart';
import 'package:so_tay_mon_an/Models/material_list.dart';
import 'package:so_tay_mon_an/Models/meal.dart';

class MaterialCard extends StatefulWidget {
  final Materials material;
  final int index;
  MaterialCard({Key? key, required this.material, required this.index})
      : super(key: key);

  @override
  State<MaterialCard> createState() => _MaterialCardState();
}

class _MaterialCardState extends State<MaterialCard> {
  CollectionReference postRef =
      FirebaseFirestore.instance.collection('Ingredients');
  CollectionReference materialRef =
      FirebaseFirestore.instance.collection('Material');
  Ingredient ingredients = Ingredient();
  @override
  void initState() {
    super.initState();
    postRef.doc(widget.material.idNguyenLieu).get().then((value) {
      setState(() {
        ingredients = Ingredient.fromDocument(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<MaterialList>(context);
    return GestureDetector(
      onLongPress: () {
        data.deleteMaterial(widget.index);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 3,
                offset: const Offset(0, 1),
              )
            ],
          ),
          child: Row(
            children: [
              Text(widget.material.soLuong.toString() +
                  " " +
                  ingredients.donVi.toString()),
              const SizedBox(
                width: 5,
              ),
              Text(ingredients.tenNguyenLieu.toString()),
            ],
          ),
        ),
      ),
    );
  }
}
