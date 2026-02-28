import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ViewDetailScreen extends StatefulWidget {
  final String imageUrl;
  final String title;

  const ViewDetailScreen({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  State<ViewDetailScreen> createState() => _ViewDetailScreenState();
}

class _ViewDetailScreenState extends State<ViewDetailScreen>
    with SingleTickerProviderStateMixin {
  /// 🗂 เก็บข้อมูลแยกตามรูป
  static Map<String, int> likeStorage = {};
  static Map<String, List<String>> commentStorage = {};

  final TextEditingController _commentController = TextEditingController();

  bool isLiked = false;

  late AnimationController _likeController;
  late Animation<double> _likeAnimation;

  String currentUser = "Carly Mensch";

  int get likeCount => likeStorage[widget.imageUrl] ?? 20;
  List<String> get comments => commentStorage[widget.imageUrl] ?? [];

  @override
  void initState() {
    super.initState();

    likeStorage.putIfAbsent(widget.imageUrl, () => 20);
    commentStorage.putIfAbsent(widget.imageUrl, () => []);

    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _likeAnimation = Tween<double>(begin: 1.0, end: 1.4).animate(
      CurvedAnimation(parent: _likeController, curve: Curves.elasticOut),
    );
  }

  void _toggleLike() {
    setState(() {
      if (isLiked) {
        likeStorage[widget.imageUrl] = likeStorage[widget.imageUrl]! - 1;
      } else {
        likeStorage[widget.imageUrl] = likeStorage[widget.imageUrl]! + 1;
        _likeController.forward().then((_) {
          _likeController.reverse();
        });
      }
      isLiked = !isLiked;
    });
  }

  void _addComment(String text) {
    setState(() {
      commentStorage[widget.imageUrl]!.add("$currentUser: $text");
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
                    const CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        "https://picsum.photos/100",
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Mr.Gunny",
                      style: TextStyle(
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
              const Padding(
                padding: EdgeInsets.only(left: 70, bottom: 10),
                child: Text(
                  "Location: อุทยานสวนเกษตร มข.",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),

              /// 🖼 CENTER IMAGE
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      widget.imageUrl,
                      width: MediaQuery.of(context).size.width * 0.9,
                      fit: BoxFit.cover,
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
                    /// 📍 RUN STATS ROW (มีไอคอน)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.green,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "5.32 Km",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.orange,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text("1 Hr", style: TextStyle(color: Colors.white)),
                          ],
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons.directions_run,
                              color: Colors.blue,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "12:00min/km",
                              style: TextStyle(color: Colors.white),
                            ),
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
                                  color: isLiked ? Colors.green : Colors.white,
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

                        /// 🔗 SHARE (แชร์จริง)
                        GestureDetector(
                          onTap: () {
                            Share.share(
                              "Check out this run!\n\n"
                              "Distance: 5.32 Km\n"
                              "Time: 1 Hr\n"
                              "Pace: 12:00min/km\n\n"
                              "Shared from WeRun App 🚀",
                            );
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.share, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                "Share",
                                style: TextStyle(color: Colors.white),
                              ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
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
