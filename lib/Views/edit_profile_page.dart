import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Widgets/circular_progress.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:image/image.dart' as Im;

class EditProfilePage extends StatefulWidget {
  Users user;
  EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  XFile? file;
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  CollectionReference userRef = FirebaseFirestore.instance.collection('Users');

  final _scaffoldkey = GlobalKey<ScaffoldState>();
  bool _displayValid = true;
  bool _bioValid = true;
  bool isSelectedAnewPicture = false;
  String callbackString = "fails";

  final cloudinary = CloudinaryPublic('dqx5uvzry', 'nbln9qlo', cache: false);

  @override
  void initState() {
    fileFromImageUrl(widget.user.hinhAnh.toString()).then((value) {
      setState(() {
        file = XFile(value);
      });
    });
    super.initState();
    print(widget.user.bio);
    usernameController.text = widget.user.username!;
    if (widget.user.bio == null || widget.user.bio == " ") {
      bioController.text = "Chưa có mô tả bản thân";
    } else {
      bioController.text = widget.user.bio!;
    }
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

  updateProfle(BuildContext context) async {
    setState(() {
      usernameController.text.trim().length < 3 ||
              usernameController.text.isEmpty
          ? _displayValid = false
          : _displayValid = true;

      bioController.text.trim().length > 80
          ? _bioValid = false
          : _bioValid = true;
    });
    if (_displayValid && _bioValid) {
      if (isSelectedAnewPicture) {
        await compressImage();
        File convertedFile = File(this.file!.path);
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(convertedFile.path,
              resourceType: CloudinaryResourceType.Image),
        );
        userRef.doc(widget.user.id).update({
          "hinhAnh": response.secureUrl,
          "username": usernameController.text,
          "bio": bioController.text,
        });
        setState(() {
          widget.user.bio = bioController.text;
          widget.user.username = usernameController.text;
          widget.user.hinhAnh = response.secureUrl;
        });
      } else {
        userRef.doc(widget.user.id).update({
          "username": usernameController.text,
          "bio": bioController.text,
        });
        setState(() {
          widget.user.bio = bioController.text;
          widget.user.username = usernameController.text;
        });
      }

      SnackBar snackBar =
          SnackBar(content: Text("Đã cập nhật thành công!"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  compressImage() async {
    String imageID = const Uuid().v4();
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    File file = File(this.file!.path);
    Im.Image? imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$imageID.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile!, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> fileFromImageUrl(String url) async {
    String imageID = const Uuid().v4();
    final response = await http.get(Uri.parse(url));

    final documentDirectory = await getApplicationDocumentsDirectory();

    final file = File(join(documentDirectory.path, '$imageID.png'));

    file.writeAsBytesSync(response.bodyBytes);

    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(widget.user),
        ),
        backgroundColor: Colors.blueGrey[900],
        title: const Text(
          "Cập nhật trang cá nhân",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Align(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Stack(
                      children: [
                        Image(
                          height: 100,
                          width: 100,
                          image: FileImage(
                            File(file!.path),
                          ),
                        ),
                        // Image.network(
                        //   widget.user.hinhAnh.toString(),
                        //   loadingBuilder: (context, child, loadingProgress) {
                        //     if (loadingProgress == null) return child;
                        //     return CircularProgress();
                        //   },
                        // ),
                        Padding(
                          padding: const EdgeInsets.all(26.0),
                          child: IconButton(
                              onPressed: () => selectImage(context),
                              icon: Icon(FontAwesomeIcons.edit,
                                  color: Colors.red[900])),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber, width: 2.0),
                      ),
                      labelText: "Tên người dùng",
                      labelStyle: const TextStyle(color: Colors.white),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber, width: 2.0),
                      ),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber, width: 2.0),
                      ),
                      errorText:
                          _displayValid ? null : "Tên người dùng quá ngắn"),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: bioController,
                  decoration: InputDecoration(
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber, width: 2.0),
                    ),
                    labelText: "Mô tả bản thân",
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber, width: 2.0),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber, width: 2.0),
                    ),
                    errorText:
                        _bioValid ? null : "phần mô tả bản thân quá dài!",
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blueGrey[900],
                  ),
                  child: TextButton(
                    onPressed: () => updateProfle(context),
                    child: Text(
                      "Cập Nhật",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
