import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Widgets/background.dart';
import 'package:so_tay_mon_an/Widgets/user_result.dart';

class SearchPage extends StatefulWidget {
  Users user;
  SearchPage({Key? key, required this.user}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchResultcontroller = TextEditingController();

  final userRef = FirebaseFirestore.instance.collection('Users');
  late Future<QuerySnapshot> searchResultFuture =
      userRef.where("username", isGreaterThanOrEqualTo: "").get();

  handleSearch(String query) {
    Future<QuerySnapshot> users =
        userRef.where("username", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultFuture = users;
    });
  }

  // Widget searchResultsWidget(String name) {
  //   return StreamBuilder(
  //       stream: FirebaseFirestore.instance
  //           .collection('Users')
  //           .where('username', isEqualTo: name)
  //           .snapshots(),
  //       builder: (context,
  //           AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
  //         if (!snapshot.hasData) {
  //           return const CircularProgressIndicator();
  //         }
  //         List<UserResult> seachResults = [];
  //         snapshot.data!.docs.forEach((doc) {
  //           if (doc['id'] == widget.user.id) {
  //             print(true);
  //           } else {
  //             Users user = Users(
  //                 email: doc['email'],
  //                 bio: doc['bio'],
  //                 hinhAnh: doc['hinhAnh'],
  //                 id: doc['id'],
  //                 quyenHan: doc['quyenHan'],
  //                 username: doc['username']);
  //             UserResult searchResult = UserResult(
  //               user: user,
  //               currentUser: widget.user,
  //             );
  //             seachResults.add(searchResult);
  //           }
  //         });
  //         return ListView(
  //           children: seachResults,
  //         );
  //       });
  // }

  Widget searchResultsWidget() {
    return FutureBuilder(
        future: searchResultFuture,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          List<UserResult> seachResults = [];
          snapshot.data!.docs.forEach((doc) {
            if (doc['id'] == widget.user.id) {
              print(true);
            } else {
              Users user = Users(
                  email: doc['email'],
                  bio: doc['bio'],
                  hinhAnh: doc['hinhAnh'],
                  id: doc['id'],
                  quyenHan: doc['quyenHan'],
                  username: doc['username'],
                  banned: doc['banned']);

              UserResult searchResult = UserResult(
                user: user,
                currentUser: widget.user,
                isAdmin: false,
              );
              seachResults.add(searchResult);
            }
          });
          return ListView(
            children: seachResults,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(100.0),
            child: AppBar(
              backgroundColor: Colors.blueGrey[900],
              centerTitle: true,
            ),
          ),
        ),
        BackGround(),
        Container(
          margin: EdgeInsets.only(left: 35, top: 35),
          width: 342,
          height: 40,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(6))),
          child: Row(
            children: [
              //icon
              const Padding(
                padding: EdgeInsets.all(11.0),
                child: SizedBox(
                  height: 17,
                  width: 17,
                  child: Icon(
                    FontAwesomeIcons.search,
                    size: 17,
                    color: Color.fromARGB(255, 6, 16, 38),
                  ),
                ),
              ),
              //text field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 250,
                  child: Center(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        color: Color.fromARGB(255, 6, 16, 38),
                        fontSize: 16,
                      ),
                      controller: searchResultcontroller,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(32),
                      ],
                      onFieldSubmitted: handleSearch,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(2.0),
                child: SizedBox(
                  height: 17,
                  width: 17,
                  child: GestureDetector(
                    onTap: () {
                      searchResultcontroller.clear();
                    },
                    child: const Icon(
                      FontAwesomeIcons.backspace,
                      size: 17,
                      color: Color.fromARGB(255, 6, 16, 38),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 100, bottom: 40),
          child: Center(
            child: Container(
              height: double.infinity,
              width: 340,
              child: searchResultFuture == null
                  ? Text('không tìm thấy')
                  : searchResultsWidget(),
            ),
          ),
        )
      ],
    );
  }
}
