import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyFollowButton extends StatefulWidget {
  final String userId;

  const MyFollowButton({Key? key, required this.userId}) : super(key: key);

  @override
  _MyFollowButtonState createState() => _MyFollowButtonState();
}

class _MyFollowButtonState extends State<MyFollowButton> {
  bool isFollowing = false;
  bool isPending = false;

  @override
  void initState() {
    super.initState();
    checkFollowStatus();
  }

  Future<void> checkFollowStatus() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;
    final currentUserDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserEmail)
        .get();

    if (currentUserDoc.exists) {
      final following = List<String>.from(
          (currentUserDoc.data() as Map<String, dynamic>)['Following'] ?? []);
      final requestsSent = List<String>.from(
          (currentUserDoc.data() as Map<String, dynamic>)['RequestsSent'] ??
              []);

      setState(() {
        isFollowing = following.contains(widget.userId);
        isPending = requestsSent.contains(widget.userId);
      });
    }
  }

  Future<void> sendFollowRequest() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

    // Add the target user to the RequestsSent list in the current user's document.
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserEmail)
        .update({
      'RequestsSent': FieldValue.arrayUnion([widget.userId]),
    });

    // Add the current user to the followRequests list in the target user's document.
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .update({
      'followRequests': FieldValue.arrayUnion([currentUserEmail]),
    });

    checkFollowStatus();
  }

  Future<void> unfollow() async {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

    await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserEmail)
        .update({
      'Following': FieldValue.arrayRemove([widget.userId]),
    });

    checkFollowStatus();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

    return currentUserEmail != widget.userId
        ? ElevatedButton(
            onPressed:
                isFollowing ? unfollow : (isPending ? null : sendFollowRequest),
            child: Text(
                isFollowing ? 'Unfollow' : (isPending ? 'Pending' : 'Follow')),
          )
        : const SizedBox.shrink(); // Replace this with your preferred widget
  }
}
