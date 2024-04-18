// import 'package:CONTGUARD/components/global_appBar.dart';
 import 'package:CONTGUARD/components/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  NotificationsPage({super.key});
  final currentUserEmail = FirebaseAuth.instance.currentUser!.email;

  Future<List<dynamic>> fetchFollowRequests(String currentUserEmail) async {
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserEmail)
        .get();

    if (doc.exists) {
      // If the document exists, return the "followRequests" field.
      return (doc.data() as Map<String, dynamic>)['followRequests']
          as List<dynamic>;
    } else {
      // If the document does not exist, throw an exception.
      throw Exception('User does not exist');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("user: $currentUserEmail");
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchFollowRequests(currentUserEmail!),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
           return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              return NotificationBar(request: snapshot.data?[index]);
            },
          );
          }
        },
      ),
    );
  }
}
