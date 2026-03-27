import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/createPost/run_route_card.dart';
import '../components/createPost/media_section.dart';
import '../components/createPost/tags_section.dart';
import '../../models/post.dart';
import '../../services/post_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

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
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const Text(
              'Create New Post',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: isLoading ? null : () => _savePost(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.black,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Share',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
            const RunRouteCard(),
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

  // ==========================
  // SAVE POST (FIXED)
  // ==========================
  Future<void> _savePost() async {
    if (description.trim().isEmpty) {
      _showSnack('❌ Please add a description', Colors.red);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('❌ Please login again', Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔹 ดึงข้อมูล user จาก Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      final userData = userDoc.data()!;

      final postId = FirebaseFirestore.instance.collection('posts').doc().id;

      final post = Post(
        id: postId,
        userId: user.uid,
        userName: userData['nickName'] ?? 'Unknown',
        description: description.trim(),
        tags: tags,
        privacy: selectedPrivacy,
        imageUrl:
            selectedImageUrl ??
            'https://www.kku.ac.th/wp-content/uploads/2023/12/IMG_0832-scaled.jpg',
        createdAt: DateTime.now(),
      );

      await _postService.createPost(post);

      if (!mounted) return;

      Navigator.pop(context);

      _showSnack('✨ Post created successfully!', Colors.green);
    } catch (e) {
      debugPrint('[CreatePost] Error: $e');
      if (!mounted) return;
      _showSnack('❌ $e', Colors.red);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnack(String text, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }
}
