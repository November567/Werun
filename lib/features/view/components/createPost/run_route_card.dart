import 'package:flutter/material.dart';

class RunRouteCard extends StatelessWidget {
  const RunRouteCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map Preview with Image
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[800],
            child: Image.asset(
              'images/Group6.jpeg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[800],
                  child: Icon(Icons.map, color: Colors.grey[600], size: 64),
                );
              },
            ),
          ),

          // Stats Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                const Text(
                  '5.32 กม.',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Icon(Icons.schedule, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                const Text(
                  '1 ชม.',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 16),
                Icon(Icons.cloud, color: Colors.green, size: 16),
                const SizedBox(width: 6),
                const Text(
                  '12:00 นาที/กม.',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}