import 'package:cloud_firestore/cloud_firestore.dart';

class Unit {
  final String id;
  final String tenDonVi;

  Unit({required this.id, required this.tenDonVi});

  factory Unit.fromDocument(DocumentSnapshot doc) {
    return Unit(
      id: doc['id'],
      tenDonVi: doc['tenDonVi'],
    );
  }
}
