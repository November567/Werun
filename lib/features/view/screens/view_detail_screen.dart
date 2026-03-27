import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/post.dart';

class ViewDetailScreen extends StatefulWidget {
  final Post post;

  const ViewDetailScreen({super.key, required this.post});

  @override
  State<ViewDetailScreen> createState() => _ViewDetailScreenState();
}

class _ViewDetailScreenState extends State<ViewDetailScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _commentController = TextEditingController();
  bool isLiked = false;
  late int likeCount;
  late List<String> comments;

  late AnimationController _likeController;
  late Animation<double> _likeAnimation;

  String currentUser = "Carly Mensch";

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likes;
    comments = List<String>.from(widget.post.comments);

    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );
  }

  Future<void> _toggleLike() async {
    setState(() {
      if (isLiked) {
        likeCount--;
      } else {
        likeCount++;
        _likeController.forward().then((_) => _likeController.reverse());
      }
      isLiked = !isLiked;
    });

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .update({'likes': likeCount});
  }

  Future<void> _addComment(String text) async {
    final newComment = "$currentUser: $text";
    setState(() {
      comments.add(newComment);
    });

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.post.id)
        .update({
      'comments': FieldValue.arrayUnion([newComment]),
    });
  }

  @override
  void dispose() {
    _likeController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔙 PROFILE BAR
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: post.userAvatar.isNotEmpty
                          ? NetworkImage(post.userAvatar)
                          : const NetworkImage("https://picsum.photos/100"),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      post.userName, // ✅ userName
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Friend",
                      style: TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),

              /// 📍 LOCATION
              if (post.location.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 70, bottom: 10),
                  child: Text(
                    "Location: ${post.location}",
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),

              /// 🖼 CENTER IMAGE
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      post.imageUrl,
                      width: MediaQuery.of(context).size.width * 0.9,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 200,
                        color: Colors.grey.shade800,
                        child: const Icon(Icons.broken_image,
                            color: Colors.white54, size: 48),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              /// 📊 STATS CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    /// 📍 RUN STATS ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.green, size: 18),
                            const SizedBox(width: 4),
                            Text(post.distance,
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text(post.duration,
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.directions_run,
                                color: Colors.blue, size: 18),
                            const SizedBox(width: 4),
                            Text(post.pace,
                                style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 10),

                    /// 🔥 ACTION ROW
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        /// 👍 LIKE
                        Row(
                          children: [
                            ScaleTransition(
                              scale: _likeAnimation,
                              child: IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  color:
                                      isLiked ? Colors.green : Colors.white,
                                ),
                                onPressed: _toggleLike,
                              ),
                            ),
                            Text(
                              "($likeCount)",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),

                        /// 💬 COMMENT COUNT
                        Row(
                          children: [
                            const Icon(Icons.comment, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              "(${comments.length})",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),

                        /// 🔗 SHARE
                        GestureDetector(
                          onTap: () {
                            Share.share(
                              "Check out this run!\n\n"
                              "Distance: ${post.distance}\n"
                              "Time: ${post.duration}\n"
                              "Pace: ${post.pace}\n\n"
                              "Shared from WeRun App 🚀",
                            );
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.share, color: Colors.white),
                              SizedBox(width: 4),
                              Text("Share",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),

                        const Text(
                          "Route detail",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              /// 💬 COMMENT LIST
              ...comments.map(
                (c) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(c, style: const TextStyle(color: Colors.white)),
                ),
              ),

              const SizedBox(height: 20),

              /// 📝 COMMENT INPUT
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: "Comments",
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.green),
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
      ),
    );
  }
}