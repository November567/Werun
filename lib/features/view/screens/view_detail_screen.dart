import 'package:flutter/material.dart';

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
  bool isLiked = false;
  bool showBigHeart = false;

  final TextEditingController _commentController = TextEditingController();
  final List<String> comments = [];

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  void _likeAnimation() {
    setState(() {
      isLiked = true;
      showBigHeart = true;
    });

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _controller.reverse();
          setState(() {
            showBigHeart = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            
          // 🔹 PROFILE BAR WITH BACK BUTTON
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // 🔙 BACK BUTTON
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage("https://picsum.photos/100"),
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    "Carly Mensch",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 IMAGE + BIG HEART ANIMATION
            Expanded(
              child: GestureDetector(
                onDoubleTap: _likeAnimation,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      widget.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                    // ❤️ BIG HEART
                    if (showBigHeart)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 120,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 🔹 ACTION BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  // ❤️ SMALL HEART ANIMATION
                  AnimatedScale(
                    scale: isLiked ? 1.3 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isLiked = !isLiked;
                        });
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.comment, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 🔹 COMMENTS
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    child: Text(
                      comments[index],
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),

            // 🔹 ADD COMMENT
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Add a comment...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green),
                    onPressed: () {
                      if (_commentController.text.isNotEmpty) {
                        setState(() {
                          comments.add(_commentController.text);
                          _commentController.clear();
                        });
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
  }
}
