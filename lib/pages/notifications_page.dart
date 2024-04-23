// import 'package:CONTGUARD/components/global_appBar.dart';
import 'package:CONTGUARD/components/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

  Future<List<dynamic>> fetchFollowRequests(String currentUserEmail) async {
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserEmail)
        .get();

    if (doc.exists) {
      // If the document exists, return the "followRequests" field.
      return (doc.data() as Map<String, dynamic>)['RequestsReceived']
          as List<dynamic>;
    } else {
      // If the document does not exist, throw an exception.
      throw Exception('User does not exist');
    }
  }

  Future<void> acceptRequest(String request) async {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    DocumentReference currentUserDoc = users.doc(currentUserEmail);

    // Remove the request from the "followRequests" field
    await currentUserDoc.update({
      'RequestsReceived': FieldValue.arrayRemove([request])
    });

    // Add the user to the "Followers" field
    await currentUserDoc.update({
      'Followers': FieldValue.arrayUnion([request])
    });

    DocumentReference requestedUserDoc = users.doc(request);

    // Fetch the "Following" list of the requested user
    DocumentSnapshot requestedUserSnapshot = await requestedUserDoc.get();
    List<dynamic> followingList = requestedUserSnapshot.get('Following');

    // Check if the current user is already in the "Following" list
    if (!followingList.contains(currentUserEmail)) {
      // If not, add the current user to the "Following" list
      await requestedUserDoc.update({
        'Following': FieldValue.arrayUnion([currentUserEmail])
      });
    }

    await requestedUserDoc.update({
      'RequestsSent': FieldValue.arrayRemove([currentUserEmail])
    });
  }

  Future<void> ignoreRequest(String request) async {}

  @override
  Widget build(BuildContext context) {
    print("user: $currentUserEmail");
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchFollowRequests(currentUserEmail!),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            if (snapshot.data?.length == 0) {
              return const Center(child: Text('No Notifications'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return NotificationBar(
                    request: snapshot.data?[index],
                    acceptRequest: (String request) =>
                        acceptRequest(snapshot.data?[index]),
                    ignoreRequest: (String request) =>
                        ignoreRequest(snapshot.data?[index]),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
