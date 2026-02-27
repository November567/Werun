import 'package:flutter/material.dart';
import '../screens/view_detail_screen.dart';

class ViewGridItem extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ViewGridItem({super.key, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewDetailScreen(imageUrl: imageUrl, title: title),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
