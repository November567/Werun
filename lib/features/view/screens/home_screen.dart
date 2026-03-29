import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/createPost/run_route_card.dart';
import '../../models/post.dart';
import '../../services/post_service.dart';
import 'view_detail_screen.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _postService = PostService();
  final Map<String, TextEditingController> _controllers = {};
  final Set<String> likedPosts = {};

  Future<void> _likePost(Post post) async {
    final isNowLiked = !likedPosts.contains(post.id);
    setState(() {
      isNowLiked ? likedPosts.add(post.id) : likedPosts.remove(post.id);
    });
    await _postService.toggleLike(post.id, isLiked: isNowLiked);
  }

  Future<void> _addComment(Post post) async {
    final controller = _controllers[post.id];
    if (controller == null || controller.text.isEmpty) return;
    final text = controller.text.trim();
    controller.clear();
    await _postService.addComment(post.id, 'You: $text');
  }

  TextEditingController _getController(String id) {
    _controllers.putIfAbsent(id, () => TextEditingController());
    return _controllers[id]!;
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs
              .map((doc) => Post.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RunRouteCard(
                    post: post,
                    isLiked: likedPosts.contains(post.id),
                    onLike: () => _likePost(post),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewDetailScreen(post: post),
                        ),
                      );
                    },
                  ),

                  // Last 2 comments preview
                  ...post.comments
                      .take(2)
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Text(
                            c,
                            style:
                                const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),

                  // Comment input
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _getController(post.id),
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Add comment...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.green),
                          onPressed: () => _addComment(post),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
