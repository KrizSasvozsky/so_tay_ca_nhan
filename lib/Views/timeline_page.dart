import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/meal.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Views/chat_page.dart';
import 'package:so_tay_mon_an/Widgets/profile_meal_listview.dart';

class TimeLinePage extends StatefulWidget {
  final Users currentUser;
  TimeLinePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  _TimeLinePageState createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  CollectionReference postRef = FirebaseFirestore.instance.collection('Meals');
  CollectionReference followingRef =
      FirebaseFirestore.instance.collection('following');
  CollectionReference userRef = FirebaseFirestore.instance.collection('Users');
  List<Meal> listOfPosts = [];
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    getTimeline();
    super.initState();
  }

  getTimeline() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.currentUser.id)
        .collection('userFollowing')
        .get();
    listOfPosts = await getList(snapshot);
    listOfPosts.sort((a, b) => b.ngayDang.compareTo(a.ngayDang));
    setState(() {
      isLoading = false;
    });
  }

  getList(QuerySnapshot snapshot) async {
    List<String> listOfFollower =
        snapshot.docs.map((e) => e['id'].toString()).toList();

    listOfFollower.add(widget.currentUser.id.toString());
    List<Meal> listOfPosts = [];
    for (String id in listOfFollower) {
      QuerySnapshot snapshot =
          await postRef.where('nguoiDang', isEqualTo: id).get();
      setState(() {
        listOfPosts += snapshot.docs.map((e) => Meal.fromDocument(e)).toList();
      });
    }
    return listOfPosts;
  }

  getListOfWidget() {
    List<Widget> list = [];
    for (Meal meal in listOfPosts) {
      list.add(Text(
        meal.tenMonAn.toString(),
        style: TextStyle(color: Colors.white),
      ));
    }
    return list;
  }

  timeline() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: listOfPosts.length,
        itemBuilder: (context, index) {
          return ProfileMealListview(
            index: index,
            meal: listOfPosts[index],
            currentUser: widget.currentUser,
            profileUserID: listOfPosts[index].nguoiDang.toString(),
            fromSearchPage: false,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  currentUser: widget.currentUser,
                ),
              ),
            ),
            icon: Icon(Icons.access_alarm),
          ),
        ],
        title: Text("Timeline"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Container(
          child: timeline(),
        ),
      ),
    );
  }
}
