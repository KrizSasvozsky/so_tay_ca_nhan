import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class IngredientType with ChangeNotifier {
  final String idLoaiNguyenLieu;
  String tenLoaiNguyenLieu;

  IngredientType(
      {required this.idLoaiNguyenLieu, required this.tenLoaiNguyenLieu});

  IngredientType.fromJson(Map<String, dynamic> json)
      : idLoaiNguyenLieu = json['idLoaiNguyenLieu'],
        tenLoaiNguyenLieu = json['tenLoaiNguyenLieu'];

  Map<String, dynamic> toJson() => {
        'idLoaiNguyenLieu': idLoaiNguyenLieu,
        'tenLoaiNguyenLieu': tenLoaiNguyenLieu,
      };

  factory IngredientType.fromDocumentSnapshot(
      {required DocumentSnapshot<Map<String, dynamic>> doc}) {
    return IngredientType(
      idLoaiNguyenLieu: doc.data()!['idLoaiNguyenLieu'],
      tenLoaiNguyenLieu: doc.data()!['tenLoaiNguyenLieu'],
    );
  }

  factory IngredientType.fromDocument(DocumentSnapshot doc) {
    return IngredientType(
      idLoaiNguyenLieu: doc['idLoaiNguyenLieu'],
      tenLoaiNguyenLieu: doc['tenLoaiNguyenLieu'],
    );
  }
}
