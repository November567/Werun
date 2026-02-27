import 'package:flutter/material.dart';

class ViewGridItem extends StatelessWidget {
  final String imageUrl;

  const ViewGridItem({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}
