import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/material.dart';

class MaterialList with ChangeNotifier {
  List<Materials> data = [];
  List<Materials> deleteData = [];

  MaterialList(this.data, this.deleteData);

  deleteMaterial(int index) {
    Materials material = data.elementAt(index);
    deleteData.add(material);
    this.data.removeAt(index);
    notifyListeners();
  }

  addMaterial(List<Materials> materials) {
    this.data = materials;
    notifyListeners();
  }
}
