import 'package:cloud_firestore/cloud_firestore.dart';

class Ingredient {
  String? idNguyenLieu;
  String? baoQuan;
  String? donVi;
  int? giaTriDinhDuong;
  String? hinhAnh;
  String? loaiNguyenLieu;
  String? nguoiDang;
  Timestamp? ngayDang;
  String? tenNguyenLieu;
  String? thuongHieu;
  String? xuatXu;

  Ingredient(
      {this.idNguyenLieu,
      this.baoQuan,
      this.donVi,
      this.giaTriDinhDuong,
      this.hinhAnh,
      this.loaiNguyenLieu,
      this.nguoiDang,
      this.tenNguyenLieu,
      this.thuongHieu,
      this.ngayDang,
      this.xuatXu});

  dynamic toJson() => {
        'idNguyenLieu': idNguyenLieu,
        'baoQuan': baoQuan,
        'donVi': donVi,
        'giaTriDinhDuong': giaTriDinhDuong,
        'hinhAnh': hinhAnh,
        'loaiNguyenLieu': loaiNguyenLieu,
        'nguoiDang': nguoiDang,
        'tenNguyenLieu': tenNguyenLieu,
        'thuongHieu': thuongHieu,
        'ngayDang': ngayDang,
        'xuatXu': xuatXu,
      };

  Ingredient.fromJson(Map<String, dynamic> json)
      : idNguyenLieu = json['idNguyenLieu'],
        baoQuan = json['baoQuan'],
        donVi = json['donVi'],
        giaTriDinhDuong = json['giaTriDinhDuong'],
        hinhAnh = json['hinhAnh'],
        loaiNguyenLieu = json['loaiNguyenLieu'],
        nguoiDang = json['nguoiDang'],
        tenNguyenLieu = json['tenNguyenLieu'],
        thuongHieu = json['thuongHieu'],
        ngayDang = json['ngayDang'],
        xuatXu = json['xuatXu'];

  static Ingredient fromMap(Map<String, dynamic> map) {
    return Ingredient(
        idNguyenLieu: map['idNguyenLieu'],
        baoQuan: map['baoQuan'],
        donVi: map['donVi'],
        giaTriDinhDuong: map['giaTriDinhDuong'],
        hinhAnh: map['hinhAnh'],
        loaiNguyenLieu: map['loaiNguyenLieu'],
        nguoiDang: map['nguoiDang'],
        tenNguyenLieu: map['tenNguyenLieu'],
        thuongHieu: map['thuongHieu'],
        ngayDang: map['ngayDang'],
        xuatXu: map['xuatXu']);
  }

  factory Ingredient.fromDocumentSnapshot(
      {required DocumentSnapshot<Map<String, dynamic>> doc}) {
    return Ingredient(
      idNguyenLieu: doc.data()!['idNguyenLieu'],
      baoQuan: doc.data()!['baoQuan'],
      donVi: doc.data()!['donVi'],
      giaTriDinhDuong: doc.data()!['giaTriDinhDuong'],
      hinhAnh: doc.data()!['hinhAnh'],
      loaiNguyenLieu: doc.data()!['loaiNguyenLieu'],
      nguoiDang: doc.data()!['nguoiDang'],
      tenNguyenLieu: doc.data()!['tenNguyenLieu'],
      thuongHieu: doc.data()!['thuongHieu'],
      ngayDang: doc.data()!['ngayDang'],
      xuatXu: doc.data()!['xuatXu'],
    );
  }

  factory Ingredient.fromDocument(DocumentSnapshot doc) {
    return Ingredient(
      idNguyenLieu: doc['idNguyenLieu'],
      baoQuan: doc['baoQuan'],
      donVi: doc['donVi'],
      giaTriDinhDuong: int.parse(doc['giaTriDinhDuong']),
      hinhAnh: doc['hinhAnh'],
      loaiNguyenLieu: doc['loaiNguyenLieu'],
      nguoiDang: doc['nguoiDang'],
      tenNguyenLieu: doc['tenNguyenLieu'],
      thuongHieu: doc['thuongHieu'],
      ngayDang: doc['ngayDang'],
      xuatXu: doc['xuatXu'],
    );
  }
}
