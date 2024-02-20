import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String username;
  final String bio;

  const UserTile({
    super.key,
    required this.username,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.person),
      title: Text(username),
      subtitle: Text(bio),
    );
  }
}
