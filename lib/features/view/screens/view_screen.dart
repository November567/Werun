import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post.dart'; // ✅ เปลี่ยนจาก post_model.dart
import '../components/view_grid_item.dart';
import 'view_detail_screen.dart';

class ViewScreen extends StatefulWidget {
  const ViewScreen({super.key});

  @override
  State<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Post> _allPosts = [];
  List<Post> _filteredPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _searchController.addListener(() {
      _filterSearch(_searchController.text);
    });
  }

  Future<void> _fetchPosts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();

      final posts = snapshot.docs
          .map((doc) => Post.fromFirestore(doc))
          .toList();

      setState(() {
        _allPosts = posts;
        _filteredPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error fetching posts: $e');
    }
  }

  void _filterSearch(String query) {
    final results = _allPosts.where((post) {
      final title = post.title.toLowerCase();
      final username = post.userName.toLowerCase(); // ✅ userName
      return title.contains(query.toLowerCase()) ||
          username.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredPosts = results;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "ค้นหา",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 📷 Grid
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Colors.green),
                    )
                  : _filteredPosts.isEmpty
                      ? const Center(
                          child: Text(
                            'ไม่พบโพสต์',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchPosts,
                          color: Colors.green,
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: _filteredPosts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemBuilder: (context, index) {
                              final post = _filteredPosts[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ViewDetailScreen(post: post),
                                    ),
                                  );
                                },
                                child: ViewGridItem(
                                  imageUrl: post.imageUrl,
                                  title: post.title,
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}