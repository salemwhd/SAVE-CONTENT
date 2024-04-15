import 'package:CONTGUARD/components/global_appBar.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: GlobalAppBar(title: 'Notifications'),
      body: Center(child: Text('hello')),
    );
  }
}
