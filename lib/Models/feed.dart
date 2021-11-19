import 'package:cloud_firestore/cloud_firestore.dart';

class Feed {
  final String loaiFeed;
  final String noiDungComment;
  final String username;
  final String idNguoiDung;
  final String hinhAnhNguoiDung;
  final String postId;
  final String feedId;
  final String hinhAnhPost;
  Timestamp thoiGianDang;

  Feed(
      {required this.loaiFeed,
      required this.noiDungComment,
      required this.username,
      required this.idNguoiDung,
      required this.hinhAnhNguoiDung,
      required this.postId,
      required this.feedId,
      required this.thoiGianDang,
      required this.hinhAnhPost});

  factory Feed.fromDocument(DocumentSnapshot doc) {
    return Feed(
        loaiFeed: doc['loaiFeed'],
        noiDungComment: doc['noiDungComment'],
        username: doc['username'],
        idNguoiDung: doc['idNguoiDung'],
        hinhAnhNguoiDung: doc['hinhAnhNguoiDung'],
        postId: doc['postId'],
        feedId: doc['feedId'],
        thoiGianDang: doc['thoiGianDang'],
        hinhAnhPost: doc['hinhAnhPost']);
  }
}
