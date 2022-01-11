import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/ingredient.dart';
import 'package:so_tay_mon_an/Models/meal_type.dart';
import 'package:provider/provider.dart';
import 'package:so_tay_mon_an/Models/meal_type_string.dart';

class MainHorizontalListView extends StatefulWidget {
  MainHorizontalListView({Key? key}) : super(key: key);

  @override
  _MainHorizontalListViewState createState() => _MainHorizontalListViewState();
}

class _MainHorizontalListViewState extends State<MainHorizontalListView> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> _selectedStream =
        FirebaseFirestore.instance.collection('Ingredients_Type').snapshots();
    final data = Provider.of<MealTypeString>(context);
    Ingredient _ingredient = Ingredient();
    return Container(
      margin: const EdgeInsets.fromLTRB(15, 15, 0, 0),
      height: 78,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(6))),
      child: StreamBuilder(
          stream: _selectedStream,
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot ingre = snapshot.data!.docs[index];
                return Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                          data.changeData(ingre['idLoaiNguyenLieu']);
                        });
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                            color: _selectedIndex == index
                                ? Colors.amber
                                : Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6))),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              ingre['tenLoaiNguyenLieu'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    )
                  ],
                );
              },
            );
          }),
    );
  }
}
