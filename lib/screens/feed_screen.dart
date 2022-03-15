import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';
import 'package:instagram_clone/widgets/post_card.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: width > webScreenSize
          ? null
          : AppBar(
              backgroundColor: width > webScreenSize
                  ? webBackgroundColor
                  : mobileBackgroundColor,
              centerTitle: false,
              title: SvgPicture.asset(
                "assets/ic_instagram.svg",
                color: primaryColor,
                height: 32,
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.messenger_outline,
                  ),
                ),
              ],
            ),
      body: Center(
        child: SizedBox(
          width: width > webScreenSize ? 600 : double.infinity,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("posts")
                .orderBy("datePublished", descending: true)
                .snapshots(),
            builder: (context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) => Container(
                  //width: width > webScreenSize ? 600 : double.infinity,
                  margin: EdgeInsets.symmetric(
                    vertical: width > webScreenSize ? 15 : 0,
                    // horizontal: width > webScreenSize ? width * 0.3 : 0
                  ),
                  child: PostCard(
                    snap: snapshot.data!.docs[index].data(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
