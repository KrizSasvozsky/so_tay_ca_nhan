import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class CreateIngredientPage extends StatefulWidget {
  Users currentUser;
  CreateIngredientPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _CreateIngredientPageState createState() => _CreateIngredientPageState();
}

class _CreateIngredientPageState extends State<CreateIngredientPage> {
  XFile? file;
  bool isUploading = false;

  String dropdownDonVi = '';
  String dropdownLoaiNguyenLieu = '';

  List<String> listOfUnits = [];
  List<String> listOfIngreType = [];

  CollectionReference unitsRef = FirebaseFirestore.instance.collection('Units');
  CollectionReference ingredientTypeRef =
      FirebaseFirestore.instance.collection('Ingredients_Type');
  CollectionReference ingredientRef =
      FirebaseFirestore.instance.collection('Ingredients');

  TextEditingController tenNguyenLieuCtrller = TextEditingController();
  TextEditingController thuongHieuCtrller = TextEditingController();
  TextEditingController cachBaoQuanCtrller = TextEditingController();
  TextEditingController giaTriDinhDuongCtrller = TextEditingController();
  TextEditingController xuatXuCtrller = TextEditingController();

  String postID = const Uuid().v4();
  DateTime timeStamp = DateTime.now();
  final cloudinary = CloudinaryPublic('dqx5uvzry', 'nbln9qlo', cache: false);

  @override
  void initState() {
    super.initState();
    getDropdownValues();
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  handleTakePhoto() async {
    Navigator.pop(context);
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
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
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text("Tải hình từ máy ảnh"),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text("Hủy"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  createPostInFireStore({required String mediaUrl}) {
    ingredientRef.doc(postID).set({
      "idNguyenLieu": postID,
      "baoQuan": cachBaoQuanCtrller.text,
      "donVi": dropdownDonVi,
      "giaTriDinhDuong": giaTriDinhDuongCtrller.text,
      "loaiNguyenLieu": mediaUrl,
      "nguoiDang": widget.currentUser.id,
      "tenNguyenLieu": tenNguyenLieuCtrller.text,
      "thuongHieu": thuongHieuCtrller.text,
      "ngayDang": DateTime.now(),
      "xuatXu": xuatXuCtrller.text,
      "hinhAnh": mediaUrl,
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });

    try {
      await compressImage();
      File convertedFile = File(this.file!.path);
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(convertedFile.path,
            resourceType: CloudinaryResourceType.Image),
      );
      await createPostInFireStore(mediaUrl: response.secureUrl);
      Navigator.pop(context, tenNguyenLieuCtrller.text);
      print(response.secureUrl);
    } on CloudinaryException catch (e) {
      print(e.message);
      print(e.request);
    }
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

  getDropdownValues() async {
    await unitsRef.get().then((QuerySnapshot snapshotvalue) {
      snapshotvalue.docs.forEach((f) => {listOfUnits.add(f['tenDonVi'])});
    });
    await ingredientTypeRef.get().then((QuerySnapshot snapshotvalue) {
      snapshotvalue.docs
          .forEach((f) => {listOfIngreType.add(f['tenLoaiNguyenLieu'])});
    });
    setState(() {
      dropdownDonVi = "ml";
      dropdownLoaiNguyenLieu = 'Thịt';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.ac_unit),
          onPressed: () => Navigator.of(context).pop("fails"),
        ),
        backgroundColor: Colors.blueGrey[900],
        title: const Text('Tạo Nguyên Liệu'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: handleSubmit,
            child: const Text(
              "Đăng Tải",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
          ),
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
                child: SizedBox(
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
                                image: file != null
                                    ? FileImage(File(file!.path))
                                    : const CachedNetworkImageProvider(
                                            'https://www.rusu.co.uk/pageassets/representation/change-it/card-submit-an-idea.jpg')
                                        as ImageProvider,
                              ),
                            ),
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
                child: ListTile(
                  title: SizedBox(
                    width: 250,
                    child: TextField(
                      controller: tenNguyenLieuCtrller,
                      decoration: const InputDecoration(
                        hintText: "Tên Nguyên Liệu...",
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
                child: ListTile(
                  title: SizedBox(
                    width: 250,
                    child: TextField(
                      controller: thuongHieuCtrller,
                      decoration: const InputDecoration(
                        hintText: "Thương Hiệu...",
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
                        'Loại Nguyên Liệu: ',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownButton<String>(
                      value: dropdownLoaiNguyenLieu,
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
                          dropdownLoaiNguyenLieu = newValue!;
                        });
                      },
                      items: listOfIngreType
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
                width: MediaQuery.of(context).size.width * 0.5,
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Đơn Vị: ',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                    DropdownButton<String>(
                      value: dropdownDonVi,
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
                          dropdownDonVi = newValue!;
                        });
                      },
                      items: listOfUnits
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
                child: ListTile(
                  title: SizedBox(
                    width: 250,
                    child: TextField(
                      controller: cachBaoQuanCtrller,
                      decoration: const InputDecoration(
                        hintText: "Cách Bảo Quản...",
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
                child: ListTile(
                  title: SizedBox(
                    width: 250,
                    child: TextField(
                      controller: giaTriDinhDuongCtrller,
                      decoration: const InputDecoration(
                        suffix: Text(
                          'Calo',
                          style: TextStyle(color: Colors.black),
                        ),
                        hintText: "Giá Trị Dinh Dưỡng...",
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                color: Colors.white,
                child: ListTile(
                  title: SizedBox(
                    width: 250,
                    child: TextField(
                      controller: xuatXuCtrller,
                      decoration: const InputDecoration(
                        hintText: "Xuất xứ...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
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
