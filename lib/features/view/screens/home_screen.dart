import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/createPost/run_route_card.dart';
import '../components/suggested_places_card.dart';
import '../components/home_app_bar.dart';
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
    final uid = FirebaseAuth.instance.currentUser?.uid;
    String userName = 'Me';
    String userAvatar = '';
    if (uid != null) {
      final userData = await _postService.getUserData(uid);
      userName = userData['nickName'] ?? userData['fullName'] ?? 'Me';
      userAvatar = userData['avatarUrl'] ?? '';
    }
    await _postService.addComment(post.id, {
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
    });
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
      backgroundColor: const Color(0xFF0E0E0E),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreatePostScreen()),
        ),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const HomeAppBar(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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

                  // items: [suggested, socialFeedHeader, ...posts]
                  final itemCount = posts.length + 2;

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: itemCount,
                    itemBuilder: (context, index) {
                      // index 0 → Suggested Places
                      if (index == 0) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 8, bottom: 20),
                          child: SuggestedPlacesSection(),
                        );
                      }

                      // index 1 → Social Feed header
                      if (index == 1) {
                        return const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Text(
                            'Social Feed',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }

                      final post = posts[index - 2];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RunRouteCard(
                            post: post,
                            isLiked: likedPosts.contains(post.id),
                            isOwnPost: post.userId == FirebaseAuth.instance.currentUser?.uid,
                            onLike: () => _likePost(post),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewDetailScreen(post: post),
                              ),
                            ),
                          ),

                          // Last 2 comments preview
                          ...post.comments.take(2).map(
                                (c) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 13,
                                        backgroundImage: NetworkImage(
                                          (c['userAvatar'] as String?)?.isNotEmpty == true
                                              ? c['userAvatar'] as String
                                              : 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: RichText(
                                          text: TextSpan(
                                            style: const TextStyle(fontSize: 13),
                                            children: [
                                              TextSpan(
                                                text: '${c['userName'] ?? ''} ',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                              TextSpan(
                                                text: c['text'] ?? '',
                                                style: const TextStyle(
                                                    color: Colors.white60),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                          // Comment input
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _getController(post.id),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                    decoration: InputDecoration(
                                      hintText: 'Add a comment...',
                                      hintStyle: const TextStyle(
                                          color: Colors.white38, fontSize: 13),
                                      filled: true,
                                      fillColor: const Color(0xFF1A1A1A),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(24),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.send,
                                      color: Theme.of(context).colorScheme.primary, size: 20),
                                  onPressed: () => _addComment(post),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 4),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
