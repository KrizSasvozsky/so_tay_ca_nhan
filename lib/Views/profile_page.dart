import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:so_tay_mon_an/Models/meal.dart';
import 'package:so_tay_mon_an/Models/meal_list_notifi.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Views/edit_profile_page.dart';
import 'package:so_tay_mon_an/Widgets/circular_progress.dart';
import 'package:so_tay_mon_an/Widgets/profile_meal.dart';
import 'package:so_tay_mon_an/Widgets/profile_meal_listview.dart';
import 'package:so_tay_mon_an/main.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:uuid/uuid.dart';

class ProfilePage extends StatefulWidget {
  Users profileUser;
  Users currentUser;
  bool fromSearchPage;
  ProfilePage(
      {Key? key,
      required this.profileUser,
      required this.fromSearchPage,
      required this.currentUser})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  CollectionReference postRef = FirebaseFirestore.instance.collection('Meals');
  CollectionReference followerRef =
      FirebaseFirestore.instance.collection('followers');
  CollectionReference followingRef =
      FirebaseFirestore.instance.collection('following');
  CollectionReference activityFeedRef =
      FirebaseFirestore.instance.collection('feed');
  List<Meal> meals = [];
  int _selectedTab = 0;
  bool isFollowing = false;
  int followers = 0;
  int following = 0;
  String feedID = const Uuid().v4();
  PageController pageController = PageController(initialPage: 0);
  LiquidController liquidController = LiquidController();

  @override
  void initState() {
    getProfileMeals();
    getFollowers();
    getFollowing();
    checkIfFollowing();
    super.initState();
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followerRef
        .doc(widget.profileUser.id)
        .collection('userFollowers')
        .get();
    setState(() {
      followers = snapshot.docs.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileUser.id)
        .collection('userFollowing')
        .get();
    setState(() {
      following = snapshot.docs.length;
    });
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followerRef
        .doc(widget.profileUser.id)
        .collection('userFollowers')
        .doc(widget.currentUser.id)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getProfileMeals() async {
    QuerySnapshot snapshot = await postRef
        .where("nguoiDang", isEqualTo: widget.profileUser.id)
        .get();
    setState(() {
      meals = snapshot.docs
          .map((e) => Meal(
              id: e['id'],
              cachCheBien: e['cachCheBien'],
              doKho: e['doKho'],
              doPhoBien: e['doPhoBien'],
              hinhAnh: e['hinhAnh'],
              loaiMonAn: e['loaiMonAn'],
              moTa: e['moTa'],
              tenMonAn: e['tenMonAn'],
              thanhPhan: e['thanhPhan'],
              luotYeuThich: e['luotYeuThich'],
              ngayDang: e['ngayDang'],
              nguoiDang: e['nguoiDang'],
              tongGiaTriDinhDuong: e['tongGiaTriDinhDuong']))
          .toList();
    });
  }

  onPageChanged(int pageIndex) {
    setState(() {
      _selectedTab = pageIndex;
    });
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    followerRef
        .doc(widget.profileUser.id)
        .collection('userFollowers')
        .doc(widget.currentUser.id)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
    followingRef
        .doc(widget.currentUser.id)
        .collection('userFollowing')
        .doc(widget.profileUser.id)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
    activityFeedRef
        .doc(widget.profileUser.id)
        .collection('feedItems')
        .doc(widget.currentUser.id)
        .get()
        .then((value) {
      if (value.exists) {
        value.reference.delete();
      }
    });
    getFollowers();
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    followerRef
        .doc(widget.profileUser.id)
        .collection('userFollowers')
        .doc(widget.currentUser.id)
        .set({'id': widget.currentUser.id});
    followingRef
        .doc(widget.currentUser.id)
        .collection('userFollowing')
        .doc(widget.profileUser.id)
        .set({'id': widget.profileUser.id});
    activityFeedRef
        .doc(widget.profileUser.id)
        .collection('feedItems')
        .doc(widget.currentUser.id)
        .set({
      "loaiFeed": "follow",
      "noiDungComment": "",
      "username": widget.currentUser.username,
      "idNguoiDung": widget.currentUser.id,
      "hinhAnhNguoiDung": widget.currentUser.hinhAnh,
      "postId": "",
      "feedId": widget.currentUser.id,
      "hinhAnhPost": "",
      "thoiGianDang": DateTime.now(),
    });
    getFollowers();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.fromSearchPage) Provider.of<MealList>(context).addMeal(meals);
    return widget.fromSearchPage
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.blueGrey[900],
            ),
            body: SingleChildScrollView(
              child: contentProfileWidget(MediaQuery.of(context).size.height,
                  MediaQuery.of(context).size.width, true),
            ),
          )
        : Scaffold(
            body: contentProfileWidget(MediaQuery.of(context).size.height,
                MediaQuery.of(context).size.width, false),
          );
  }

  Widget contentProfileWidget(
          double height, double width, bool isFromSearchPage) =>
      Column(
        children: [
          Stack(
            children: [
              //profile content
              Container(
                margin: const EdgeInsets.only(top: 90, left: 40, right: 40),
                width: width - (width / 5),
                height: 115,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Container(
                  padding: EdgeInsets.only(top: 35),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      //first container
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 10.0, right: 10.0, top: 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.profileUser.username.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.profileUser.bio.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      //second container
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Số món ăn: " + meals.length.toString()),
                            Text("Người theo dõi: " + followers.toString()),
                            Text("Đang theo dõi: " + following.toString()),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              //Circle Avatar
              Container(
                width: 85,
                height: 85,
                margin: const EdgeInsets.fromLTRB(165, 40, 165, 0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 3,
                      offset: const Offset(0, 3),
                    )
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: widget.profileUser.hinhAnh != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          widget.profileUser.hinhAnh.toString(),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return CircularProgress();
                          },
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          'https://www.manufacturingusa.com/sites/manufacturingusa.com/files/styles/large/public/default.png?itok=qAgo_2rs',
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return CircularProgress();
                          },
                        ),
                      ),
              ),
              //Edit profile
              widget.fromSearchPage
                  ? Container(
                      padding: EdgeInsets.only(top: 95, left: 260),
                      child: Container(
                        height: 30,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset: const Offset(0, 3),
                              )
                            ]),
                        child: isFollowing
                            ? TextButton(
                                onPressed: handleUnfollowUser,
                                child: const Text(
                                  "Đã Yêu Thích",
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic),
                                ))
                            : TextButton(
                                onPressed: handleFollowUser,
                                child: const Text("Yêu Thích"),
                              ),
                      ))
                  : Container(
                      padding: EdgeInsets.only(top: 85, left: 325),
                      child: IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditProfilePage(user: widget.profileUser),
                            ),
                          ).then((value) {
                            if (value == "fails" || value == null) {
                              print('this is fails');
                            } else {
                              setState(() {
                                print(value);
                                widget.currentUser = value;
                              });
                            }
                          });
                        },
                        icon: const Icon(
                          FontAwesomeIcons.userEdit,
                          size: 20,
                        ),
                      ),
                    ),
              //button thoát ứng dụng
              widget.fromSearchPage
                  ? Text("")
                  : Container(
                      padding: EdgeInsets.only(top: 85, left: 30),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              await GoogleSignIn().signOut();
                              exit(0);
                            },
                            icon: const Icon(
                              FontAwesomeIcons.times,
                              size: 20,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            "Thoát",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          //2 button, show meals type
          Container(
            color: Colors.blueGrey[900],
            width: double.infinity,
            height: 40,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      onPageChanged(0);
                      liquidController.animateToPage(page: 0, duration: 400);
                    });
                  },
                  child: Container(
                    color: _selectedTab == 0
                        ? Colors.blueGrey[800]
                        : Colors.blueGrey[900],
                    width: 206,
                    height: double.infinity,
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.th,
                        color: _selectedTab == 0 ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      onPageChanged(1);
                      liquidController.animateToPage(page: 1, duration: 400);
                    });
                  },
                  child: Container(
                    color: _selectedTab == 1
                        ? Colors.blueGrey[800]
                        : Colors.blueGrey[900],
                    height: double.infinity,
                    width: 205,
                    child: Center(
                      child: Icon(
                        FontAwesomeIcons.list,
                        color: _selectedTab == 1 ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              print(MediaQuery.of(context).size.height);
              print(MediaQuery.of(context).size.width);
            },
            child: Container(
              height: height - (205 + 80 + 15),
              width: double.infinity,
              child: LiquidSwipe(
                pages: [
                  Container(
                    color: Colors.black,
                    child: GridView.count(
                      padding: EdgeInsets.zero,
                      crossAxisSpacing: 0,
                      crossAxisCount: 4,
                      children: meals
                          .map((e) => ProfileMeal(
                              meal: e, currentUser: widget.profileUser))
                          .toList(),
                    ),
                  ),
                  Container(
                    color: Colors.grey[900],
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: meals.length,
                      itemBuilder: (context, index) {
                        return ProfileMealListview(
                          index: index,
                          meal: meals[index],
                          currentUser: widget.currentUser,
                          profileUserID: widget.profileUser.id.toString(),
                          fromSearchPage: widget.fromSearchPage,
                        );
                      },
                    ),
                  ),
                ],
                positionSlideIcon: 0.5,
                slideIconWidget: Icon(
                  Icons.arrow_back,
                  color: _selectedTab == 0 ? Colors.white : Colors.black,
                ),
                waveType: WaveType.liquidReveal,
                liquidController: liquidController,
                fullTransitionValue: 880,
                enableLoop: true,
                ignoreUserGestureWhileAnimating: true,
                onPageChangeCallback: onPageChanged,
              ),
            ),
          ),
        ],
      );
}
