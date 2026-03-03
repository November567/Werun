import 'package:flutter/material.dart';
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
  bool shareToSuggested = false;
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
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
        title: const Text(
          'Create New Post',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: isLoading ? null : () => _savePost(),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Share',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              RunRouteCard(),
              const SizedBox(height: 20),

              MediaSection(
                onImageChanged: (url) {
                  setState(() {
                    selectedImageUrl = url;
                  });
                  debugPrint('Image URL updated: $url');
                },
              ),
              const SizedBox(height: 20),

              TagsSection(
                tags: tags,
                onTagsChanged: (newTags) {
                  setState(() {
                    tags = newTags;
                  });
                },
                description: description,
                onDescriptionChanged: (newDescription) {
                  setState(() {
                    description = newDescription;
                  });
                },
                selectedPrivacy: selectedPrivacy,
                onPrivacyChanged: (value) {
                  setState(() {
                    selectedPrivacy = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2a2a2a),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Checkbox(
                      value: shareToSuggested,
                      onChanged: (value) {
                        setState(() {
                          shareToSuggested = value ?? false;
                        });
                      },
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.green;
                        }
                        return Colors.grey[700];
                      }),
                      side: BorderSide(color: Colors.grey[600]!),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Also Share to Suggested Places?',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: isLoading ? null : () => _savePost(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
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
              const SizedBox(height: 20),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _savePost() async {
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Please add a description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      debugPrint('[CreatePost] Creating post...');
      debugPrint('[CreatePost] Description: $description');
      debugPrint('[CreatePost] Tags: $tags');
      debugPrint('[CreatePost] Privacy: $selectedPrivacy');
      debugPrint('[CreatePost] Image URL: $selectedImageUrl');

      final post = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'user123',
        userName: 'Mr.Gunny',
        description: description,
        tags: tags,
        privacy: selectedPrivacy,
        imageUrl: selectedImageUrl ?? 'https://www.kku.ac.th/wp-content/uploads/2023/12/IMG_0832-scaled.jpg',
        createdAt: DateTime.now(),
      );

      debugPrint('[CreatePost] Saving to Firebase...');
      await _postService.createPost(post);
      debugPrint('[CreatePost] Post saved successfully!');

      if (!mounted) {
        debugPrint('[CreatePost] Widget not mounted, skipping navigation');
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      debugPrint('[CreatePost] Navigating back to home');
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Post created successfully! ✨'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('[CreatePost] Error: $e');
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}