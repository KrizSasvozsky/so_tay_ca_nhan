import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:so_tay_mon_an/Models/ingredient.dart';
import 'package:so_tay_mon_an/Models/material.dart';
import 'package:so_tay_mon_an/Models/material_list.dart';
import 'package:so_tay_mon_an/Models/meal.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Widgets/choose_ingredient.dart';
import 'package:so_tay_mon_an/Widgets/material_card.dart';
import 'package:uuid/uuid.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class EditMealPage extends StatefulWidget {
  final Users user;
  final Meal meal;
  EditMealPage({Key? key, required this.user, required this.meal})
      : super(key: key);

  @override
  _EditMealPageState createState() => _EditMealPageState();
}

class _EditMealPageState extends State<EditMealPage> {
  XFile? file;
  bool isUploading = false;
  double doPhoBien = 0;
  double doKho = 0;
  String dropdownValue = 'Lẩu';
  bool isSelectedAnewPicture = false;
  Meal currentMeal = Meal();

  List<String> listOfMealType = [];
  List<String> listOfIngredientsName = [];
  List<Materials> listOfMaterials = [];
  List<Materials> deleteData = [];

  TextEditingController moTaController = TextEditingController();
  TextEditingController tenMonAnController = TextEditingController();
  TextEditingController cachCheBienController = TextEditingController();

  CollectionReference materialRef =
      FirebaseFirestore.instance.collection('Material');
  CollectionReference postRef = FirebaseFirestore.instance.collection('Meals');

  final cloudinary = CloudinaryPublic('dqx5uvzry', 'nbln9qlo', cache: false);

  @override
  void initState() {
    fileFromImageUrl(widget.meal.hinhAnh.toString()).then((value) {
      setState(() {
        file = XFile(value);
      });
    });
    super.initState();
    FirebaseFirestore.instance
        .collection('Ingredients')
        .get()
        .then((QuerySnapshot snapshotvalue) => {
              snapshotvalue.docs.forEach((f) => {
                    setState(() {
                      listOfIngredientsName.add(f['tenNguyenLieu']);
                    })
                  })
            });
    FirebaseFirestore.instance
        .collection('meal_type')
        .get()
        .then((QuerySnapshot snapshotvalue) => {
              snapshotvalue.docs.forEach((f) => {
                    setState(() {
                      listOfMealType.add(f['tenLoaiMonAn']);
                    })
                  })
            });
    getMaterials();
    moTaController.text = widget.meal.moTa.toString();
    tenMonAnController.text = widget.meal.tenMonAn.toString();
    cachCheBienController.text = widget.meal.cachCheBien.toString();
    doPhoBien = widget.meal.doPhoBien!.toDouble();
    doKho = widget.meal.doKho!.toDouble();
    dropdownValue = widget.meal.loaiMonAn.toString();
  }

  getMaterials() async {
    List<String> listOfId = [];
    String result = '';
    widget.meal.thanhPhan.keys.forEach((val) {
      listOfId.add(val);
    });
    for (int i = 0; i < listOfId.length; i++) {
      await materialRef.doc(listOfId.elementAt(i)).get().then((value) async {
        Materials materials = Materials.fromDocument(value);
        setState(() {
          listOfMaterials.add(materials);
        });
      });
    }
  }

  Future<String> fileFromImageUrl(String url) async {
    String imageID = const Uuid().v4();
    final response = await http.get(Uri.parse(url));

    final documentDirectory = await getApplicationDocumentsDirectory();

    final file = File(join(documentDirectory.path, '$imageID.png'));

    file.writeAsBytesSync(response.bodyBytes);

    return file.path;
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  handleTakePhoto(BuildContext context) async {
    Navigator.pop(context);
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      this.file = file;
      isSelectedAnewPicture = true;
    });
  }

  handleChooseFromGallery(BuildContext context) async {
    Navigator.pop(context);
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
      isSelectedAnewPicture = true;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Tạo bài viết'),
            children: [
              SimpleDialogOption(
                child: Text("Tải hình từ thư viện ảnh"),
                onPressed: () => handleChooseFromGallery(context),
              ),
              SimpleDialogOption(
                child: Text("Tải hình từ máy ảnh"),
                onPressed: () => handleTakePhoto(context),
              ),
              SimpleDialogOption(
                child: Text("Hủy"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  handleSubmit(BuildContext context) async {
    setState(() {
      isUploading = true;
    });
    try {
      if (isSelectedAnewPicture) {
        await compressImage();
        File convertedFile = File(this.file!.path);
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(convertedFile.path,
              resourceType: CloudinaryResourceType.Image),
        );
        await updatePostInFireStore(mediaUrl: response.secureUrl);
      } else {
        await updatePostInFireStore(mediaUrl: widget.meal.hinhAnh.toString());
      }
      moTaController.clear();
      tenMonAnController.clear();
      cachCheBienController.clear();
    } on Exception catch (e) {
      print(e);
    }
    setState(() {
      listOfMaterials.clear();
      dropdownValue = "Lẩu";
      doKho = 0;
      doPhoBien = 0;
      file = null;
      isUploading = false;
    });
    Navigator.pop(context, currentMeal);
  }

  String stringFormat(List<Materials> list) {
    String result = "";
    for (int i = 0; i < list.length; i++) {
      Ingredient ingre = Ingredient();
      FirebaseFirestore.instance
          .collection('Ingredients')
          .doc(list.elementAt(i).idNguyenLieu)
          .get()
          .then((value) => ingre = Ingredient.fromDocument(value));
      result += "- " +
          list.elementAt(i).soLuong.toString() +
          " " +
          ingre.donVi.toString() +
          " " +
          ingre.tenNguyenLieu.toString() +
          "\n";
    }
    return result;
  }

  int calculateCalories(List<Materials> list) {
    int result = 0;
    for (int i = 0; i < list.length; i++) {
      Ingredient ingre = Ingredient();
      FirebaseFirestore.instance
          .collection('Ingredients')
          .doc(list.elementAt(i).idNguyenLieu)
          .get()
          .then((value) => ingre = Ingredient.fromDocument(value));
      result += ingre.giaTriDinhDuong!.toInt();
    }
    print(result);
    return result;
  }

  updatePostInFireStore({required String mediaUrl}) {
    Map<String, bool> result = {
      for (var v in listOfMaterials) v.idThanhPhan.toString(): true
    };
    currentMeal = Meal(
        id: widget.meal.id,
        cachCheBien: cachCheBienController.text,
        doKho: doKho,
        doPhoBien: doPhoBien,
        hinhAnh: mediaUrl,
        loaiMonAn: dropdownValue,
        luotYeuThich: widget.meal.luotYeuThich,
        moTa: moTaController.text,
        ngayDang: widget.meal.ngayDang,
        nguoiDang: widget.meal.nguoiDang,
        tenMonAn: tenMonAnController.text,
        thanhPhan: result,
        tongGiaTriDinhDuong: 0);

    for (Materials material in listOfMaterials) {
      materialRef.doc(material.idThanhPhan).set({
        "id": material.idThanhPhan,
        "idMonAn": widget.meal.id,
        "idNguyenLieu": material.idNguyenLieu,
        "soLuong": material.soLuong,
      });
    }
    for (Materials material in deleteData) {
      materialRef.doc(material.idThanhPhan).get().then((value) {
        value.reference.delete();
      });
    }
    postRef.doc(widget.meal.id).update({
      "cachCheBien": cachCheBienController.text,
      "doKho": doKho,
      "doPhoBien": doPhoBien,
      "hinhAnh": mediaUrl,
      "loaiMonAn": dropdownValue,
      "moTa": moTaController.text,
      "tenMonAn": tenMonAnController.text,
      "thanhPhan": result,
    });
  }

  compressImage() async {
    String postID = widget.meal.id.toString();
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    File file = File(this.file!.path);
    Im.Image? imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postID.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    listOfMaterials = Provider.of<MaterialList>(context).data;
    deleteData = Provider.of<MaterialList>(context).deleteData;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
          },
        ),
        title: const Text(
          "Sửa Món Ăn",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => handleSubmit(
                    context,
                  ),
              child: const Text(
                "Cập Nhật",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ))
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: ListView(
            children: [
              GestureDetector(
                onTap: () => selectImage(context),
                child: Container(
                  height: 220,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                              fit: BoxFit.cover,
                              image: FileImage(File(file!.path)),
                            )),
                          ),
                          const Center(
                            child: Icon(
                              FontAwesomeIcons.edit,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      widget.user.hinhAnh.toString(),
                    ),
                    backgroundColor: Colors.white,
                  ),
                  title: SizedBox(
                    width: 250,
                    child: TextField(
                      controller: moTaController,
                      decoration: const InputDecoration(
                        hintText: "Mô tả...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ListTile(
                  leading: const Icon(
                    FontAwesomeIcons.accessibleIcon,
                    color: Colors.black,
                    size: 35,
                  ),
                  title: SizedBox(
                    width: 250,
                    child: TextField(
                      controller: tenMonAnController,
                      decoration: const InputDecoration(
                        hintText: "Tên món ăn",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width * 0.5,
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Loại món ăn: ',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black),
                      underline: Container(
                        width: 50,
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      items: listOfMealType
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                color: Colors.white,
                width: 300,
                height: 100,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: TextField(
                    controller: cachCheBienController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Cách chế biến",
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 50,
                color: Colors.white,
                child: Row(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(top: 15.0, left: 15.0, bottom: 15.0),
                      child: Text(
                        "Độ Phổ Biến: ",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SmoothStarRating(
                      rating: doPhoBien,
                      isReadOnly: false,
                      size: 30,
                      filledIconData: Icons.star,
                      halfFilledIconData: Icons.star_half,
                      defaultIconData: Icons.star_border,
                      starCount: 5,
                      allowHalfRating: false,
                      spacing: 2.0,
                      onRated: (value) {
                        setState(() {
                          doPhoBien = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                height: 50,
                color: Colors.white,
                child: Row(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(top: 15.0, left: 15.0, bottom: 15.0),
                      child: Text(
                        "Độ Khó: ",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SmoothStarRating(
                      rating: doKho,
                      isReadOnly: false,
                      size: 30,
                      filledIconData: Icons.star,
                      halfFilledIconData: Icons.star_half,
                      defaultIconData: Icons.star_border,
                      starCount: 5,
                      allowHalfRating: false,
                      spacing: 2.0,
                      onRated: (value) {
                        setState(() {
                          doKho = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width * 0.5,
                child: Row(
                  children: [
                    const Padding(
                      padding:
                          EdgeInsets.only(top: 15.0, left: 15.0, bottom: 15.0),
                      child: Text(
                        'Thành phần: ',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              ChooseIngredientDialog(
                            listIngredientName: listOfIngredientsName,
                          ),
                        ).then((value) {
                          setState(() {
                            if (value == null) {
                              print("fails");
                            } else
                              listOfMaterials.add(value);
                          });
                        });
                      },
                      icon: const Icon(
                        FontAwesomeIcons.plus,
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      width: 266,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: listOfMaterials.length,
                          itemBuilder: (context, index) {
                            return MaterialCard(
                              index: index,
                              material: listOfMaterials[index],
                            );
                          }),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
