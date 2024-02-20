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
              if (_pickedImagePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.file(
                    File(_pickedImagePath!),
                    height: 300, // you can adjust the size as needed
                    width: double.infinity,
                    fit: BoxFit.fill,
                  ),
                ),
              const SizedBox(height: 16.0),
              PostButton(
                onPressed: postMessage,
              )
            ],
          ),
        ),
      ),
    );
  }
}
