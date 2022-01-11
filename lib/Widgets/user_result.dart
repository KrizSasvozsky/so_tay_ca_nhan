import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Views/profile_page.dart';
import 'package:so_tay_mon_an/Widgets/circular_progress.dart';

class UserResult extends StatelessWidget {
  Users user;
  Users currentUser;
  bool isAdmin;
  UserResult(
      {Key? key,
      required this.user,
      required this.currentUser,
      required this.isAdmin})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            !user.banned!
                ? Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(
                        profileUser: user,
                        currentUser: currentUser,
                        fromSearchPage: true,
                        isAdmin: isAdmin,
                      ),
                    ),
                  )
                : Fluttertoast.showToast(msg: "Người dùng đã bị cấm!");
          },
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    user.hinhAnh != null || user.banned!
                        ? Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.amber, width: 2),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(13),
                                topRight: Radius.circular(13),
                                bottomLeft: Radius.circular(13),
                              ),
                              child: Image.network(
                                user.hinhAnh.toString(),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.amber, width: 2),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                'https://www.manufacturingusa.com/sites/manufacturingusa.com/files/styles/large/public/default.png?itok=qAgo_2rs',
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return CircularProgress();
                                },
                              ),
                            ),
                          ),
                    Container(
                      height: double.infinity,
                      width: 256,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: Colors.transparent,
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: !user.banned!
                                  ? Text(
                                      user.username.toString(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    )
                                  : const Text(
                                      "Người dùng đã bị cấm!",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(color: Colors.amber, width: 2),
                                right:
                                    BorderSide(color: Colors.amber, width: 2),
                                bottom:
                                    BorderSide(color: Colors.amber, width: 2),
                              ),
                            ),
                            child: !user.banned!
                                ? Text(
                                    user.email.toString(),
                                  )
                                : const Text(
                                    "Người dùng đã bị cấm!",
                                  ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 78.0, top: 37),
                  child: Container(
                    color: Colors.white,
                    height: 40,
                    width: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
