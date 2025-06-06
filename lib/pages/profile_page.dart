import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:CONTGUARD/components/global_appBar.dart';
import 'package:CONTGUARD/components/text_box.dart';
import 'package:CONTGUARD/components/wall_post.dart';
import 'package:CONTGUARD/helper/helper_method.dart';
import 'package:CONTGUARD/components/my_follow_button.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final String userEmail;
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  final storage = FirebaseStorage.instance;
  final picker = ImagePicker();
  late String? imageUrl;
  bool isFollowing = false;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    userEmail = widget.userId;
    fetchProfileImage().then((_) {
      setState(() {}); // Trigger a rebuild after fetching the image
    });
    checkIfFollowing();
  }

  Future<void> checkIfFollowing() async {
    try {
      final currentUserDoc = await usersCollection.doc(currentUser.email).get();
      if (currentUserDoc.exists &&
          currentUserDoc.data()!.containsKey('Following')) {
        final followingList =
            List<String>.from(currentUserDoc.data()!['Following']);
        setState(() {
          isFollowing = followingList.contains(userEmail);
        });
        print('Following list: $followingList');
        print('Is following: $isFollowing');
      } else {
        print('Following list not found or empty.');
      }
    } catch (e) {
      print('Error checking following status: $e');
    }
  }

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color.fromARGB(255, 197, 0, 251),
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: const TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          // cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          // save button
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue),
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    // update in Firestore
    if (newValue.trim().isNotEmpty) {
      // only update if there is something in textfield
      await usersCollection.doc(userEmail).update({field: newValue});
    }
  }

  Future<void> fetchProfileImage() async {
    final userData = await usersCollection.doc(userEmail).get();
    final profileImageUrl = userData.data()?['profileImageUrl'];
    setState(() {
      imageUrl = profileImageUrl;
    });
  }

  Future<void> uploadProfilePicture() async {
    print('uploadProfilePicture called');
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.email == userEmail) {
      print('User is authenticated and is viewing their own profile');
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        print('Image picked successfully');
        File imageFile = File(pickedFile.path);
        Reference ref = storage.ref().child('profile_images/$userEmail.jpg');
        UploadTask uploadTask = ref.putFile(imageFile);
        await uploadTask.whenComplete(() => null);
        String downloadUrl = await ref.getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
        });
        await usersCollection
            .doc(userEmail)
            .update({'profileImageUrl': downloadUrl});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(title: 'Profile Page'),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: usersCollection.doc(userEmail).get(),
                builder: (context, snapshot) {
                  // get user data
                  if (snapshot.hasData) {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        // profile pic
                        GestureDetector(
                          onTap: uploadProfilePicture,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: imageUrl != null
                                ? NetworkImage(imageUrl!)
                                : null,
                            child: imageUrl == null
                                ? const Icon(Icons.person,
                                    size: 72,
                                    color: Color.fromARGB(255, 148, 13, 202))
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // user email
                        Text(
                          userEmail,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          height: 30,
                          child: MyFollowButton(
                            userId: userEmail,
                          ),
                        ),
                        // username
                        MyTextBox(
                          text: userData['username'],
                          sectionName: 'username',
                          onPressed: () => editField('username'),
                        ),
                        // bio
                        MyTextBox(
                          text: userData['bio'],
                          sectionName: 'bio',
                          onPressed: () => editField('bio'),
                        ),
                        const SizedBox(height: 50),
                        // user posts
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              // display user posts
              isFollowing || userEmail == currentUser.email
                  ? StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("User Posts")
                          .where('UserEmail', isEqualTo: userEmail)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          // get all posts
                          final posts = snapshot.data!.docs;
                          return Column(
                            children: posts.map((post) {
                              final data = post.data() as Map<String, dynamic>?;
                              final imageUrl = data?['ImageUrl'];
                              return WallPost(
                                user: post['UserEmail'],
                                message: post['Message'],
                                postId: post.id,
                                likes: List<String>.from(post['Likes'] ?? []),
                                time: formatDate(post['TimeStamp']),
                                imageUrl: imageUrl,
                                originalAuthor: data?['OriginalAuthor'],
                              );
                            }).toList(), // display user posts
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    )
                  : Center(
                      child: Text("Follow to see posts!"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
