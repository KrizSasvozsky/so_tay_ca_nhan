import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Widgets/chat_page_detail.dart';

class ChatBody extends StatelessWidget {
  final List<Users> users;
  final Users currentUser;
  const ChatBody({
    required this.users,
    required this.currentUser,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: buildChats(),
        ),
      );

  Widget buildChats() => ListView.builder(
        physics: BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final user = users[index];

          return Container(
            height: 75,
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatPageDetail(
                    user: users[index],
                    currentUser: currentUser,
                  ),
                ));
              },
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(user.hinhAnh.toString()),
              ),
              title: Text(user.username.toString()),
            ),
          );
        },
        itemCount: users.length,
      );
}
