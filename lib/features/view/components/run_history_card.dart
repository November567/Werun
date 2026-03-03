import 'package:flutter/material.dart';

class RunHistoryCard extends StatelessWidget {
  const RunHistoryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: double.infinity,
              height: 90,
              child: Image.asset(
                'images/Group6.jpeg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[800],
                  child: Icon(Icons.map, color: Colors.grey[600], size: 32),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Run History:',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          const Text(
            'อุทยานสวนเกษตร มข.',
            style: TextStyle(color: Colors.white70, fontSize: 11),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.green, size: 11),
              const SizedBox(width: 2),
              const Text('5.32 km', style: TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
          Row(
            children: [
              Icon(Icons.schedule, color: Colors.green, size: 11),
              const SizedBox(width: 2),
              const Text('1 hr. ', style: TextStyle(color: Colors.white70, fontSize: 10)),
              Icon(Icons.directions_run, color: Colors.green, size: 11),
              const SizedBox(width: 2),
              const Text('2 hr./Pace', style: TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {},
            child: const Text(
              'See more',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}