import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Widgets/chat_body.dart';
import 'package:so_tay_mon_an/Widgets/chat_header.dart';

class ChatPage extends StatefulWidget {
  Users currentUser;
  ChatPage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  CollectionReference followingRef =
      FirebaseFirestore.instance.collection('following');
  CollectionReference userRef = FirebaseFirestore.instance.collection('Users');

  List<Users> listOfUsers = [];

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  getUsers() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.currentUser.id)
        .collection('userFollowing')
        .get();
    listOfUsers = await getList(snapshot);
    for (Users user in listOfUsers) {
      print(user.username);
    }
  }

  getList(QuerySnapshot snapshot) async {
    List<String> listOfFollower =
        snapshot.docs.map((e) => e['id'].toString()).toList();

    for (String id in listOfFollower) {
      DocumentSnapshot snapshot = await userRef.doc(id).get();
      Users user = Users.fromDocument(snapshot);
      setState(() {
        listOfUsers.add(user);
      });
    }
    return listOfUsers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: Text("Phòng Chat"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          ChatHeaderWidget(
            users: listOfUsers,
            currentUser: widget.currentUser,
          ),
          ChatBody(
            users: listOfUsers,
            currentUser: widget.currentUser,
          )
        ],
      ),
    );
  }
}
