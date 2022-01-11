import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Widgets/chat_page_detail.dart';

class ChatHeaderWidget extends StatelessWidget {
  final List<Users> users;
  final Users currentUser;
  const ChatHeaderWidget({
    required this.users,
    required this.currentUser,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        !users.elementAt(index).banned!
                            ? Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ChatPageDetail(
                                  user: users[index],
                                  currentUser: currentUser,
                                ),
                              ))
                            : Fluttertoast.showToast(
                                msg: "Người dùng đã bị cấm bởi admin");
                      },
                      child: CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(user.hinhAnh.toString()),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      );
}
