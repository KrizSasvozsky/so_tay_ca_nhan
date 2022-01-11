import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:so_tay_mon_an/Models/feed.dart';
import 'package:so_tay_mon_an/Models/feed_list.dart';
import 'package:so_tay_mon_an/Models/meal.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'comments.dart';

class ActivityFeedItem extends StatelessWidget {
  Feed feed;
  String activityText = "";
  Widget widget = Text('');
  Users user;
  int index;
  CollectionReference activityFeedRef =
      FirebaseFirestore.instance.collection('feed');
  final commentRef = FirebaseFirestore.instance.collection('comments');
  final postRef = FirebaseFirestore.instance.collection('Meals');
  ActivityFeedItem(
      {Key? key, required this.feed, required this.user, required this.index})
      : super(key: key);

  getMediaPreview() {
    if (feed.loaiFeed == "like" || feed.loaiFeed == "comment") {
      return widget = GestureDetector(
        onTap: () {},
        child: Container(
          height: 50,
          width: 50,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: CachedNetworkImageProvider(feed.hinhAnhPost),
                    fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      );
    } else {
      return widget = Text('');
    }
  }

  getActivityText() {
    if (feed.loaiFeed == 'like') {
      activityText = " đã thích bài đăng của bạn";
    } else if (feed.loaiFeed == 'follow') {
      activityText = " đã theo dõi bạn";
    } else if (feed.loaiFeed == 'comment') {
      activityText = " đã bình luận vào bài viết của bạn";
    }
  }

  deleteFeed(String id) {
    activityFeedRef
        .doc(user.id)
        .collection('feedItems')
        .doc(id)
        .get()
        .then((value) => value.reference.delete());
  }

  toCommentPage(BuildContext context, Feed feed) async {
    if (feed.loaiFeed != 'follow') {
      String postId = '';
      Meal meal = Meal();

      await commentRef
          .doc(feed.postId)
          .collection('comments')
          .doc(feed.feedId)
          .get()
          .then((value) {
        postId = value.data()!['postId'];
      });
      await postRef.doc(postId).get().then((value) {
        meal = Meal.fromDocument(value);
      });
      await Navigator.push(context, MaterialPageRoute(builder: (context) {
        return CommentPage(
          postId: postId,
          nguoiDang: meal.nguoiDang.toString(),
          user: user,
          hinhAnhMonAn: meal.hinhAnh.toString(),
        );
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    getMediaPreview();
    getActivityText();
    timeago.setLocaleMessages('vn', timeago.ViMessages());
    final data = Provider.of<FeedList>(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2),
      child: Container(
        color: Colors.white,
        child: GestureDetector(
          onLongPress: () => showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Xóa thông báo'),
              content: const Text('Bạn có muốn xóa thông báo này không?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    deleteFeed(feed.feedId);
                    data.deleteFeed(index);
                  },
                  child: const Text("Đồng ý"),
                ),
              ],
            ),
          ),
          onTap: () => toCommentPage(context, feed),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(feed.hinhAnhNguoiDung),
            ),
            title: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  children: [
                    TextSpan(
                      text: feed.username,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: activityText,
                    )
                  ]),
            ),
            subtitle: Text(
              timeago.format(
                feed.thoiGianDang.toDate(),
                locale: 'vn',
              ),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: widget,
          ),
        ),
      ),
    );
  }
}
