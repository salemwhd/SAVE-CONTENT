import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlobalAppBar({super.key, required this.title});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  final String title;
  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    return AppBar(
      leading: currentUser != null
          ? StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(currentUser.email)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Icon(Icons.account_circle);
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                Map<String, dynamic> data =
                    snapshot.data!.data() as Map<String, dynamic>;
                String? profilePicUrl = data['profileImageUrl'];

                return CircleAvatar(
                  backgroundImage: profilePicUrl != null
                      ? NetworkImage(profilePicUrl)
                      : null,
                );
              },
            )
          : const Icon(Icons.account_circle),
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
      ),
      backgroundColor: const Color.fromARGB(255, 135, 1, 172),
      actions: [IconButton(onPressed: signOut, icon: Icon(Icons.logout))],
    );
  }
}
