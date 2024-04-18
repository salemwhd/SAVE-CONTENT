import 'package:flutter/material.dart';

class NotificationBar extends StatefulWidget {
  const NotificationBar({super.key});

  @override
  State<NotificationBar> createState() => _NotificationBarState();
}

class _NotificationBarState extends State<NotificationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Card(
        elevation: 30,
        child: Row(
          children: [
            const Icon(
              Icons.person,
              size: 40,
            ),
            const Text('Friend request from ..'),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.blue)),
              child: const Text('Accept'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('ignore'),
            ),
          ],
        ),
      ),
    );
  }
}
