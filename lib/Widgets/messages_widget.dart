import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/message.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Widgets/message_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MessagesWidget extends StatefulWidget {
  final String idUser;
  final Users currentUser;

  MessagesWidget({
    required this.idUser,
    required this.currentUser,
    Key? key,
  }) : super(key: key);

  @override
  State<MessagesWidget> createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget> {
  ScrollController _chatScrollController = ScrollController();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int loadMoreMsgs = 10;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    setState(() {
      loadMoreMsgs += 10;
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot<Map<String, dynamic>>> _selectedStream =
        FirebaseFirestore.instance
            .collection('chats')
            .doc(widget.currentUser.id)
            .collection('users')
            .doc(widget.idUser)
            .collection('messages')
            .orderBy('ngayDang', descending: true)
            .limit(loadMoreMsgs)
            .snapshots();
    return Container(
      margin: const EdgeInsets.fromLTRB(13, 0, 0, 0),
      height: 78,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(6),
        ),
      ),
      child: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: const WaterDropHeader(
          complete: Text(
            "Tải dữ liệu thành công!",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
        onRefresh: _onRefresh,
        controller: _refreshController,
        child: StreamBuilder(
          stream: _selectedStream,
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return buildText('Something Went Wrong Try later');
                } else {
                  return !snapshot.hasData
                      ? buildText('Say Hi..')
                      : ListView.builder(
                          physics: BouncingScrollPhysics(),
                          reverse: true,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot data = snapshot.data!.docs[index];
                            Message message = Message.fromDocument(data);

                            return MessageWidget(
                              message: message,
                              isMe:
                                  message.idNguoiDung == widget.currentUser.id,
                            );
                          },
                        );
                }
            }
          },
        ),
      ),
    );
  }

  Widget buildText(String text) => Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, color: Colors.black),
        ),
      );
}
