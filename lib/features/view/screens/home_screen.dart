import 'package:flutter/material.dart';
import '../components/run_history_card.dart';
import '../components/suggested_places_card.dart';
import '../components/friend_activity_card.dart';
import 'create_post_screen.dart';
import 'view_detail_screen.dart'; // ✅ เพิ่ม
import '../../models/post.dart';
import '../../services/post_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final postService = PostService();

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostScreen(),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Run History & Suggested Places
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Row(
                  children: [
                    RunHistoryCard(),
                    SizedBox(width: 12),
                    SuggestedPlacesCard(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Friend Activities
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<List<Post>>(
                stream: postService.getPostsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading posts: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final posts = snapshot.data ?? [];

                  if (posts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Text(
                          'No posts yet. Create your first post!',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: posts
                        .map(
                          (post) => Column(
                            children: [
                              // ✅ ห่อด้วย GestureDetector
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ViewDetailScreen(post: post),
                                    ),
                                  );
                                },
                                child: FriendActivityCard(
                                  name: post.userName,
                                  location: post.tags.isNotEmpty
                                      ? post.tags.first
                                      : 'Unknown Location',
                                  distance: post.tags.length > 1
                                      ? post.tags[1]
                                      : '0 km',
                                  duration: '1 hr',
                                  pace: '12:00/min/km',
                                  likes: post.likes,
                                  saves: post.saves,
                                  imageUrl: post.imageUrl,
                                  onLike: () async {
                                    try {
                                      await postService.likePost(post.id);
                                    } catch (_) {}
                                  },
                                  onUnlike: () async {
                                    try {
                                      await postService.unlikePost(post.id);
                                    } catch (_) {}
                                  },
                                  onSave: () async {
                                    try {
                                      await postService.savePost(post.id);
                                    } catch (_) {}
                                  },
                                  onUnsave: () async {
                                    try {
                                      await postService.unsavePost(post.id);
                                    } catch (_) {}
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}