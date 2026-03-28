import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/createPost/run_route_card.dart';
import '../components/createPost/media_section.dart';
import '../components/createPost/tags_section.dart';
import '../../models/post.dart';
import '../../services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String selectedPrivacy = 'public';
  String description = '';
  List<String> tags = ['Khon Kaen', 'Night Run'];

  bool isLoading = false;
  String? selectedImageUrl;

  final PostService _postService = PostService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,

        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),

            const Text(
              'Create New Post',
              style: TextStyle(color: Colors.white),
            ),

            GestureDetector(
              onTap: isLoading ? null : _savePost,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        "Share",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ❌ ห้าม const เพราะต้องส่ง data
            RunRouteCard(
              post: Post(
                id: '',
                userId: '',
                userName: 'Preview',
                description: description,
                tags: tags,
                privacy: selectedPrivacy,
                imageUrl: selectedImageUrl ?? 'https://picsum.photos/400/200',
                createdAt: DateTime.now(),
              ),
              isLiked: false, // ✅ เพิ่มตรงนี้
              onLike: () {},
              onTap: () {},
            ),

            const SizedBox(height: 20),

            MediaSection(
              onImageChanged: (url) {
                setState(() => selectedImageUrl = url);
              },
            ),

            const SizedBox(height: 20),

            TagsSection(
              tags: tags,
              description: description,
              selectedPrivacy: selectedPrivacy,
              onTagsChanged: (value) => setState(() => tags = value),
              onDescriptionChanged: (value) =>
                  setState(() => description = value),
              onPrivacyChanged: (value) =>
                  setState(() => selectedPrivacy = value),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePost() async {
    if (description.trim().isEmpty) {
      _showSnack('❌ Please add description', Colors.red);
      return;
    }

    if (selectedImageUrl == null) {
      _showSnack('❌ Please add photo', Colors.red);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('❌ Please login again', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User not found");
      }

      final userData = userDoc.data()!;

      final postId = FirebaseFirestore.instance.collection('posts').doc().id;

      final post = Post(
        id: postId,
        userId: user.uid,
        userName: userData['nickName'] ?? 'Unknown',
        userAvatar: userData['avatar'] ?? '',
        description: description.trim(),
        tags: tags,
        privacy: selectedPrivacy,
        imageUrl: selectedImageUrl!,
        location: tags.isNotEmpty ? tags.first : '',
        distance: '5.32 กม.',
        duration: '1 ชม.',
        pace: '12:00 นาที/กม.',
        createdAt: DateTime.now(),

        // 🔥 สำคัญ
        likes: 0,
        comments: [],
      );

      await _postService.createPost(post);

      if (!mounted) return;

      Navigator.pop(context);
      _showSnack('✅ Post created!', Colors.green);
    } catch (e) {
      _showSnack('❌ $e', Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnack(String text, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }
}
