import 'dart:async';
import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:so_tay_mon_an/Models/material_list.dart';
import 'package:so_tay_mon_an/Models/meal.dart';
import 'package:so_tay_mon_an/Models/meal_list_notifi.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Views/edit_meal.dart';
import 'package:so_tay_mon_an/Views/meal_detail.dart';
import 'package:so_tay_mon_an/Widgets/comments.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileMealListview extends StatefulWidget {
  Meal meal;
  Users currentUser;
  String profileUserID;
  int index;
  bool fromSearchPage;
  ProfileMealListview(
      {Key? key,
      required this.index,
      required this.meal,
      required this.currentUser,
      required this.profileUserID,
      required this.fromSearchPage})
      : super(key: key);

  @override
  _ProfileMealListviewState createState() => _ProfileMealListviewState();
}

class _ProfileMealListviewState extends State<ProfileMealListview> {
  CollectionReference postRef = FirebaseFirestore.instance.collection('Meals');
  CollectionReference activityFeedRef =
      FirebaseFirestore.instance.collection('feed');
  CollectionReference userRef = FirebaseFirestore.instance.collection('Users');

  DateTime date = DateTime.now();
  Users profileUser = Users();
  int soLuotThich = 0;
  bool isLiked = false;
  bool showHeart = false;

  @override
  void initState() {
    getUser(widget.profileUserID);
    super.initState();
    checkLike();
    setState(() {
      date = widget.meal.ngayDang.toDate();
      soLuotThich = widget.meal.getLikeCount();
    });
  }

  getUser(String id) async {
    Users user =
        await userRef.doc(id).get().then((value) => Users.fromDocument(value));
    setState(() {
      profileUser = user;
    });
  }

  checkLike() async {
    Map<String, dynamic> map = Map.from(widget.meal.luotYeuThich);
    //check xem trong map có key và value = true không
    if (map.containsKey(widget.currentUser.id) && map[widget.currentUser.id]) {
      setState(() {
        isLiked = true;
      });
    }
  }

  handleLikeMeal() {
    String currentID = widget.currentUser.id.toString();
    if (isLiked) {
      postRef.doc(widget.meal.id).update({'luotYeuThich.$currentID': false});
      removeLikeFromActivity();
      setState(() {
        soLuotThich -= 1;
        isLiked = false;
        widget.meal.luotYeuThich[widget.currentUser.id] = false;
      });
    } else if (!isLiked) {
      postRef.doc(widget.meal.id).update({'luotYeuThich.$currentID': true});
      addLikeToActivity();
      setState(() {
        soLuotThich += 1;
        isLiked = true;
        widget.meal.luotYeuThich[widget.currentUser.id] = true;
        showHeart = true;
      });
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  removeLikeFromActivity() {
    bool isNotOwner = widget.currentUser.id != widget.meal.nguoiDang;
    if (isNotOwner) {
      activityFeedRef
          .doc(widget.meal.nguoiDang)
          .collection("feedItems")
          .doc(widget.meal.id)
          .get()
          .then((value) {
        if (value.exists) {
          value.reference.delete();
        }
      });
    }
  }

  addLikeToActivity() {
    bool isNotOwner = widget.currentUser.id != widget.meal.nguoiDang;
    if (isNotOwner) {
      activityFeedRef
          .doc(widget.meal.nguoiDang)
          .collection("feedItems")
          .doc(widget.meal.id)
          .set({
        "loaiFeed": "like",
        "noiDungComment": "",
        "username": widget.currentUser.username,
        "idNguoiDung": widget.currentUser.id,
        "hinhAnhNguoiDung": widget.currentUser.hinhAnh,
        "postId": widget.meal.id,
        "feedId": widget.meal.id,
        "hinhAnhPost": widget.meal.hinhAnh,
        "thoiGianDang": DateTime.now(),
      });
    }
  }

  showComments(BuildContext context, {String? postId, String? nguoiDang}) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return CommentPage(
        postId: postId.toString(),
        nguoiDang: nguoiDang.toString(),
        user: widget.currentUser,
        hinhAnhMonAn: widget.meal.hinhAnh.toString(),
      );
    }));
  }

  deletePost(String id) {
    postRef.doc(id).get().then((value) {
      value.reference.delete();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner = widget.currentUser.id == widget.meal.nguoiDang;
    timeago.setLocaleMessages('vn', timeago.ViMessages());

    dynamic data = null;
    if (!widget.fromSearchPage) {
      data = Provider.of<MealList>(context);
    }
    return Container(
      color: Colors.grey[900],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(
                profileUser.hinhAnh.toString(),
              ),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              child: Text(
                profileUser.username.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: Text(
              timeago.format(date, locale: 'vn'),
              style: TextStyle(color: Colors.white),
            ),
            trailing: isOwner
                ? PopupMenuButton(
                    icon: Icon(Icons.more_vert_sharp, color: Colors.white),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: const Text('Xóa thông báo'),
                                  content: const Text(
                                      'Bạn có muốn xóa thông báo này không?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'notok'),
                                      child: const Text("Hủy"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, 'ok');
                                      },
                                      child: Text("Đồng ý"),
                                    ),
                                  ],
                                ),
                              ).then((value) {
                                if (value == 'ok') {
                                  setState(() {
                                    Navigator.pop(context);
                                    data.deleteMeal(widget.index);
                                  });
                                }
                              });
                            },
                            child: Text("Xóa bài viết")),
                        value: 1,
                      ),
                      PopupMenuItem(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangeNotifierProvider(
                                  create: (context) => MaterialList([], []),
                                  child: EditMealPage(
                                    user: widget.currentUser,
                                    meal: widget.meal,
                                  ),
                                ),
                              ),
                            ).then(
                              (value) {
                                if (value != null)
                                  setState(
                                    () {
                                      widget.meal = value;
                                    },
                                  );
                              },
                            );
                          },
                          child: Text("Sửa bài viết"),
                        ),
                        value: 2,
                      ),
                    ],
                  )
                : null,
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealDetailPage(
                  meal: widget.meal,
                  currentUser: widget.currentUser,
                ),
              ),
            ).then(
              (value) {
                setState(() {
                  widget.meal = value;
                });
                checkLike();
              },
            ),
            onDoubleTap: handleLikeMeal,
            child: Stack(
              children: [
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: 250,
                  child: Image(
                    image: CachedNetworkImageProvider(
                        widget.meal.hinhAnh.toString()),
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 80),
                  child: Center(
                    child: showHeart
                        ? Animator<double>(
                            duration: Duration(milliseconds: 500),
                            tween: Tween<double>(begin: 60, end: 80),
                            curve: Curves.elasticInOut,
                            cycles: 0,
                            builder: (context, animatorState, child) => Icon(
                              Icons.favorite,
                              size: animatorState.value,
                              color: Colors.red,
                            ),
                          )
                        : Text(""),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: handleLikeMeal,
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
              IconButton(
                onPressed: () => showComments(context,
                    postId: widget.meal.id, nguoiDang: widget.meal.nguoiDang),
                icon: Icon(
                  FontAwesomeIcons.solidComments,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
            child: Text(
              widget.meal.getLikeCount().toString() + " lượt thích",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
