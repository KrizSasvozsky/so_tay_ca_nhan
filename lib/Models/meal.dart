import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:so_tay_mon_an/Models/food_material.dart';
import 'package:so_tay_mon_an/Models/ingredient.dart';
import 'package:so_tay_mon_an/Models/meal_type.dart';

class Meal with ChangeNotifier {
  final String? id;
  final String? cachCheBien;
  final double? doKho;
  final double? doPhoBien;
  final String? hinhAnh;
  final String? loaiMonAn;
  final String? moTa;
  final String? tenMonAn;
  final dynamic? thanhPhan;
  final dynamic? luotYeuThich;
  final dynamic? ngayDang;
  final String? nguoiDang;
  final int? tongGiaTriDinhDuong;

  Meal(
      {this.id,
      this.cachCheBien,
      this.doKho,
      this.doPhoBien,
      this.hinhAnh,
      this.loaiMonAn,
      this.moTa,
      this.tenMonAn,
      this.thanhPhan,
      this.luotYeuThich,
      this.ngayDang,
      this.nguoiDang,
      this.tongGiaTriDinhDuong});

  factory Meal.fromDocument(DocumentSnapshot doc) {
    return Meal(
      id: doc['id'],
      cachCheBien: doc['cachCheBien'],
      doKho: doc['doKho'],
      doPhoBien: doc['doPhoBien'],
      hinhAnh: doc['hinhAnh'],
      loaiMonAn: doc['loaiMonAn'],
      moTa: doc['moTa'],
      tenMonAn: doc['tenMonAn'],
      thanhPhan: doc['thanhPhan'],
      luotYeuThich: doc['luotYeuThich'],
      ngayDang: doc['ngayDang'],
      nguoiDang: doc['nguoiDang'],
      tongGiaTriDinhDuong: doc['tongGiaTriDinhDuong'],
    );
  }

  Meal.fromJson(Map<String, dynamic> json)
      : cachCheBien = json['cachCheBien'],
        doKho = json['doKho'],
        doPhoBien = json['doPhoBien'],
        hinhAnh = json['hinhAnh'],
        id = json['id'],
        loaiMonAn = json['loaiMonAn'],
        moTa = json['moTa'],
        tenMonAn = json['tenMonAn'],
        thanhPhan = json['thanhPhan'],
        luotYeuThich = json['luotYeuThich'],
        ngayDang = json['ngayDang'],
        nguoiDang = json['nguoiDang'],
        tongGiaTriDinhDuong = json['tongGiaTriDinhDuong'];

  Map<String, dynamic> toJson() => {
        'cachCheBien': cachCheBien,
        'doKho': doKho,
        'doPhoBien': doPhoBien,
        'hinhAnh': hinhAnh,
        'id': id,
        'loaiMonAn': loaiMonAn,
        'moTa': moTa,
        'tenMonAn': tenMonAn,
        'thanhPhan': thanhPhan,
        'likes': luotYeuThich,
        'ngayDang': ngayDang,
        'nguoiDang': nguoiDang,
        'tongGiaTriDinhDuong': tongGiaTriDinhDuong,
      };
  int getLikeCount() {
    if (luotYeuThich == null) {
      return 0;
    }
    int count = 0;
    luotYeuThich.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  // @override
  // String toString() {
  //   String result = "";
  //   for (int i = 0; i < thanhPhan.length; i++) {
  //     result += '- ' +
  //         thanhPhan[i].soLuong.toString() +
  //         ' ' +
  //         thanhPhan[i].TenNguyenLieu +
  //         '\n';
  //   }
  //   return result;
  // }
}
