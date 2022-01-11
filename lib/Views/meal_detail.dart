import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:so_tay_mon_an/Models/ingredient.dart';
import 'package:so_tay_mon_an/Models/material.dart';
import 'package:so_tay_mon_an/Models/meal.dart';
import 'package:so_tay_mon_an/Models/meal_type.dart';
import 'package:so_tay_mon_an/Models/unit.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Widgets/comments.dart';
import 'package:timeago/timeago.dart' as timeago;

class MealDetailPage extends StatefulWidget {
  Meal meal;
  Users currentUser;

  MealDetailPage({Key? key, required this.meal, required this.currentUser})
      : super(key: key);

  @override
  _MealDetailPageState createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  CollectionReference postRef = FirebaseFirestore.instance.collection('Meals');
  CollectionReference materialRef =
      FirebaseFirestore.instance.collection('Material');
  CollectionReference ingredientRef =
      FirebaseFirestore.instance.collection('Ingredients');
  CollectionReference mealTypeRef =
      FirebaseFirestore.instance.collection('meal_type');
  CollectionReference unitRef = FirebaseFirestore.instance.collection('Units');

  List<MealType> listOfMealType = [];
  List<Unit> listOfUnit = [];

  DateTime date = DateTime.now();
  Users user = Users(
      banned: false,
      bio: "loading",
      email: "loading",
      hinhAnh: "loading",
      id: "loading",
      quyenHan: false,
      username: "loading");
  int soLuotThich = 0;
  bool isLiked = false;
  bool showHeart = false;
  String thanhPhan = '';

  @override
  void initState() {
    generateUser(widget.meal.nguoiDang.toString());
    checkLike();
    setState(() {
      date = widget.meal.ngayDang.toDate();
    });
    super.initState();
  }

  getlist() async {
    QuerySnapshot mealTypeSnapshot = await mealTypeRef.get();
    QuerySnapshot unitSnapshot = await unitRef.get();
    setState(() {
      listOfMealType +=
          mealTypeSnapshot.docs.map((e) => MealType.fromDocument(e)).toList();
      listOfUnit += unitSnapshot.docs.map((e) => Unit.fromDocument(e)).toList();
    });
  }

  getNameFromMealTypeId(String id) {
    String result = '';
    for (MealType mealType in listOfMealType) {
      if (mealType.id.compareTo(id) == 0) result = mealType.tenLoaiMonAn;
    }
    return result;
  }

  getNameFromUnitId(String id) {
    String result = '';
    for (Unit unit in listOfUnit) {
      if (unit.id.compareTo(id) == 0) result = unit.tenDonVi;
    }
    return result;
  }

  generateUser(String id) async {
    var document = FirebaseFirestore.instance.collection('Users').doc(id);
    await document.get().then((value) {
      setState(() {
        user = Users(
            id: id,
            bio: value['bio'],
            email: value['email'],
            hinhAnh: value['hinhAnh'],
            quyenHan: value['quyenHan'],
            username: value['username'],
            banned: value['banned']);
      });
    });
  }

  checkLike() async {
    Map<String, dynamic> map = Map.from(widget.meal.luotYeuThich);
    if (map.containsKey(widget.currentUser.id) && map[widget.currentUser.id]) {
      setState(() {
        isLiked = true;
      });
    }
  }

  handleLikeMeal() {
    String currentID = widget.currentUser.id.toString();
    if (isLiked) {
      postRef.doc(widget.meal.id).update({'luotYeuThich.$currentID': false});
      setState(() {
        soLuotThich -= 1;
        isLiked = false;
        widget.meal.luotYeuThich[widget.currentUser.id] = false;
      });
    } else if (!isLiked) {
      postRef.doc(widget.meal.id).update({'luotYeuThich.$currentID': true});
      setState(() {
        soLuotThich += 1;
        isLiked = true;
        widget.meal.luotYeuThich[widget.currentUser.id] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  buildHeader() {
    timeago.setLocaleMessages('vn', timeago.ViMessages());
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(
          user.hinhAnh.toString(),
        ),
        backgroundColor: Colors.grey,
      ),
      title: GestureDetector(
        child: !user.banned!
            ? Text(
                user.username.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : const Text(
                "Người dùng đã bị cấm!",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      subtitle: Text(
        timeago.format(date, locale: 'vn'),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  showComments(BuildContext context, {String? postId, String? nguoiDang}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CommentPage(
        postId: postId.toString(),
        nguoiDang: nguoiDang.toString(),
        user: widget.currentUser,
        hinhAnhMonAn: widget.meal.hinhAnh.toString(),
      );
    }));
  }

  Future<String> thanhPhanListToString(dynamic list) async {
    List<String> listOfId = [];
    String result = '';
    list.keys.forEach((val) {
      listOfId.add(val);
    });
    for (int i = 0; i < listOfId.length; i++) {
      await materialRef.doc(listOfId.elementAt(i)).get().then((value) async {
        Materials materials = Materials.fromDocument(value);
        await ingredientRef.doc(materials.idNguyenLieu).get().then((value) {
          Ingredient ingredient = Ingredient.fromDocument(value);
          result += "- " +
              materials.soLuong.toString() +
              " " +
              getNameFromUnitId(ingredient.donVi.toString()) +
              " " +
              ingredient.tenNguyenLieu.toString() +
              "\n";
        });
      });
    }
    return result;
  }

  buildContent() {
    thanhPhanListToString(widget.meal.thanhPhan).then((value) {
      setState(() {
        thanhPhan = value;
      });
    });
    return SizedBox(
      height: MediaQuery.of(context).size.height - 152,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          GestureDetector(
            onTap: () {},
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: 250,
                  child: Image(
                    image: CachedNetworkImageProvider(
                        widget.meal.hinhAnh.toString()),
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Center(
                    child: showHeart
                        ? Animator<double>(
                            duration: Duration(milliseconds: 500),
                            tween: Tween<double>(begin: 60, end: 80),
                            curve: Curves.elasticInOut,
                            cycles: 0,
                            builder: (context, animatorState, child) => Icon(
                              Icons.favorite,
                              size: animatorState.value,
                              color: Colors.red,
                            ),
                          )
                        : Text(""),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: handleLikeMeal,
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                  ),
                  IconButton(
                    onPressed: () => showComments(context,
                        postId: widget.meal.id,
                        nguoiDang: widget.meal.nguoiDang),
                    icon: Icon(
                      FontAwesomeIcons.solidComments,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  widget.meal.getLikeCount().toString() + " lượt thích",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Tên món ăn: " + widget.meal.tenMonAn.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Mô tả: " + widget.meal.moTa.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Loại món ăn: " +
                      getNameFromMealTypeId(widget.meal.loaiMonAn.toString()),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Thành phần: \n" + thanhPhan,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Cách chế biến: " + widget.meal.cachCheBien.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Tổng giá trị dinh dưỡng: " +
                      widget.meal.tongGiaTriDinhDuong.toString() +
                      " Calories",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Độ khó: " + widget.meal.doKho.toString() + "/5.0",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Độ Phổ biến: " +
                      widget.meal.doPhoBien.toString() +
                      "/5.0",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    getlist();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context, widget.meal),
        ),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildHeader(),
          buildContent(),
        ],
      ),
    );
  }
}
