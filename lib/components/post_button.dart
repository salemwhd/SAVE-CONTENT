import 'package:flutter/material.dart';

class PostButton extends StatelessWidget {
  final void Function() onPressed;

  const PostButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.blue),
        foregroundColor: MaterialStateProperty.all(Colors.white),
      ),
      child:  const Text('Post'),
    );
  }
}
