// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Services/flutter_firebase.dart';
import 'package:so_tay_mon_an/Viewmodels/login_page_viewmodel.dart';

import 'main_page.dart';

class RegisPage extends StatefulWidget {
  const RegisPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisPageState();
}

class _RegisPageState extends State<RegisPage> {
  final _userNameController = TextEditingController();
  final _passController = TextEditingController();
  final _emailController = TextEditingController();
  final _conformPassController = TextEditingController();

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
        //form đăng ký
        Container(
          margin: const EdgeInsets.fromLTRB(60, 0, 60, 0),
          color: Colors.white,
          width: 294,
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
                  child: Text('Đăng Ký ',
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
              //dòng nhập Username
              Padding(
                padding: const EdgeInsets.only(left: 35, right: 35),
                child: TextFormField(
                  controller: _userNameController,
                  decoration: const InputDecoration(
                      labelText: 'Username',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 6, 16, 38), width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Color.fromARGB(255, 6, 16, 38), width: 2),
                      ),
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 6, 16, 38),
                        fontWeight: FontWeight.bold,
                      )),
                ),
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
              ),
            ],
          ),
        ),
        //Button Enter
        Padding(
          padding: const EdgeInsets.only(left: 142, top: 426),
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
                              return const Color.fromARGB(255, 6, 16, 38);
                            },
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ))),
                      onPressed: snapshot.data == true
                          ? () async {
                              bool shouldNavigate = await register(
                                  _emailController.text,
                                  _passController.text,
                                  _userNameController.text);
                              User? user = FirebaseAuth.instance.currentUser;
                              print("user hiện tại có display name là: " +
                                  user!.displayName.toString());
                              print(user);
                              if (shouldNavigate) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MainPage(
                                              user: Users(
                                                  id: user.uid,
                                                  email: user.email,
                                                  hinhAnh: user.photoURL,
                                                  quyenHan: false,
                                                  username: user.displayName),
                                            )));
                              }
                            }
                          : null,
                      child: const Center(
                        child: Text(
                          'XONG',
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
