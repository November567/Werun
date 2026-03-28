import 'package:flutter/material.dart';
import '../../../models/post.dart';

class RunRouteCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onTap;

  const RunRouteCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // 🔥 กดทั้ง card
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🖼 IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                post.imageUrl.isNotEmpty
                    ? post.imageUrl
                    : 'https://via.placeholder.com/300',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),

            /// 📊 CONTENT
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🧑 USER
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: post.userAvatar.isNotEmpty
                            ? NetworkImage(post.userAvatar)
                            : null,
                        backgroundColor: Colors.grey,
                        child: post.userAvatar.isEmpty
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// 📍 RUN INFO
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        post.distance,
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(width: 16),

                      const Icon(
                        Icons.schedule,
                        color: Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        post.duration,
                        style: const TextStyle(color: Colors.white),
                      ),

                      const SizedBox(width: 16),

                      const Icon(
                        Icons.directions_run,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        post.pace,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// 📝 DESCRIPTION
                  if (post.description.isNotEmpty)
                    Text(
                      post.description,
                      style: const TextStyle(color: Colors.white70),
                    ),

                  const SizedBox(height: 10),

                  const Divider(color: Colors.white24),

                  /// 👍 LIKE + 💬 COMMENT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.thumb_up,
                              color: Colors.white,
                            ),
                            onPressed: onLike,
                          ),
                          Text(
                            "(${post.likes})",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          const Icon(Icons.comment, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            "(${post.comments.length})",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
