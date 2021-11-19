import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final username;
  final idNguoiDung;
  final idComment;
  final hinhAnh;
  final noiDung;
  final ngayDang;
  final postId;

  Comment(
      {this.idNguoiDung,
      this.idComment,
      this.hinhAnh,
      this.ngayDang,
      this.noiDung,
      this.username,
      this.postId});

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
        idNguoiDung: doc['idNguoiDung'],
        idComment: doc['idComment'],
        hinhAnh: doc['hinhAnh'],
        ngayDang: doc['ngayDang'],
        noiDung: doc['noiDung'],
        username: doc['username'],
        postId: doc['postId']);
  }
}
