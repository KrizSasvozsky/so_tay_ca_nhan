import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Im;
import 'package:provider/provider.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:so_tay_mon_an/Models/ingredient.dart';
import 'package:so_tay_mon_an/Models/ingredient_type.dart';
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

class EditIngredientPage extends StatefulWidget {
  final Users currentUser;
  final Ingredient ingredient;
  const EditIngredientPage(
      {Key? key, required this.currentUser, required this.ingredient})
      : super(key: key);

  @override
  _EditIngredientPageState createState() => _EditIngredientPageState();
}

class _EditIngredientPageState extends State<EditIngredientPage> {
  XFile? file;
  bool isUploading = false;
  bool isSelectedAnewPicture = false;

  String dropdownDonVi = '';
  String dropdownLoaiNguyenLieu = '';

  List<String> listOfUnits = [];
  List<IngredientType> listOfIngreType = [];

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
    fileFromImageUrl(widget.ingredient.hinhAnh.toString()).then((value) {
      setState(() {
        file = XFile(value);
      });
    });

    getDropdownValues();
    tenNguyenLieuCtrller.text = widget.ingredient.tenNguyenLieu.toString();
    thuongHieuCtrller.text = widget.ingredient.thuongHieu.toString();
    cachBaoQuanCtrller.text = widget.ingredient.baoQuan.toString();
    giaTriDinhDuongCtrller.text = widget.ingredient.giaTriDinhDuong.toString();
    xuatXuCtrller.text = widget.ingredient.xuatXu.toString();
  }

  Future<String> fileFromImageUrl(String url) async {
    String imageID = const Uuid().v4();
    final response = await http.get(Uri.parse(url));

    final documentDirectory = await getApplicationDocumentsDirectory();

    final file = File(join(documentDirectory.path, '$imageID.png'));

    file.writeAsBytesSync(response.bodyBytes);

    return file.path;
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
            title: Text('Chọn hình ảnh'),
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

  updateIngredientInFireStore(
      {required String mediaUrl, required String idLoaiNguyenLieu}) {
    ingredientRef.doc(widget.ingredient.idNguyenLieu).update({
      "baoQuan": cachBaoQuanCtrller.text,
      "donVi": dropdownDonVi,
      "giaTriDinhDuong": giaTriDinhDuongCtrller.text,
      "loaiNguyenLieu": idLoaiNguyenLieu,
      "tenNguyenLieu": tenNguyenLieuCtrller.text,
      "thuongHieu": thuongHieuCtrller.text,
      "xuatXu": xuatXuCtrller.text,
      "hinhAnh": mediaUrl,
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
        String idLoaiNguyenLieu =
            await getIdFromIngredientTypeName(dropdownLoaiNguyenLieu);
        await updateIngredientInFireStore(
            mediaUrl: response.secureUrl, idLoaiNguyenLieu: idLoaiNguyenLieu);
      } else {
        String idLoaiNguyenLieu =
            await getIdFromIngredientTypeName(dropdownLoaiNguyenLieu);
        await updateIngredientInFireStore(
            mediaUrl: widget.ingredient.hinhAnh.toString(),
            idLoaiNguyenLieu: idLoaiNguyenLieu);
      }
      Navigator.pop(context);
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
    QuerySnapshot snapshot = await ingredientTypeRef.get();
    setState(() {
      listOfIngreType +=
          snapshot.docs.map((e) => IngredientType.fromDocument(e)).toList();
    });
    String result = await getNameFromIngredientTypeId(
        widget.ingredient.loaiNguyenLieu.toString());
    setState(() {
      dropdownDonVi = widget.ingredient.donVi.toString();
      dropdownLoaiNguyenLieu = result;
    });
  }

  Future<String> getNameFromIngredientTypeId(String id) async {
    List<IngredientType> listOfIngre = [];
    final snapshot = await ingredientTypeRef.doc(id).get();
    IngredientType ingredientType = IngredientType.fromDocument(snapshot);
    return ingredientType.tenLoaiNguyenLieu;
  }

  Future<String> getIdFromIngredientTypeName(String ingredientTypeName) async {
    String id = '';
    List<IngredientType> listOfIngre = [];
    QuerySnapshot snapshot = await ingredientTypeRef
        .where('tenLoaiNguyenLieu', isEqualTo: ingredientTypeName)
        .get();
    listOfIngre +=
        snapshot.docs.map((e) => IngredientType.fromDocument(e)).toList();
    id = listOfIngre.first.idLoaiNguyenLieu;
    return id;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop("fails"),
        ),
        backgroundColor: Colors.blueGrey[900],
        title: const Text('Cập Nhật Nguyên Liệu'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => handleSubmit(context),
            child: const Text(
              "Cập Nhật",
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
                        .map<DropdownMenuItem<String>>((IngredientType value) {
                      return DropdownMenuItem<String>(
                        value: value.tenLoaiNguyenLieu,
                        child: Text(
                          value.tenLoaiNguyenLieu,
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
    );
  }
}
