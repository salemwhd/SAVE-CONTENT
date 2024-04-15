// ignore_for_file: unused_field

import 'package:CONTGUARD/pages/new_post_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:CONTGUARD/components/global_appBar.dart';
import 'package:CONTGUARD/components/text_field.dart';
import 'package:CONTGUARD/components/wall_post.dart';
import 'package:CONTGUARD/helper/helper_method.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  //text controller
  final textController = TextEditingController();
  String? _pickedImagePath;

  Future<void> _requestGalleryPermission() async {
    var status = await Permission.photos.status;
    if (status.isDenied) {
      await Permission.photos.request();
    }
  }

  Future<void> _pickImage() async {
    await _requestGalleryPermission();

    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // Update the variable with the picked image path
      _pickedImagePath = pickedImage.path;
    }
  }

  // HomePage.dart
  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return NewPostScreen(); // Navigate to the NewPostScreen
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
                child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("User Posts")
                  .orderBy("TimeStamp", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      //get the post
                      final post = snapshot.data!.docs[index];
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
                  return CircularProgressIndicator();
                }
              },
            )),
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
