import 'package:CONTGUARD/pages/new_post_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:CONTGUARD/components/global_appBar.dart';
import 'package:CONTGUARD/components/text_field.dart';
import 'package:CONTGUARD/components/wall_post.dart';
import 'package:CONTGUARD/helper/helper_method.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser!.email;

  final textController = TextEditingController();

  // Fetch the list of users the current user is following
  Future<List<String>> _getFollowingUsers() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser)
          .get();
      final following = List<String>.from(userDoc.data()?['Following'] ?? []);
      print('Following users: $following');
      return following;
    } catch (e) {
      print('Error fetching following users: $e');
      return [];
    }
  }

  // HomePage.dart
  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const NewPostScreen(); // Navigate to the NewPostScreen
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(253, 253, 253, 1),
      appBar: const GlobalAppBar(
        title: 'HOME',
      ),
      body: Center(
        child: Column(
          children: [
            //the wall
            Expanded(
              child: FutureBuilder<List<String>>(
                future: _getFollowingUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No posts to display');
                  }

                  final followingUsers = snapshot.data!;
                  // Check the number of following users
                  print('Number of following users: ${followingUsers.length}');

                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("User Posts")
                        .where('UserEmail',
                            whereIn: followingUsers.isNotEmpty
                                ? followingUsers
                                : ['dummy']) // Ensure no error with empty list
                        .orderBy("TimeStamp", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final docs = snapshot.data!.docs;
                        // Check the number of posts fetched
                        print('Number of posts fetched: ${docs.length}');

                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            //get the post
                            final post = docs[index];
                            return WallPost(
                              user: post['UserEmail'],
                              message: post['Message'],
                              postId: post.id,
                              likes: List<String>.from(post['Likes'] ?? []),
                              time: formatDate(post['TimeStamp']),
                              imageUrl: post.data().containsKey('ImageUrl')
                                  ? post['ImageUrl']
                                  : null,
                              originalAuthor:
                                  post.data().containsKey('OriginalAuthor')
                                      ? post['OriginalAuthor']
                                      : null,
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return const CircularProgressIndicator();
                      }
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: _openBottomSheet,
                child: AbsorbPointer(
                  child: MyTextField(
                    controller: textController,
                    hintText: "Write something on the wall...",
                    obscureText: false,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
