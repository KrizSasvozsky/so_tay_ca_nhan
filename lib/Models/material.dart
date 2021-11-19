import 'package:cloud_firestore/cloud_firestore.dart';

class Materials {
  final String? idThanhPhan;
  final String? idMonAn;
  final String? idNguyenLieu;
  final int? soLuong;

  Materials({this.idThanhPhan, this.idMonAn, this.idNguyenLieu, this.soLuong});

  factory Materials.fromDocument(DocumentSnapshot doc) {
    return Materials(
      idThanhPhan: doc['id'],
      idMonAn: doc['idMonAn'],
      idNguyenLieu: doc['idNguyenLieu'],
      soLuong: doc['soLuong'],
    );
  }
}
