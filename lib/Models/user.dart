import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String? id;
  String? email;
  String? hinhAnh;
  String? username;
  String? bio;
  bool? quyenHan;
  bool? banned;

  Users(
      {this.id,
      this.email,
      this.hinhAnh,
      this.quyenHan,
      this.username,
      this.bio,
      this.banned});

  factory Users.fromDocument(DocumentSnapshot doc) {
    return Users(
      email: doc['email'],
      bio: doc['bio'],
      hinhAnh: doc['hinhAnh'],
      username: doc['username'],
      quyenHan: doc['quyenHan'],
      id: doc['id'],
      banned: doc['banned'],
    );
  }
}
