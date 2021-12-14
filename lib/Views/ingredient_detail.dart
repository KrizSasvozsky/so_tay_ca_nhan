import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:so_tay_mon_an/Models/ingredient.dart';
import 'package:so_tay_mon_an/Models/material.dart';
import 'package:so_tay_mon_an/Models/meal.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Widgets/comments.dart';
import 'package:timeago/timeago.dart' as timeago;

class IngreDetailPage extends StatefulWidget {
  Ingredient ingredient;
  Users currentUser;

  IngreDetailPage(
      {Key? key, required this.ingredient, required this.currentUser})
      : super(key: key);

  @override
  _IngreDetailPageState createState() => _IngreDetailPageState();
}

class _IngreDetailPageState extends State<IngreDetailPage> {
  DateTime date = DateTime.now();
  late Users user;
  int soLuotThich = 0;
  bool isLiked = false;
  String thanhPhan = '';

  @override
  void initState() {
    generateUser(widget.ingredient.nguoiDang.toString());
    setState(() {
      date = widget.ingredient.ngayDang!.toDate();
    });
    super.initState();
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
            username: value['username']);
      });
    });
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
        child: Text(
          user.username.toString(),
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

  buildContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 152,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              color: Colors.white,
              width: double.infinity,
              height: 250,
              child: Image(
                image: CachedNetworkImageProvider(
                    widget.ingredient.hinhAnh.toString()),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Tên nguyên liệu: " +
                      widget.ingredient.tenNguyenLieu.toString(),
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Cách bảo quản: " + widget.ingredient.baoQuan.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Loại nguyên liệu: " +
                      widget.ingredient.loaiNguyenLieu.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Đơn vị: " + widget.ingredient.donVi.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Thương Hiệu: " + widget.ingredient.thuongHieu.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Xuất xứ: " + widget.ingredient.xuatXu.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  "Tổng giá trị dinh dưỡng: " +
                      widget.ingredient.giaTriDinhDuong.toString(),
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
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
