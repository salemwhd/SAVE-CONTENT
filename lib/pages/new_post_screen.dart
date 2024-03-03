import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:CONTGUARD/components/global_appBar.dart';
import 'package:CONTGUARD/components/post_button.dart';
import 'package:flutter/material.dart';
import 'package:CONTGUARD/components/text_field.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({Key? key}) : super(key: key);

  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final textController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser!;
  String? _pickedImagePath;
  int wordCount = 0; // New state variable
  bool isTextCopyrighted = false;
  bool isImageCopyrighted = false;
  @override
  void initState() {
    super.initState();
    textController
        .addListener(_updateWordCount); // Add listener to textController
  }

  @override
  void dispose() {
    textController.removeListener(_updateWordCount); // Remove listener
    super.dispose();
  }

  void _updateWordCount() {
    setState(() {
      wordCount = textController.text
          .split(' ')
          .where((word) => word.isNotEmpty)
          .length;
    });
  }

  void postMessage() async {
    if (textController.text.isNotEmpty) {
      String? imageUrl;
      if (_pickedImagePath != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('post_images')
            .child(DateTime.now().toString() + '.jpg');

        await ref.putFile(File(_pickedImagePath!));

        imageUrl = await ref.getDownloadURL();
      }

      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentUser.email,
        'Message': textController.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
        'ImageUrl': imageUrl,
      });

      setState(() {
        textController.clear();
        _pickedImagePath = null;
      });
      Navigator.pop(context);
    }
  }

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
      setState(() {
        _pickedImagePath = pickedImage.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlobalAppBar(title: 'New Post'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: MyTextField(
                      controller: textController,
                      hintText: "Write something on the wall...",
                      obscureText: false,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              //make it in left
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Text Copyright'),
                      Checkbox(
                        value: isTextCopyrighted,
                        onChanged: (bool? value) {
                          setState(() {
                            isTextCopyrighted = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(width: 100),
                  Text('Word count: $wordCount'),
                ],
              ),
              if (_pickedImagePath != null)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Image.file(
                        File(_pickedImagePath!),
                        height: 300, // you can adjust the size as needed
                        width: double.infinity,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Image Copyright'),
                        Checkbox(
                          value: isImageCopyrighted,
                          onChanged: (bool? value) {
                            setState(() {
                              isImageCopyrighted = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
              PostButton(
                onPressed: () {
                  if (!isTextCopyrighted || wordCount >= 100) {
                    postMessage();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter at least 100 words'),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
