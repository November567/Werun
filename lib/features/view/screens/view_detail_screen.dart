import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post.dart';
import '../../services/post_service.dart';

class ViewDetailScreen extends StatefulWidget {
  final Post post;

  const ViewDetailScreen({super.key, required this.post});

  @override
  State<ViewDetailScreen> createState() => _ViewDetailScreenState();
}

class _ViewDetailScreenState extends State<ViewDetailScreen>
    with SingleTickerProviderStateMixin {
  final _postService = PostService();
  final TextEditingController _commentController = TextEditingController();

  bool isLiked = false;

  late AnimationController _likeController;
  late Animation<double> _likeAnimation;

  String currentUser = "Carly Mensch";

  @override
  void initState() {
    super.initState();

    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _likeAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );
  }

  /// 👍 LIKE
  Future<void> _toggleLike() async {
    setState(() => isLiked = !isLiked);
    await _postService.toggleLike(widget.post.id, isLiked: isLiked);
    _likeController.forward().then((_) => _likeController.reverse());
  }

  /// 💬 COMMENT
  Future<void> _addComment(String text) async {
    await _postService.addComment(widget.post.id, '$currentUser: $text');
  }

  /// 🔗 SHARE (สวย + มีข้อมูลครบ)
  void _sharePost(Post post) {
    final text =
        """
🏃‍♂️ WeRun แชร์เส้นทางวิ่ง

👤 ${post.userName}
📍 ${post.location}
📏 ระยะทาง: ${post.distance}
⏱ เวลา: ${post.duration}
⚡ Pace: ${post.pace}

📝 ${post.description}

📲 ดูเพิ่มเติมใน WeRun App
""";

    Share.share(text);
  }

  @override
  void dispose() {
    _likeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.post.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final post = Post.fromMap(data);

          final comments = List<String>.from(data['comments'] ?? []);
          final likes = data['likes'] ?? 0;

          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔙 HEADER
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        CircleAvatar(
                          backgroundImage: post.userAvatar.isNotEmpty
                              ? NetworkImage(post.userAvatar)
                              : null,
                          backgroundColor: Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          post.userName,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),

                  /// 🖼 IMAGE
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      post.imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 250,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 50,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// 📊 RUN INFO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoItem(Icons.location_on, post.distance),
                        _infoItem(Icons.access_time, post.duration),
                        _infoItem(Icons.directions_run, post.pace),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 🔥 ACTION BAR (IG STYLE)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        /// 👍 LIKE
                        ScaleTransition(
                          scale: _likeAnimation,
                          child: IconButton(
                            icon: Icon(
                              isLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              color: isLiked
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                            ),
                            onPressed: _toggleLike,
                          ),
                        ),

                        Text(
                          "$likes",
                          style: const TextStyle(color: Colors.white),
                        ),

                        const SizedBox(width: 20),

                        /// 💬 COMMENT
                        const Icon(Icons.comment, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          "${comments.length}",
                          style: const TextStyle(color: Colors.white),
                        ),

                        const Spacer(),

                        /// 🔗 SHARE (ปุ่มสวย)
                        GestureDetector(
                          onTap: () => _sharePost(post),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.share,
                                  size: 18,
                                  color: Colors.black,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "Share",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Colors.white24),

                  /// 📝 DESCRIPTION
                  if (post.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        post.description,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),

                  /// 💬 COMMENT LIST (Realtime)
                  ...comments.map(
                    (c) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        c,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// 📝 INPUT COMMENT
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextField(
                              controller: _commentController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: "Add comment...",
                                hintStyle: TextStyle(color: Colors.white54),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                          onPressed: () {
                            if (_commentController.text.isNotEmpty) {
                              _addComment(_commentController.text);
                              _commentController.clear();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 📌 Widget ย่อย
  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
