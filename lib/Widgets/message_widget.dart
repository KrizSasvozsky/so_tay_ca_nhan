import 'package:flutter/material.dart';
import 'package:so_tay_mon_an/Models/message.dart';
import 'package:so_tay_mon_an/Widgets/fullscreen_image_widget.dart';

class MessageWidget extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageWidget({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        if (!isMe)
          CircleAvatar(
              radius: 16, backgroundImage: NetworkImage(message.hinhAnh)),
        Container(
          padding: message.loaiTinNhan == "message"
              ? const EdgeInsets.all(16)
              : null,
          margin: const EdgeInsets.all(16),
          constraints: BoxConstraints(maxWidth: 140),
          decoration: BoxDecoration(
            color: isMe ? Colors.grey[100] : Theme.of(context).accentColor,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1), // changes position of shadow
              ),
            ],
            borderRadius: isMe
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(context),
        ),
      ],
    );
  }

  Widget buildMessage(BuildContext context) => Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          message.loaiTinNhan == "message"
              ? Text(
                  message.noiDung,
                  style: TextStyle(color: isMe ? Colors.black : Colors.white),
                  textAlign: isMe ? TextAlign.end : TextAlign.start,
                )
              : GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return FullScreenImage(
                        imageUrl: message.tinNhanHinhAnh,
                        tag: "generate_a_unique_tag",
                      );
                    }));
                  },
                  child: Hero(
                    child: Image.network(message.tinNhanHinhAnh),
                    tag: "generate_a_unique_tag",
                  ),
                ),
        ],
      );
}
