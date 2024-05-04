import 'dart:convert';
import 'package:http/http.dart' as http;
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

  Future<Map<String, dynamic>> calculateSimilarity(String inputText) async {
    late http.Response response;
    try {
      response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/similarity'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'input_text': inputText,
        }),
      );
    } catch (e) {
      print('Caught exception: $e');
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Failed to calculate similarity');
      throw Exception('Failed to calculate similarity');
    }
  }

  void postMessage(bool isTextCopyrighted, bool isImageCopyrighted) async {
    String inputText = textController.text;

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
        'isTextCopyrighted': isTextCopyrighted,
        'isImageCopyrighted': isImageCopyrighted,
      });
      setState(() {
        textController.clear();
        _pickedImagePath = null;
      });
      //Navigator.pop(context);
    }
    if (isTextCopyrighted) {
      Map<String, dynamic> similarityScores =
          await calculateSimilarity(inputText);
      print('Similarity Scores: $similarityScores'); // Debugging line
      _showSimilarityScores(similarityScores);
      print('Show Similarity Scores method executed'); // Debugging line
    }
  }

  void _showSimilarityScores(Map<String, dynamic> similarityScores) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Similarity Scores'),
            content: Text(jsonEncode(similarityScores)),
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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
                      maxLines: 4,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: _pickImage,
                  ),
                ],
              ),
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
                    postMessage(isTextCopyrighted, isImageCopyrighted);
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
