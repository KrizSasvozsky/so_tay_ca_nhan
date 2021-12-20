import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:so_tay_mon_an/Models/feed.dart';
import 'package:so_tay_mon_an/Models/feed_list.dart';
import 'package:so_tay_mon_an/Models/user.dart';
import 'package:so_tay_mon_an/Widgets/activity_feed_item.dart';

class ActivityFeedNotiFyPage extends StatefulWidget {
  Users currentUser;
  ActivityFeedNotiFyPage({Key? key, required this.currentUser})
      : super(key: key);

  @override
  _ActivityFeedNotiFyPageState createState() => _ActivityFeedNotiFyPageState();
}

class _ActivityFeedNotiFyPageState extends State<ActivityFeedNotiFyPage> {
  CollectionReference activityFeedRef =
      FirebaseFirestore.instance.collection('feed');
  List<Feed> feedItems = [];
  @override
  void initState() {
    getActivityFeed();
    super.initState();
  }

  getActivityFeed() async {
    QuerySnapshot snapshot = await activityFeedRef
        .doc(widget.currentUser.id)
        .collection('feedItems')
        .orderBy('thoiGianDang', descending: true)
        .limit(50)
        .get();
    snapshot.docs.forEach((element) {
      setState(() {
        Feed feed = Feed.fromDocument(element);
        feedItems.add(feed);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<FeedList>(context).addFeed(feedItems);
    return Scaffold(
      appBar: AppBar(
        title: Text("Thông Báo"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: Container(
          child: ListView.builder(
            itemCount: feedItems.length,
            itemBuilder: (context, index) {
              return ActivityFeedItem(
                feed: Provider.of<FeedList>(context).data.elementAt(index),
                user: widget.currentUser,
                index: index,
              );
            },
          ),
        ),
      ),
    );
  }
}
