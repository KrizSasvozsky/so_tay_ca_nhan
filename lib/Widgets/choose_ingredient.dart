import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:so_tay_mon_an/Models/ingredient.dart';
import 'package:so_tay_mon_an/Models/material.dart';
import 'package:uuid/uuid.dart';

class ChooseIngredientDialog extends StatefulWidget {
  List<String> listIngredientName;
  ChooseIngredientDialog({Key? key, required this.listIngredientName})
      : super(key: key);

  @override
  State<ChooseIngredientDialog> createState() => _ChooseIngredientDialogState();
}

class _ChooseIngredientDialogState extends State<ChooseIngredientDialog> {
  TextEditingController soluongController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<String> searchResult = [];

  @override
  void initState() {
    // TODO: implement initState
    searchResult = widget.listIngredientName;
    super.initState();
  }

  filter(String keyword) {
    List<String> results = [];
    if (keyword.isEmpty) {
      results = widget.listIngredientName;
    } else {
      results = widget.listIngredientName
          .where((element) =>
              element.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }
    setState(() {
      searchResult = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: ListView(
          children: [
            Container(
              height: 572,
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 300,
                      height: 40,
                      color: Colors.amber,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.search,
                              size: 17,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 8.0,
                                right: 8.0,
                              ),
                              child: Container(
                                width: 230,
                                color: Colors.white,
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (value) => filter(value),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => searchController.clear(),
                              child: const Icon(
                                FontAwesomeIcons.backspace,
                                size: 17,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 300,
                    height: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GridView.builder(
                      itemCount: searchResult.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemBuilder: (context, index) {
                        return ingredientCard(searchResult[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: soluongController,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(
                        hintText: "Số lượng",
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Hủy!',
                        style: TextStyle(color: Colors.purple, fontSize: 18.0),
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ingredientCard(String name) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Ingredients')
            .where('tenNguyenLieu', isEqualTo: name)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          DocumentSnapshot ingre = snapshot.data!.docs[0];

          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 3,
                        offset: const Offset(0, 3),
                      )
                    ]),
                child: TextButton(
                    onPressed: () {
                      if (soluongController.text.isEmpty) {
                        Fluttertoast.showToast(msg: "Vui lòng nhập số lượng!");
                      } else {
                        String thanhPhanID = const Uuid().v4();
                        Materials materials = Materials(
                            idThanhPhan: thanhPhanID,
                            soLuong: int.parse(soluongController.text),
                            idNguyenLieu: ingre['idNguyenLieu']);

                        Navigator.of(context).pop(materials);
                      }
                    },
                    child: Text(
                      name,
                      style: TextStyle(color: Colors.black),
                    )),
              ),
            ),
          );
        });
  }
}
