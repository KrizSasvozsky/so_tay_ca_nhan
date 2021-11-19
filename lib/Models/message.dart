import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Message {
  final String idNguoiDung;
  final String hinhAnh;
  final String tenNguoiDung;
  final String noiDung;
  final DateTime ngayDang;

  const Message({
    required this.idNguoiDung,
    required this.hinhAnh,
    required this.tenNguoiDung,
    required this.noiDung,
    required this.ngayDang,
  });

  static Message fromJson(Map<String, dynamic> json) => Message(
        idNguoiDung: json['idNguoiDung'],
        hinhAnh: json['hinhAnh'],
        tenNguoiDung: json['tenNguoiDung'],
        noiDung: json['noiDung'],
        ngayDang: json['ngayDang'],
      );

  Map<String, dynamic> toJson() => {
        'idNguoiDung': idNguoiDung,
        'hinhAnh': hinhAnh,
        'tenNguoiDung': tenNguoiDung,
        'noiDung': noiDung,
        'ngayDang': ngayDang,
      };

  factory Message.fromDocument(DocumentSnapshot doc) {
    return Message(
      idNguoiDung: doc['idNguoiDung'],
      hinhAnh: doc['hinhAnh'],
      tenNguoiDung: doc['tenNguoiDung'],
      noiDung: doc['noiDung'],
      ngayDang: doc['ngayDang'].toDate(),
    );
  }
}
