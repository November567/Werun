import 'package:flutter/material.dart';

class ViewGridItem extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ViewGridItem({super.key, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade800,
            child: const Icon(Icons.broken_image,
                color: Colors.white54, size: 32),
          ),
        ),
      ),
    );
  }
}