// ignore_for_file: prefer_final_fields

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:so_tay_mon_an/MenuController.dart';
import 'package:so_tay_mon_an/Models/feed_list.dart';
import 'package:so_tay_mon_an/Models/material_list.dart';
import 'package:so_tay_mon_an/Models/meal_list_notifi.dart';
import 'package:so_tay_mon_an/Models/meal_type.dart';
import 'package:so_tay_mon_an/Models/meal_type_string.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Views/activity_feed_notification.dart';
import 'package:so_tay_mon_an/Views/ingredient_page.dart';
import 'package:so_tay_mon_an/Views/post_meal.dart';
import 'package:so_tay_mon_an/Views/profile_page.dart';
import 'package:so_tay_mon_an/Views/search_page.dart';
import 'package:so_tay_mon_an/Views/timeline_page.dart';
import 'package:so_tay_mon_an/Widgets/background.dart';
import 'package:so_tay_mon_an/Widgets/main_horizontal_listview.dart';
import 'package:so_tay_mon_an/Widgets/meals_listview.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  Users user;
  MainPage({Key? key, required this.user}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainPageState(user: user);
}

class _MainPageState extends State<MainPage> {
  Users user;
  int _selectedTab = 0;
  PageController pageController = PageController(initialPage: 0);
  _MainPageState({required this.user});
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    generateUser(user.id.toString());
  }

  generateUser(String id) {
    var document = FirebaseFirestore.instance.collection('Users').doc(id);
    document.get().then((value) {
      setState(() {
        user = Users(
          id: id,
          bio: value['bio'],
          email: value['email'],
          hinhAnh: value['hinhAnh'],
          quyenHan: value['quyenHan'],
          username: value['username'],
          banned: value['banned'],
        );
      });
    });
  }

  onPageChanged(int pageIndex) {
    setState(() {
      _selectedTab = pageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: () => Material(
        child: Stack(
          children: [
            //appbar
            _selectedTab == 0
                ? Scaffold(
                    appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(100.0),
                      child: AppBar(
                        backgroundColor: Colors.blueGrey[900],
                        title: const Text('Sổ Tay Món Ăn'),
                      ),
                    ),
                    body: const Center(
                      child: Text('hello'),
                    ),
                  )
                : Scaffold(
                    appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(100.0),
                      child: AppBar(
                        backgroundColor: Colors.blueGrey[900],
                        title: null,
                      ),
                    ),
                    body: const Center(
                      child: Text('hello'),
                    ),
                  ),
            PageView(
              children: [
                MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                      create: (context) => MealList([]),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => MenuController(),
                    ),
                  ],
                  builder: (context, child) => TimeLinePage(
                    currentUser: user,
                  ),
                ),
                IngredientPage(
                  user: user,
                ),
                ChangeNotifierProvider(
                  create: (context) => FeedList([]),
                  child: ActivityFeedNotiFyPage(
                    currentUser: user,
                  ),
                ),
                ChangeNotifierProvider(
                    create: (context) => MaterialList([], []),
                    child: PostMeal(user: user)),
                SearchPage(
                  user: user,
                ),
                ChangeNotifierProvider(
                  create: (context) => MealList([]),
                  child: ProfilePage(
                    profileUser: user,
                    currentUser: user,
                    fromSearchPage: false,
                    isAdmin: false,
                  ),
                ),
              ],
              controller: pageController,
              onPageChanged: onPageChanged,
            ),
            //Bottom Navigator bar
            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.blueGrey[900],
                height: 40,
                child: Row(
                  children: [
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            pageController.animateToPage(
                              0,
                              duration: const Duration(
                                milliseconds: 300,
                              ),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.solidSnowflake,
                          color:
                              _selectedTab == 0 ? Colors.black : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            pageController.animateToPage(
                              1,
                              duration: const Duration(
                                milliseconds: 300,
                              ),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.balanceScale,
                          color:
                              _selectedTab == 1 ? Colors.black : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            pageController.animateToPage(
                              2,
                              duration: const Duration(
                                milliseconds: 300,
                              ),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.solidBell,
                          color:
                              _selectedTab == 2 ? Colors.black : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            pageController.animateToPage(
                              3,
                              duration: const Duration(
                                milliseconds: 300,
                              ),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.plusCircle,
                          color:
                              _selectedTab == 3 ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            pageController.animateToPage(
                              4,
                              duration: const Duration(
                                milliseconds: 300,
                              ),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.search,
                          color:
                              _selectedTab == 4 ? Colors.black : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            pageController.animateToPage(
                              5,
                              duration: const Duration(
                                milliseconds: 300,
                              ),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.solidUser,
                          color:
                              _selectedTab == 5 ? Colors.black : Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      designSize: const Size(412, 732),
    );
  }
}
