import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:so_tay_mon_an/Services/flutter_firebase.dart';
import 'package:so_tay_mon_an/Widgets/animated_background.dart';
import 'Models/user.dart';
import 'Views/main_page.dart';
import 'Views/registration_page.dart';
import 'Views/login_page.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

GoogleSignIn _googleSignIn = GoogleSignIn();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance
      .activate(webRecaptchaSiteKey: 'recaptcha-v3-site-key');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  PageController pageController = PageController();
  bool _isAuth = false;
  int _widgetId = 1;
  double _topMargin = 60;
  int pageIndex = 0;
  late Users user;
  String bio = "";

  List<Color> colorList = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow
  ];
  List<Alignment> alignmentList = [
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.topRight,
    Alignment.topLeft,
  ];
  int index = 0;
  Color bottomColor = Colors.red;
  Color topColor = Colors.yellow;
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (err) {
      print('Error signing in: $err');
    });
  }

  Widget _renderWidget() {
    return _widgetId == 1 ? LoginPage() : const RegisPage();
  }

  handleSignIn(GoogleSignInAccount? account) {
    if (account != null) {
      setState(() {
        user = Users(
            id: account.id,
            email: account.email,
            hinhAnh: account.photoUrl,
            quyenHan: false,
            username: account.displayName);
        _isAuth = true;
      });
    } else {
      setState(() {
        _isAuth = false;
      });
    }
  }

  void _updateLogin() {
    pageController.animateToPage(
      0,
      duration: Duration(
        milliseconds: 300,
      ),
      curve: Curves.easeInOut,
    );
    setState(() {
      if (_widgetId == 2) {
        _widgetId = 1;
      }
    });
  }

  void _updateRegis() {
    pageController.animateToPage(
      1,
      duration: Duration(
        milliseconds: 300,
      ),
      curve: Curves.easeInOut,
    );
    setState(() {
      if (_widgetId == 1) {
        _widgetId = 2;
      }
    });
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _buttonRadius = 15;
    double _logoSize = 65;
    return _isAuth
        ? ScreenUtilInit(
            builder: () => MaterialApp(
              theme: ThemeData(
                scaffoldBackgroundColor: Colors.black,
              ),
              home: MainPage(
                user: user,
              ),
            ),
            designSize: const Size(412, 732),
          )
        : ScreenUtilInit(
            builder: () => MaterialApp(
              theme: ThemeData(
                scaffoldBackgroundColor: Colors.black,
              ),
              home: Scaffold(
                appBar: null,
                body: GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  child: Stack(
                    children: [
                      //gradient background
                      AnimatedBackground(),
                      Center(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            //container 2 nút đăng nhập và đăng ký
                            Container(
                              decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 6, 16, 38),
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(_buttonRadius),
                                    topRight: Radius.circular(_buttonRadius),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    )
                                  ]),
                              margin: EdgeInsets.only(
                                  left: 60, right: 60, top: _topMargin),
                              width: 300,
                              height: 50,
                              child: Row(
                                children: [
                                  //button Đăng nhập
                                  SizedBox(
                                    width: 145,
                                    height: double.infinity,
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  const Color.fromARGB(
                                                      255, 6, 16, 38)),
                                          overlayColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                      MaterialState.focused) ||
                                                  states.contains(
                                                      MaterialState.pressed)) {
                                                return const Color.fromARGB(
                                                    255, 10, 56, 92);
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        onPressed: func,
                                        child: const Center(
                                          child: Text(
                                            'Đăng Nhập',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                  ),
                                  //button đăng ký
                                  SizedBox(
                                    width: 146,
                                    height: double.infinity,
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white),
                                          overlayColor: MaterialStateProperty
                                              .resolveWith<Color?>(
                                            (Set<MaterialState> states) {
                                              if (states.contains(
                                                      MaterialState.focused) ||
                                                  states.contains(
                                                      MaterialState.pressed)) {
                                                return Colors.grey
                                                    .withOpacity(0.5);
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        onPressed: func2,
                                        child: const Center(
                                          child: Text(
                                            'Đăng Ký',
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 6, 16, 38),
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        )),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              height: 480,
                              child: PageView(
                                children: [
                                  LoginPage(),
                                  RegisPage(),
                                ],
                                controller: pageController,
                                onPageChanged: onPageChanged,
                              ),
                            ),
                            //logo gmail
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: GestureDetector(
                                onTap: () async {
                                  await _googleSignIn.signIn();
                                  final user = _googleSignIn.currentUser;
                                  await createUserViaGmail(user!.email,
                                      user.displayName, user.id, user.photoUrl);
                                },
                                child: Container(
                                  width: _logoSize,
                                  height: _logoSize,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                        image: AssetImage(
                                            'assets/images/GooglePlus.png'),
                                        fit: BoxFit.fill),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            designSize: const Size(412, 732),
          );
  }

  void func() {
    _updateLogin();
  }

  void func2() {
    _updateRegis();
  }
}
