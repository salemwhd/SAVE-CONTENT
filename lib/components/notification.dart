import 'package:flutter/material.dart';

class NotificationBar extends StatefulWidget {
  const NotificationBar({
    super.key,
    required this.request,
    required this.acceptRequest,
    required this.ignoreRequest,
  });
  final String request;
  final Function(String) acceptRequest;
  final Function(String) ignoreRequest;
  @override
  State<NotificationBar> createState() => _NotificationBarState();
}

class _NotificationBarState extends State<NotificationBar> {
  bool requestHandled = false;

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
            if (!requestHandled)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      widget.acceptRequest(widget.request);
                      setState(() {
                        requestHandled = true;
                      });
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue)),
                    child: const Text('Accept'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      widget.ignoreRequest(widget.request);
                      setState(() {
                        requestHandled = true;
                      });
                    },
                    child: const Text('Ignore'),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
