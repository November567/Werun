import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/post.dart';

class RunRouteCard extends StatelessWidget {
  final Post post;
  final VoidCallback onLike;
  final VoidCallback onTap;
  final VoidCallback? onComment;
  final bool isLiked;
  final bool isOwnPost;

  const RunRouteCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onTap,
    this.onComment,
    required this.isLiked,
    this.isOwnPost = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(
              children: [
                _UserAvatar(userId: post.userId, avatarUrl: post.userAvatar),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.userName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontSize: 14),
                          ),
                          if (!isOwnPost) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'FRIEND',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (post.location.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.white38, size: 12),
                            const SizedBox(width: 2),
                            Text(post.location,
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.white38),
              ],
            ),
          ),

          // ── Image ──
          GestureDetector(
            onTap: onTap,
            child: Image.network(
              post.imageUrl.isNotEmpty
                  ? post.imageUrl
                  : 'https://via.placeholder.com/400x200',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey[800],
                child: const Icon(Icons.map,
                    color: Colors.white38, size: 48),
              ),
            ),
          ),

          // ── Stats ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCol(value: post.distance, label: 'DIST', primary: primary),
                Container(width: 1, height: 28, color: Colors.white12),
                _StatCol(value: post.duration, label: 'TIME', primary: primary),
                Container(width: 1, height: 28, color: Colors.white12),
                _StatCol(value: post.pace, label: 'PACE', primary: primary),
              ],
            ),
          ),

          const Divider(height: 1),

          // ── Actions ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                // Like — padded for 44dp touch target
                GestureDetector(
                  onTap: onLike,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Row(
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? primary : Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text('${post.likes}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Comment count — tappable, padded for 44dp touch target
                GestureDetector(
                  onTap: onComment,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline,
                            color: Colors.white54, size: 20),
                        const SizedBox(width: 4),
                        Text('${post.comments.length}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    minimumSize: const Size(64, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Share', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    minimumSize: const Size(96, 44),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Route detail',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _kAnonymousAvatar =
    'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y';

class _UserAvatar extends StatelessWidget {
  final String userId;
  final String avatarUrl;

  const _UserAvatar({required this.userId, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[700],
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    if (userId.isEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey[700],
        backgroundImage: const NetworkImage(_kAnonymousAvatar),
      );
    }

    // Avatar not cached in post — fetch live from Firestore
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, snapshot) {
        final url = snapshot.hasData && snapshot.data!.exists
            ? (snapshot.data!.data() as Map<String, dynamic>)['avatarUrl']
                    as String? ??
                ''
            : '';
        return CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[700],
          backgroundImage: NetworkImage(url.isNotEmpty ? url : _kAnonymousAvatar),
        );
      },
    );
  }
}

class _StatCol extends StatelessWidget {
  final String value;
  final String label;
  final Color primary;

  const _StatCol(
      {required this.value, required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.isNotEmpty ? value : '--',
          style: TextStyle(
              color: primary, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
}
