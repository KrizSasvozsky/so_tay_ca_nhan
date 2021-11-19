import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Widgets/messages_widget.dart';
import 'package:so_tay_mon_an/Widgets/new_message.dart';
import 'package:so_tay_mon_an/Widgets/profile_header.dart';

class ChatPageDetail extends StatefulWidget {
  final Users user;
  final Users currentUser;

  const ChatPageDetail({
    required this.user,
    required this.currentUser,
    Key? key,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPageDetail> {
  @override
  Widget build(BuildContext context) => Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.blueGrey[900],
        body: SafeArea(
          child: Column(
            children: [
              ProfileHeader(name: widget.user.username.toString()),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                  child: MessagesWidget(
                    idUser: widget.user.id.toString(),
                    currentUser: widget.currentUser,
                  ),
                ),
              ),
              NewMessageWidget(
                idUser: widget.user.id.toString(),
                currentUser: widget.currentUser,
              )
            ],
          ),
        ),
      );
}
