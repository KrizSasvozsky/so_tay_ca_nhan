// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> signIn(String email, String password) async {
  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'wrong-password') {
      Fluttertoast.showToast(msg: "Sai Password!");
    }
    if (e.code == 'too-many-requests') {
      Fluttertoast.showToast(msg: "Bạn bấm quá nhiều lần rồi!");
    }
    if (e.code == 'user-not-found') {
      Fluttertoast.showToast(msg: "Không tìm thấy tài khoản này!");
    }
    return false;
  } catch (e) {
    print(e);
    return false;
  }
}

Future<bool> register(String email, String password, String username) async {
  try {
    UserCredential user = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await user.user!.updateDisplayName(username);
    await createUser(email, username);
    return true;
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      Fluttertoast.showToast(msg: "Password quá yếu!");
    } else if (e.code == 'email-already-in-use') {
      Fluttertoast.showToast(msg: "Email đã được đăng ký!");
    }
    return false;
  } catch (e) {
    print(e.toString());
    return false;
  }
}

Future<void> createUser(String email, String username) async {
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  FirebaseAuth auth = FirebaseAuth.instance;
  String uid = auth.currentUser!.uid.toString();
  await users.doc(uid).set({
    'id': uid,
    'email': email,
    'hinhAnh':
        "https://www.manufacturingusa.com/sites/manufacturingusa.com/files/styles/large/public/default.png?itok=qAgo_2rs",
    'username': username,
    'quyenHan': false,
    'bio': " ",
  });
  return;
}

Future<void> createUserViaGmail(
    String email, String? username, String id, String? hinhAnh) async {
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  FirebaseAuth auth = FirebaseAuth.instance;
  try {
    await users
        .where("username", isEqualTo: username)
        .get()
        .then((value) => value.docs[0].exists);
  } catch (e) {
    print("không có data");
    users.doc(id).set({
      'id': id,
      'email': email,
      'hinhAnh': hinhAnh,
      'username': username,
      'quyenHan': false,
      'bio': " ",
    });
  }
  return;
}
