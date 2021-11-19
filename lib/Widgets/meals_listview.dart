import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:so_tay_mon_an/Models/meal.dart';
import 'package:so_tay_mon_an/Models/meal_type.dart';
import 'package:provider/provider.dart';
import 'package:so_tay_mon_an/Models/meal_type_string.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Views/meal_detail.dart';

class MealsListView extends StatefulWidget {
  Users user;
  MealsListView({Key? key, required this.user}) : super(key: key);

  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView> {
  @override
  Widget build(BuildContext context) {
    final data = Provider.of<MealTypeString>(context).data;
    Stream<QuerySnapshot<Map<String, dynamic>>> _selectedStream =
        FirebaseFirestore.instance
            .collection('Meals')
            .where('loaiMonAn', isEqualTo: data)
            .snapshots();
    return StreamBuilder(
        stream: _selectedStream,
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot meals = snapshot.data!.docs[index];
              String hinhAnh = meals['hinhAnh'];
              Meal meal = Meal.fromDocument(meals);
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealDetailPage(
                      meal: meal,
                      currentUser: widget.user,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      child: Row(children: [
                        SizedBox(
                          width: 158,
                          height: 120,
                          child: FittedBox(
                            fit: BoxFit.fill,
                            child: Image.network(
                              hinhAnh,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                          child: Column(
                            children: [
                              Container(
                                width: 215,
                                height: 25,
                                child: Row(
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      width: 190,
                                      child: Text(meal.tenMonAn.toString()),
                                    ),
                                    Container(
                                        height: 25,
                                        width: 25,
                                        alignment: Alignment.center,
                                        child: IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            FontAwesomeIcons.solidHeart,
                                            color: Colors.red,
                                            size: 15,
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                              Container(
                                width: 215,
                                height: 65,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(9)),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 3,
                                        offset: const Offset(0, 3),
                                      )
                                    ]),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                                  child: Text("Nguyên Liệu chính:\n" +
                                      meal.thanhPhan.toString()),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: SizedBox(
                                  width: 215,
                                  child: Row(
                                    children: [
                                      SmoothStarRating(
                                        rating: meal.doPhoBien,
                                        isReadOnly: true,
                                        size: 20,
                                        filledIconData: Icons.star,
                                        halfFilledIconData: Icons.star_half,
                                        defaultIconData: Icons.star_border,
                                        starCount: 5,
                                        allowHalfRating: false,
                                        spacing: 2.0,
                                        onRated: (value) {},
                                      ),
                                      Container(
                                          alignment: Alignment.topRight,
                                          width: 105,
                                          child: Text('Độ khó:' +
                                              meal.doKho.toString() +
                                              '/5')),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ]),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}
