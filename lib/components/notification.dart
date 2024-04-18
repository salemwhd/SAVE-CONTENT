import 'package:flutter/material.dart';

class NotificationBar extends StatefulWidget {
  const NotificationBar({super.key, required this.request});
  final String request;

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
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 40,
                ),
                Text('Friend request from ${widget.request}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
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
            )
          ],
        ),
      ),
    );
  }
}
