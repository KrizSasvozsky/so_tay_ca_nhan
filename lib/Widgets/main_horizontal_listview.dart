import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
        FirebaseFirestore.instance.collection('meal_type').snapshots();
    final data = Provider.of<MealTypeString>(context);
    MealType _mealType = MealType("id", "hinhAnh", "tenLoaiMonAn");
    return Container(
      margin: const EdgeInsets.fromLTRB(13, 88, 0, 0),
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
                DocumentSnapshot mealType = snapshot.data!.docs[index];
                String hinhAnh = mealType['hinhAnh'];
                return Row(
                  children: [
                    Container(
                      width: 62,
                      height: 78,
                      decoration: BoxDecoration(
                          color: _selectedIndex == index
                              ? Colors.amber
                              : Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6))),
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedIndex = index;
                                _mealType = MealType(
                                    mealType['id'],
                                    mealType['hinhAnh'],
                                    mealType['tenLoaiMonAn']);
                                data.changeData(mealType['tenLoaiMonAn']);
                              });
                            },
                            icon: Image.asset('assets/images/$hinhAnh'),
                          ),
                          Text(mealType['tenLoaiMonAn']),
                        ],
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
