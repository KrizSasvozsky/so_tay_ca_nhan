import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:so_tay_mon_an/Models/user.dart';

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
  CollectionReference chatRef = FirebaseFirestore.instance.collection('chats');

  CollectionReference userRef = FirebaseFirestore.instance.collection('Users');

  void sendMessage() async {
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
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black,
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
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
            SizedBox(width: 20),
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
