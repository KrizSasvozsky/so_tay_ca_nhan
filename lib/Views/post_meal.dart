import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:so_tay_mon_an/Models/ingredient.dart';
import 'package:so_tay_mon_an/Models/material.dart';
import 'package:so_tay_mon_an/Models/material_list.dart';
import 'package:so_tay_mon_an/Models/meal_type.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:so_tay_mon_an/Views/create_ingredient.dart';
import 'package:so_tay_mon_an/Widgets/choose_ingredient.dart';
import 'package:so_tay_mon_an/Widgets/circular_progress.dart';
import 'package:so_tay_mon_an/Widgets/material_card.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class PostMeal extends StatefulWidget {
  final Users user;
  PostMeal({Key? key, required this.user}) : super(key: key);

  @override
  _PostMealState createState() => _PostMealState();
}

class _PostMealState extends State<PostMeal> {
  XFile? file;
  bool isUploading = false;
  bool isValid = false;

  String dropdownValue = 'Lẩu';
  double doPhoBien = 0;
  double doKho = 0;

  TextEditingController moTaController = TextEditingController();
  TextEditingController tenMonAnController = TextEditingController();
  TextEditingController cachCheBienController = TextEditingController();

  String postID = const Uuid().v4();

  List<String> listOfMealType = [];
  List<String> listOfIngredientsName = [];
  List<Materials> listOfMaterials = [];

  final storageRef = FirebaseStorage.instance.ref();
  CollectionReference postRef = FirebaseFirestore.instance.collection('Meals');
  CollectionReference materialRef =
      FirebaseFirestore.instance.collection('Material');
  DateTime timeStamp = DateTime.now();

  final cloudinary = CloudinaryPublic('dqx5uvzry', 'nbln9qlo', cache: false);

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('Ingredients')
        .get()
        .then((QuerySnapshot snapshotvalue) => {
              snapshotvalue.docs.forEach((f) {
                setState(() {
                  listOfIngredientsName.add(f['tenNguyenLieu']);
                });
              })
            });
    FirebaseFirestore.instance
        .collection('meal_type')
        .get()
        .then((QuerySnapshot snapshotvalue) => {
              snapshotvalue.docs
                  .forEach((f) => {listOfMealType.add(f['tenLoaiMonAn'])})
            });
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
    });
  }

  handleChooseFromGallery(BuildContext context) async {
    Navigator.pop(context);
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
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
                onPressed: () => handleChooseFromGallery(parentContext),
              ),
              SimpleDialogOption(
                child: Text("Tải hình từ máy ảnh"),
                onPressed: () => handleTakePhoto(parentContext),
              ),
              SimpleDialogOption(
                child: Text("Hủy"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  bool checkValid() {
    if (moTaController.text.isEmpty ||
        tenMonAnController.text.isEmpty ||
        cachCheBienController.text.isEmpty ||
        listOfMaterials.isEmpty) {
      return false;
    }
    return true;
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    if (checkValid()) {
      try {
        await compressImage();
        File convertedFile = File(file!.path);
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(convertedFile.path,
              resourceType: CloudinaryResourceType.Image),
        );
        createPostInFireStore(mediaUrl: response.secureUrl);
        moTaController.clear();
        tenMonAnController.clear();
        cachCheBienController.clear();

        print(response.secureUrl);
      } on CloudinaryException catch (e) {
        print(e.message);
        print(e.request);
      }
      setState(() {
        listOfMaterials.clear();
        dropdownValue = "Lẩu";
        doKho = 0;
        doPhoBien = 0;
        file = null;
        isUploading = false;
      });
    }
    
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

  // int calculateCalories(List<Materials> list) {
  //   int result = 0;
  //   for (int i = 0; i < list.length; i++) {
  //     Ingredient ingre = Ingredient();
  //     FirebaseFirestore.instance
  //         .collection('Ingredients')
  //         .doc(list.elementAt(i).idNguyenLieu)
  //         .get()
  //         .then((value) => ingre = Ingredient.fromDocument(value));
  //     print(ingre.tenNguyenLieu);
  //     result += ingre.giaTriDinhDuong!.toInt();
  //   }
  //   print(result);
  //   return result;
  // }

  createPostInFireStore({required String mediaUrl}) {
    for (Materials material in listOfMaterials) {
      materialRef.doc(material.idThanhPhan).set({
        "id": material.idThanhPhan,
        "idMonAn": postID,
        "idNguyenLieu": material.idNguyenLieu,
        "soLuong": material.soLuong,
      });
    }
    Map<String, bool> result = {
      for (var v in listOfMaterials) v.idThanhPhan.toString(): true
    };
    postRef.doc(postID).set({
      "id": postID,
      "cachCheBien": cachCheBienController.text,
      "doKho": doKho,
      "doPhoBien": doPhoBien,
      "hinhAnh": mediaUrl,
      "loaiMonAn": dropdownValue,
      "moTa": moTaController.text,
      "tenMonAn": tenMonAnController.text,
      "thanhPhan": result,
      "tongGiaTriDinhDuong": 0,
      "luotYeuThich": {},
      "nguoiDang": widget.user.id,
      "ngayDang": DateTime.now(),
    });
  }

  Future<String> uploadImage(imageFile) async {
    String downloadURL = "";
    UploadTask uploadTask =
        storageRef.child("post_$postID.jpg").putFile(imageFile);
    uploadTask.then((res) async {
      downloadURL = await res.ref.getDownloadURL();
    });
    return downloadURL;
  }

  compressImage() async {
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

  List<Widget> makeButtons(
      int num, List<Widget> children, List<Function()?> onPresses) {
    List<Widget> buttons = [];
    for (int i = 0; i < num; i++) {
      buttons.add(ElevatedButton(child: children[i], onPressed: onPresses[i]));
    }
    return buttons;
  }

  Scaffold buildSplashScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          "Tạo Món Ăn",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(bottom: 46),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FontAwesomeIcons.camera,
                color: Colors.white,
                size: 150,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(primary: Colors.grey.shade600),
                  onPressed: () => selectImage(context),
                  child: const Text(
                    "Chọn ảnh để tạo bài viết món ăn",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Scaffold buildUploadForm() {
    listOfMaterials = Provider.of<MaterialList>(context).data;
    final data = Provider.of<MaterialList>(context);
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
              file = null;
            });
          },
        ),
        title: const Text(
          "Tạo Món Ăn",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
              onPressed: handleSubmit,
              child: const Text(
                "Đăng tải",
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
              Container(
                height: 220,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FileImage(File(file!.path)),
                        ),
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
                            } else {
                              listOfMaterials.add(value);
                            }
                          });
                        });
                      },
                      icon: const Icon(
                        FontAwesomeIcons.plus,
                      ),
                    ),
                    Container(
                      height: 60,
                      width: 266,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: listOfMaterials.length,
                          itemBuilder: (context, index) {
                            return MaterialCard(
                                index: index, material: listOfMaterials[index]);
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

  @override
  Widget build(BuildContext context) {
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
