import 'package:CONTGUARD/pages/profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:CONTGUARD/components/comment.dart';
import 'package:CONTGUARD/components/like_button.dart';
import 'package:CONTGUARD/helper/helper_method.dart';

import 'comment_button.dart';

class WallPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  final String? imageUrl;
  final String? originalAuthor;
  const WallPost({
    super.key,
    required this.user,
    required this.time,
    required this.message,
    required this.postId,
    required this.likes,
    this.imageUrl,
    this.originalAuthor,
  });

  @override
  State<WallPost> createState() => _WallPostState();
}

class _WallPostState extends State<WallPost> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  late final String userEmail;

  bool isLiked = false;

  //comment text controller
  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
    userEmail = widget.user;
  }

  //toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    //Access the document in firebase

    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      //if the post is now liked, add the users email to the liked field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      //if the post is unliked , remove the users email from liked field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  //add a comment
  void addComment(String commentText) {
    //write a comment to firestore under the comments collection of this post
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now(), //remember to format this when displaying
    });
  }

  //show a dialog box for adding comment
  void showCommentDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Add Comment"),
              content: TextField(
                controller: _commentTextController,
                decoration:
                    const InputDecoration(hintText: "Write a comment..."),
              ),
              actions: [
                //cancel button
                TextButton(
                    onPressed: () => {
                          Navigator.pop(context),
                          _commentTextController.clear()
                        },
                    //clear controller

                    child: const Text("Cancel")),

                //post button
                TextButton(
                    onPressed: () => {
                          addComment(_commentTextController.text),
                          //pop box
                          Navigator.pop(context),

                          _commentTextController.clear(),
                        },
                    child: const Text("Post")),
              ],
            ));
  }

  void deletePost() {
    FirebaseFirestore.instance
        .collection('User Posts')
        .doc(widget.postId)
        .delete();
  }

  void sharePost() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
    final postsCollection = FirebaseFirestore.instance.collection('User Posts');
    final newPostId = postsCollection.doc().id;

    await postsCollection.doc(newPostId).set({
      'UserEmail': currentUserEmail,
      'Message': widget.message,
      'Likes': [],
      'TimeStamp': Timestamp.now(),
      'ImageUrl': widget.imageUrl,
      'OriginalAuthor': widget.user,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post has been shared!')),
    );
  }

  Future<String> fetchProfilePic(String userEmail) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userEmail)
        .get();

    return userDoc.get('profileImageUrl') as String;
  }

  void goToProfilePage(BuildContext ctx, {String? userEmail}) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (ctx) => ProfilePage(
          userId: userEmail!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final image = widget.image;
    return FutureBuilder<String>(
        future: fetchProfilePic(widget.user),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          final profilePicUrl = snapshot.data;

          return Container(
            decoration: BoxDecoration(
              //color: Color.fromARGB(255, 80, 10, 126),
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 167, 79, 226),
                  Color.fromARGB(255, 80, 10, 126),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profilePicUrl != null)
                  InkWell(
                    onTap: (() {
                      goToProfilePage(context, userEmail: userEmail);
                    }),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        profilePicUrl,
                      ),
                      radius: 30,
                    ),
                  )
                else
                  InkWell(
                    onTap: (() {
                      goToProfilePage(context, userEmail: userEmail);
                    }),
                    child: const Icon(
                      Icons.person,
                      size: 30,
                    ),
                  ),
                if (widget.imageUrl != null) Image.network(widget.imageUrl!),
                const SizedBox(
                  width: 20,
                ),

                //message and user email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),

                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        if (widget.originalAuthor != null)
                          InkWell(
                            onTap: () {
                              goToProfilePage(context,
                                  userEmail: widget.originalAuthor);
                            },
                            child: Text(
                              'Shared from ${widget.originalAuthor}',
                              style: const TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          Text(
                            widget.user,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        const Text(
                          " . ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          widget.time,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                    //buttons

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //LIKE
                        Column(
                          children: [
                            //like button
                            LikeButton(isLiked: isLiked, onTap: toggleLike),

                            const SizedBox(
                              height: 5,
                            ),

                            //like count

                            Text(widget.likes.length.toString())
                          ],
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        //COMMENT
                        Column(
                          children: [
                            //comment button
                            CommentButton(onTap: showCommentDialog),

                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        if (currentUser.email == widget.user)
                          Column(
                            children: [
                              // delete button
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: deletePost,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.screen_share_rounded,
                                  color: Colors.blue),
                              onPressed: sharePost,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    //comments under the post
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("User Posts")
                            .doc(widget.postId)
                            .collection("Comments")
                            .orderBy("CommentTime", descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          //show loading circle if no data yet
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return ListView(
                            shrinkWrap: true, //for nested lists
                            physics: const NeverScrollableScrollPhysics(),
                            children: snapshot.data!.docs.map((doc) {
                              //get the comment
                              final commentData =
                                  doc.data() as Map<String, dynamic>;

                              //return the comment
                              return Comment(
                                  text: commentData["CommentText"],
                                  user: commentData["CommentedBy"],
                                  time: formatDate(commentData["CommentTime"]));
                            }).toList(),
                          );
                        })
                  ],
                )
              ],
            ),
          );
        });
  }
}
