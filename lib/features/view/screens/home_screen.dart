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
  final Set<String> likedPosts = {};

  Future<void> _likePost(Post post) async {
    final isNowLiked = !likedPosts.contains(post.id);
    setState(() {
      isNowLiked ? likedPosts.add(post.id) : likedPosts.remove(post.id);
    });
    await _postService.toggleLike(post.id, isLiked: isNowLiked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
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
                            onComment: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ViewDetailScreen(
                                  post: post,
                                  autoFocusComment: true,
                                ),
                              ),
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
