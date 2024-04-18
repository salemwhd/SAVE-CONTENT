import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyFollowButton extends StatefulWidget {
  final String userId;

  const MyFollowButton({super.key, required this.userId});

  @override
  State<MyFollowButton> createState() => _MyFollowButtonState();
}

class _MyFollowButtonState extends State<MyFollowButton> {
  bool isFollowing = false;
  List<String> following = [];
  final usersCollection = FirebaseFirestore.instance.collection('Users');
  late final String userEmail;

  @override
  void initState() {
    super.initState();
    userEmail = widget.userId;
    fetchFollowing();
  }

  Future<void> sendFollowRequest() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
    DocumentSnapshot currentUserDoc =
        await usersCollection.doc(currentUserEmail).get();
    List<String> requestsSent =
        List<String>.from(currentUserDoc['RequestsSent']);

    if (requestsSent.contains(userEmail)) {
      // Follow request is already pending
      return;
    }

    await usersCollection.doc(userEmail).update({
      'followRequests': FieldValue.arrayUnion([currentUserEmail])
    });

    await usersCollection.doc(currentUserEmail).update({
      'RequestsSent': FieldValue.arrayUnion([userEmail])
    });

    setState(() {
      isFollowing = !isFollowing;
    });
  }

  Future<void> fetchFollowing() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
    DocumentSnapshot currentUserDoc =
        await usersCollection.doc(currentUserEmail).get();
    if (currentUserDoc.exists) {
      setState(() {
        following = List<String>.from(
            (currentUserDoc.data() as Map<String, dynamic>)['Following'] ?? []);
        isFollowing = following.contains(userEmail);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

    return currentUserEmail != widget.userId
        ? ElevatedButton(
            onPressed: () => sendFollowRequest(),
            child: Text(isFollowing ? 'Unfollow' : 'Follow'),
          )
        : const SizedBox.shrink(); // Replace this with your preferred widget
  }
}
