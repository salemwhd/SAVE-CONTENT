import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final bool isLiked;

  const LikeButton({super.key, required this.isLiked, required this.onTap});
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.red : Colors.red,
      ),
    );
  }
}
