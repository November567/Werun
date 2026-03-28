import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/createPost/run_route_card.dart';
import '../../models/post.dart';
import 'view_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, TextEditingController> _controllers = {};

  /// 👍 LIKE
  Future<void> _likePost(Post post) async {
    await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
      'likes': FieldValue.increment(1),
    });
  }

  /// 💬 ADD COMMENT
  Future<void> _addComment(Post post) async {
    final controller = _controllers[post.id];
    if (controller == null || controller.text.trim().isEmpty) return;

    final text = controller.text.trim();
    final newComment = "You: $text";

    await FirebaseFirestore.instance.collection('posts').doc(post.id).update({
      'comments': FieldValue.arrayUnion([newComment]),
    });

    controller.clear();
  }

  TextEditingController _getController(String postId) {
    if (!_controllers.containsKey(postId)) {
      _controllers[postId] = TextEditingController();
    }
    return _controllers[postId]!;
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No posts yet",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final posts = snapshot.data!.docs.map((doc) {
            return Post.fromFirestore(doc);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final controller = _getController(post.id);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔥 CARD
                  RunRouteCard(
                    post: post,
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

                  /// 💬 COMMENT LIST (แสดง 2 อันล่าสุด)
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
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),

                  /// ✍️ COMMENT INPUT
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              controller: controller,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: "Add a comment...",
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
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

                  const SizedBox(height: 10),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
