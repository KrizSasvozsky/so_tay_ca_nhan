import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:so_tay_mon_an/Models/user.dart';

class BottomNavBar extends StatefulWidget {
  Users user;
  BottomNavBar({Key? key, required this.user}) : super(key: key);

  @override
  _BottomNavBarState createState() => _BottomNavBarState(user: user);
}

class _BottomNavBarState extends State<BottomNavBar> {
  Users user;
  _BottomNavBarState({required this.user});
  int _selectedTab = 2;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.blueGrey[900],
        height: 40,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 22, 0),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedTab = 1;
                  });
                },
                icon: Icon(
                  FontAwesomeIcons.solidHeart,
                  color: _selectedTab == 1
                      ? const Color.fromARGB(255, 6, 16, 38)
                      : Colors.white,
                  size: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 22, 0),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedTab = 2;
                  });
                },
                icon: Image.asset(
                  'assets/images/Burger.png',
                  color: _selectedTab == 2
                      ? const Color.fromARGB(255, 6, 16, 38)
                      : Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 22, 0),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedTab = 3;
                  });
                },
                icon: Image.asset(
                  'assets/images/pizza.png',
                  color: _selectedTab == 3
                      ? const Color.fromARGB(255, 6, 16, 38)
                      : Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 22, 0),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _selectedTab = 4;
                    print(user.username);
                  });
                },
                icon: Image.asset(
                  'assets/images/profile.png',
                  color: _selectedTab == 4
                      ? const Color.fromARGB(255, 6, 16, 38)
                      : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
