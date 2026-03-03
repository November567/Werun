import 'package:flutter/material.dart';

class FriendActivityCard extends StatefulWidget {
  final String name;
  final String location;
  final String distance;
  final String duration;
  final String pace;
  final int likes;
  final int saves;
  final String? imageUrl;
  final VoidCallback? onLike;
  final VoidCallback? onUnlike;
  final VoidCallback? onSave;
  final VoidCallback? onUnsave;

  const FriendActivityCard({
    Key? key,
    required this.name,
    required this.location,
    required this.distance,
    required this.duration,
    required this.pace,
    required this.likes,
    required this.saves,
    this.imageUrl,
    this.onLike,
    this.onUnlike,
    this.onSave,
    this.onUnsave,
  }) : super(key: key);

  @override
  State<FriendActivityCard> createState() => _FriendActivityCardState();
}

class _FriendActivityCardState extends State<FriendActivityCard> {
  late int _likes;
  late int _saves;
  bool _liked = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _likes = widget.likes;
    _saves = widget.saves;
  }

  @override
  void didUpdateWidget(FriendActivityCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_liked) _likes = widget.likes;
    if (!_saved) _saves = widget.saves;
  }

  void _handleLike() {
    setState(() {
      if (_liked) {
        _liked = false;
        _likes -= 1;
        widget.onUnlike?.call();
      } else {
        _liked = true;
        _likes += 1;
        widget.onLike?.call();
      }
    });
  }

  void _handleSave() {
    setState(() {
      if (_saved) {
        _saved = false;
        _saves -= 1;
        widget.onUnsave?.call();
      } else {
        _saved = true;
        _saves += 1;
        widget.onSave?.call();
      }
    });
  }

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
          // Header
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
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Location: ${widget.location}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
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
              widget.imageUrl ??
                  'https://www.kku.ac.th/wp-content/uploads/2023/12/IMG_0832-scaled.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.image, color: Colors.grey[600], size: 48);
              },
            ),
          ),

          // Stats Section
          Container(
            color: const Color(0xFF1a1a1a),
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stats',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text(widget.distance,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 16),
                    Icon(Icons.schedule, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text(widget.duration,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 16),
                    Icon(Icons.directions_run, color: Colors.green, size: 18),
                    const SizedBox(width: 6),
                    Text(widget.pace,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    // Like Button
                    GestureDetector(
                      onTap: _handleLike,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _liked ? Colors.green : Colors.grey[700],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              _liked ? Icons.thumb_up : Icons.thumb_up_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '($_likes)',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Save Button
                    GestureDetector(
                      onTap: _handleSave,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _saved ? Colors.blue : Colors.grey[700],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              _saved ? Icons.chat_bubble : Icons.chat_bubble_outline,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '($_saves)',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Share Button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share coming soon')),
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(Icons.share, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Share',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Route Detail Button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Route detail coming soon')),
                        );
                      },
                      child: const Text(
                        'Route detail',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
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