import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/global_variables.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    // _isShowUsers = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: "Search for user",
          ),
          onFieldSubmitted: (String _) {
            setState(() {
              _isShowUsers = true;
            });
          },
        ),
      ),
      body: _isShowUsers
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .where(
                    "username",
                    isGreaterThanOrEqualTo: _searchController.text,
                  )
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              uid: (snapshot.data! as dynamic).docs[index]
                                  ['uid'],
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            (snapshot.data! as dynamic).docs[index]['photoUrl'],
                          ),
                        ),
                        title: Text(
                          (snapshot.data! as dynamic).docs[index]['username'],
                        ),
                      ),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection("posts").get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // return GridView.countbuilder(
                //   itemCount: (snapshot.data! as dynamic).docs.length,
                //   gridDelegate: SliverQuiltedGridDelegate(
                //     crossAxisCount: 3,
                //     pattern: [],
                //   ),
                //   itemBuilder: (context, index) => Image.network(
                //     (snapshot.data! as dynamic).docs[index]['postUrl'],
                //   ),
                // );
                var patternMobile = [
                  const QuiltedGridTile(2, 2),
                  const QuiltedGridTile(1, 1),
                  const QuiltedGridTile(1, 1),
                ];

                var patternWeb = [
                  const QuiltedGridTile(1, 1),
                  const QuiltedGridTile(1, 1),
                  const QuiltedGridTile(1, 1),
                ];
                //pattern.shuffle();
                return GridView.custom(
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 3,
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                    pattern: MediaQuery.of(context).size.width > webScreenSize
                        ? patternWeb
                        : patternMobile,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) => Image.network(
                      (snapshot.data! as dynamic).docs[index]['postUrl'],
                    ),
                    childCount: (snapshot.data! as dynamic).docs.length,
                  ),
                );
              },
            ),
    );
  }
}
