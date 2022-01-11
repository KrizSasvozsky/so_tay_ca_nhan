import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Widgets/header.dart';
import 'package:so_tay_mon_an/Widgets/side_menu.dart';

class DashboardScreen extends StatefulWidget {
  Users currentUser;

  DashboardScreen({Key? key, required this.currentUser}) : super(key: key);
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void controlMenu() {
    if (!_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        drawer: SideMenu(
          currentUser: widget.currentUser,
        ),
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          title: const Text("Trang Admin"),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child:
                  Center(child: Image.asset("assets/images/greeting-icon.png")),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  "Xin chào Admin\n" + widget.currentUser.username.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ));
  }
}
