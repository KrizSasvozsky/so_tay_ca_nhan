// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Services/flutter_firebase.dart';
import 'package:so_tay_mon_an/Viewmodels/login_page_viewmodel.dart';
import 'package:so_tay_mon_an/Views/main_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  final loginViewModel = LoginViewModel();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      loginViewModel.emailSink.add(_emailController.text);
    });

    _passController.addListener(() {
      loginViewModel.passwordSink.add(_passController.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
    loginViewModel.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //form đăng nhập
        Container(
          margin: const EdgeInsets.fromLTRB(60, 0, 60, 0),
          color: Colors.white,
          width: 290,
          height: 450,
          child: Column(
            children: [
              //logo
              Container(
                  margin: const EdgeInsets.fromLTRB(40, 45, 40, 20),
                  child: Container(
                    width: 70,
                    height: 61,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/chefhat.png'),
                          fit: BoxFit.fill),
                    ),
                  )),
              //tên form
              const Center(
                  child: Text('Đăng Nhập',
                      style: TextStyle(
                          color: Color.fromARGB(255, 6, 16, 38),
                          fontWeight: FontWeight.bold,
                          fontSize: 20))),
              //dòng nhập email
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 35, top: 10),
                child: StreamBuilder<String>(
                    stream: loginViewModel.emailStream.cast(),
                    builder: (context, snapshot) {
                      return TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            hintText: 'vd: example@gmail.com',
                            labelText: 'Email',
                            errorText: snapshot.data,
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 6, 16, 38),
                                  width: 2),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 6, 16, 38),
                                  width: 2),
                            ),
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 6, 16, 38),
                              fontWeight: FontWeight.bold,
                            )),
                      );
                    }),
              ),
              //dòng nhập password
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 35),
                child: StreamBuilder<String>(
                    stream: loginViewModel.passwordStream.cast(),
                    builder: (context, snapshot) {
                      return TextFormField(
                        controller: _passController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            errorText: snapshot.data,
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 6, 16, 38),
                                  width: 2),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 6, 16, 38),
                                  width: 2),
                            ),
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(255, 6, 16, 38),
                              fontWeight: FontWeight.bold,
                            )),
                      );
                    }),
              )
            ],
          ),
        ),
        //button enter
        Padding(
          padding: const EdgeInsets.only(left: 142, top: 425),
          child: SizedBox(
            width: 129,
            height: 47,
            child: StreamBuilder<bool>(
                stream: loginViewModel.btnEnterStream,
                builder: (context, snapshot) {
                  return ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 6, 16, 38)),
                          overlayColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.focused) ||
                                  states.contains(MaterialState.pressed)) {
                                return const Color.fromARGB(255, 10, 56, 92);
                              }
                              return const Color.fromARGB(255, 6, 16,
                                  38); // Defer to the widget's default.
                            },
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ))),
                      onPressed: snapshot.data == true
                          ? () async {
                              bool shouldNavigate = await signIn(
                                  _emailController.text, _passController.text);
                              User? user = FirebaseAuth.instance.currentUser;
                              if (shouldNavigate) {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainPage(
                                              user: Users(
                                                  id: user!.uid,
                                                  email: user.email,
                                                  hinhAnh: user.photoURL,
                                                  quyenHan: false,
                                                  username: user.displayName,
                                                  banned: false),
                                            )));
                              }
                            }
                          : null,
                      child: const Center(
                        child: Text(
                          'Enter',
                          style: TextStyle(color: Colors.white),
                        ),
                      ));
                }),
          ),
        ),
      ],
    );
  }
}
