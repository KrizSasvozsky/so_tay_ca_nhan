import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class MealType with ChangeNotifier {
  final String id;
  String tenLoaiMonAn;

  MealType({required this.id, required this.tenLoaiMonAn});

  void changeType(String type) {
    tenLoaiMonAn = type;
    notifyListeners();
  }

  MealType.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        tenLoaiMonAn = json['tenLoaiMonAn'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'tenLoaiMonAn': tenLoaiMonAn,
      };

  factory MealType.fromDocument(DocumentSnapshot doc) {
    return MealType(
      id: doc['id'],
      tenLoaiMonAn: doc['tenLoaiMonAn'],
    );
  }
}
