import 'package:flutter/material.dart';

class RunPlaceCard extends StatelessWidget {
  const RunPlaceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 90,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://images.unsplash.com/photo-1508609349937-5ec4ae374ebf',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'สวนเบญจกิติ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Easy · 4.61 km · 32m 30s',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                  ),
                  SizedBox(height: 6),
                  Text('See more', style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
