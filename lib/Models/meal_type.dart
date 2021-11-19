import 'package:flutter/cupertino.dart';

class MealType with ChangeNotifier {
  final String id;
  final String hinhAnh;
  String tenLoaiMonAn;

  MealType(this.id, this.hinhAnh, this.tenLoaiMonAn);

  void changeType(String type) {
    tenLoaiMonAn = type;
    notifyListeners();
  }

  MealType.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        hinhAnh = json['hinhAnh'],
        tenLoaiMonAn = json['tenLoaiMonAn'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'hinhAnh': hinhAnh,
        'tenLoaiMonAn': tenLoaiMonAn,
      };
}
