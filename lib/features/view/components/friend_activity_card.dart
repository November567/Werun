import 'package:flutter/material.dart';

class FriendActivityCard extends StatelessWidget {
  final String name;
  final String location;
  final String distance;
  final String duration;
  final String pace;
  final int likes;
  final int saves;

  const FriendActivityCard({
    required this.name,
    required this.location,
    required this.distance,
    required this.duration,
    required this.pace,
    required this.likes,
    required this.saves,
  });

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
          // Header (Name + Friend Badge)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[700],
                      backgroundImage: null,
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Location: $location',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'Friend',
                    style: TextStyle(
                      color: Colors.grey[300],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Activity Image
          Container(
            width: double.infinity,
            height: 160,
            color: Colors.grey[800],
            child: Image.network(
              'https://www.kku.ac.th/wp-content/uploads/2023/12/IMG_0832-scaled.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.image, color: Colors.grey[600], size: 48);
              },
            ),
          ),
          
          // Stats Section with dark background
          Container(
            color: const Color(0xFF1a1a1a),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Label
                const Text(
                  'Stats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Stats Row
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text(distance, 
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text(duration, 
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.directions_run, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text(pace, 
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Action Buttons Row
                Row(
                  children: [
                    // Like Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.thumb_up, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            '($likes)',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Save Button
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            '($saves)',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    
                    // Share Button
                    Row(
                      children: [
                        const Icon(Icons.share, size: 16, color: Colors.white),
                        const SizedBox(width: 4),
                        const Text(
                          'Share',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    
                    // Route Detail Button
                    const Text(
                      'Route detail',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}