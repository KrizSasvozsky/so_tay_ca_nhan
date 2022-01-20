import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

class NewMessageWidget extends StatefulWidget {
  final String idUser;
  final Users currentUser;

  const NewMessageWidget({
    required this.idUser,
    required this.currentUser,
    Key? key,
  }) : super(key: key);

  @override
  _NewMessageWidgetState createState() => _NewMessageWidgetState();
}

class _NewMessageWidgetState extends State<NewMessageWidget> {
  final _controller = TextEditingController();
  String message = '';
  XFile? file;
  bool isUploading = false;
  bool isSelectImage = false;
  bool isKeyboardVisible = false;
  bool isEmojiVisible = false;

  final cloudinary = CloudinaryPublic('dqx5uvzry', 'nbln9qlo', cache: false);

  CollectionReference chatRef = FirebaseFirestore.instance.collection('chats');

  CollectionReference userRef = FirebaseFirestore.instance.collection('Users');

  void sendMessage() async {
    setState(() {
      isUploading = true;
    });
    await chatRef
        .doc(widget.currentUser.id)
        .collection('users')
        .doc(widget.idUser)
        .collection('messages')
        .add({
      'hinhAnh': widget.currentUser.hinhAnh,
      'idNguoiDung': widget.currentUser.id,
      'ngayDang': DateTime.now(),
      'noiDung': _controller.text,
      'tenNguoiDung': widget.currentUser.username,
      'loaiTinNhan': 'message',
      'tinNhanHinhAnh': '',
    });
    await chatRef
        .doc(widget.idUser)
        .collection('users')
        .doc(widget.currentUser.id)
        .collection('messages')
        .add({
      'hinhAnh': widget.currentUser.hinhAnh,
      'idNguoiDung': widget.currentUser.id,
      'ngayDang': DateTime.now(),
      'noiDung': _controller.text,
      'tenNguoiDung': widget.currentUser.username,
      'loaiTinNhan': 'message',
      'tinNhanHinhAnh': '',
    });
    setState(() {
      _controller.clear();
      isUploading = false;
    });
  }

  Future<void> sendMessageWithImage(String url) async {
    setState(() {
      isUploading = true;
    });
    await chatRef
        .doc(widget.currentUser.id)
        .collection('users')
        .doc(widget.idUser)
        .collection('messages')
        .add({
      'hinhAnh': widget.currentUser.hinhAnh,
      'idNguoiDung': widget.currentUser.id,
      'ngayDang': DateTime.now(),
      'noiDung': _controller.text,
      'tenNguoiDung': widget.currentUser.username,
      'loaiTinNhan': 'image',
      'tinNhanHinhAnh': url,
    });
    await chatRef
        .doc(widget.idUser)
        .collection('users')
        .doc(widget.currentUser.id)
        .collection('messages')
        .add({
      'hinhAnh': widget.currentUser.hinhAnh,
      'idNguoiDung': widget.currentUser.id,
      'ngayDang': DateTime.now(),
      'noiDung': _controller.text,
      'tenNguoiDung': widget.currentUser.username,
      'loaiTinNhan': 'image',
      'tinNhanHinhAnh': url,
    });
    setState(() {
      _controller.clear();
      isUploading = false;
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

  handleTakePhoto(BuildContext context) async {
    Navigator.pop(context);
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      this.file = file;
    });
    await sendImage(this.file);
  }

  handleChooseFromGallery(BuildContext context) async {
    Navigator.pop(context);
    XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
    await sendImage(this.file);
  }

  sendImage(XFile? file) async {
    if (file != null) {
      await compressImage();
      File convertedFile = File(file.path);
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(convertedFile.path,
            resourceType: CloudinaryResourceType.Image),
      );
      await sendMessageWithImage(response.secureUrl);
    }
  }

  compressImage() async {
    String postID = const Uuid().v4();
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
  Widget build(BuildContext context) => Container(
        color: Colors.black,
        padding: const EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            InkWell(
              onTap: () => selectImage(context),
              child: const SizedBox(
                width: 30,
                height: 48,
                child: Icon(
                  FontAwesomeIcons.image,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) => setState(() {
                  message = value;
                }),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: message.trim().isEmpty ? null : sendMessage,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueGrey[900],
                ),
                child: Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      );
}
