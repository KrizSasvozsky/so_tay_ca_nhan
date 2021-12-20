import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/comment.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

class CommentPage extends StatefulWidget {
  String postId;
  String nguoiDang;
  String hinhAnhMonAn;
  Users user;
  CommentPage(
      {Key? key,
      required this.postId,
      required this.nguoiDang,
      required this.user,
      required this.hinhAnhMonAn})
      : super(key: key);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final commentRef = FirebaseFirestore.instance.collection('comments');
  CollectionReference activityFeedRef =
      FirebaseFirestore.instance.collection('feed');
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  editComment(Comment comment) {
    TextEditingController textEditingController = TextEditingController();
    if (widget.user.id == comment.idNguoiDung) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Sửa bình luận!"),
                content: TextField(
                  controller: textEditingController,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: Text("Hủy"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'ok'),
                    child: Text("Đồng ý"),
                  ),
                ],
              )).then((value) {
        if (value == "ok") {
          commentRef
              .doc(widget.postId)
              .collection('comments')
              .doc(comment.idComment)
              .get()
              .then((value) {
            if (value.exists) {
              value.reference.update({"noiDung": textEditingController.text});
            }
          });
        }
      });
    }
  }

  deleteComment(Comment comment) {
    if (widget.user.id == comment.idNguoiDung) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text("Xóa bình luận!"),
                content:
                    Text("Bạn có chắc muốn xóa bình luận này không?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                    child: Text("Hủy"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'ok'),
                    child: Text("Đồng ý"),
                  ),
                ],
              )).then((value) {
        if (value == "ok") {
          commentRef
              .doc(widget.postId)
              .collection('comments')
              .doc(comment.idComment)
              .get()
              .then((value) {
            if (value.exists) {
              value.reference.delete();
            }
          });
          print(comment.idComment);
          activityFeedRef
              .doc(widget.nguoiDang)
              .collection('feedItems')
              .doc(comment.idComment)
              .get()
              .then((value) => value.reference.delete());
        }
      });
    }
  }

  buildComments() {
    return StreamBuilder(
        stream: commentRef
            .doc(widget.postId)
            .collection('comments')
            .orderBy("ngayDang", descending: true)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Comment> comments = [];
          snapshot.data!.docs.forEach((doc) {
            comments.add(Comment.fromDocument(doc));
          });
          return ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                timeago.setLocaleMessages('vn', timeago.ViMessages());
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12, width: 1),
                  ),
                  child: GestureDetector(
                    onLongPress: () => deleteComment(comments.elementAt(index)),
                    onDoubleTap: () => editComment(comments.elementAt(index)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          comments.elementAt(index).hinhAnh,
                        ),
                        backgroundColor: Colors.grey,
                      ),
                      title: Text(
                        comments.elementAt(index).username,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        comments.elementAt(index).noiDung,
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        timeago.format(
                            (comments.elementAt(index).ngayDang as Timestamp)
                                .toDate(),
                            locale: 'vn'),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              });
        });
  }

  addComment() {
    String commentID = const Uuid().v4();
    commentRef.doc(widget.postId).collection("comments").doc(commentID).set({
      "username": widget.user.username,
      "noiDung": commentController.text,
      "ngayDang": DateTime.now(),
      "hinhAnh": widget.user.hinhAnh,
      "idNguoiDung": widget.user.id,
      "idComment": commentID,
      "postId": widget.postId,
    });
    bool isNotOwner = widget.user.id != widget.nguoiDang;
    if (isNotOwner) {
      activityFeedRef
          .doc(widget.nguoiDang)
          .collection('feedItems')
          .doc(commentID)
          .set({
        "loaiFeed": "comment",
        "noiDungComment": commentController.text,
        "username": widget.user.username,
        "idNguoiDung": widget.user.id,
        "hinhAnhNguoiDung": widget.user.hinhAnh,
        "postId": widget.postId,
        "feedId": commentID,
        "hinhAnhPost": widget.hinhAnhMonAn,
        "thoiGianDang": DateTime.now(),
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Bình luận"),
          backgroundColor: Colors.blueGrey[900],
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                child: buildComments(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                title: TextFormField(
                  controller: commentController,
                  decoration: const InputDecoration(
                    labelText: "Hãy nhập bình luận",
                    labelStyle: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                ),
                trailing: TextButton(
                    onPressed: addComment, child: const Text("Đăng tải")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
