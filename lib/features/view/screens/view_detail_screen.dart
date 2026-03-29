import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/post.dart';
import '../../services/post_service.dart';

class ViewDetailScreen extends StatefulWidget {
  final Post post;
  final bool autoFocusComment;

  const ViewDetailScreen({
    super.key,
    required this.post,
    this.autoFocusComment = false,
  });

  @override
  State<ViewDetailScreen> createState() => _ViewDetailScreenState();
}

class _ViewDetailScreenState extends State<ViewDetailScreen>
    with SingleTickerProviderStateMixin {
  final _postService = PostService();
  final _commentController = TextEditingController();
  final _commentFocusNode = FocusNode();
  final _scrollController = ScrollController();

  bool isLiked = false;
  String _myAvatar = '';
  bool _sending = false;

  late AnimationController _likeController;
  late Animation<double> _likeAnimation;

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
    _loadMyAvatar();
    if (widget.autoFocusComment) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _commentFocusNode.requestFocus();
      });
    }
  }

  Future<void> _loadMyAvatar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final data = await _postService.getUserData(uid);
    if (mounted) setState(() => _myAvatar = data['avatarUrl'] ?? '');
  }

  @override
  void dispose() {
    _likeController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleLike() async {
    setState(() => isLiked = !isLiked);
    await _postService.toggleLike(widget.post.id, isLiked: isLiked);
    _likeController.forward().then((_) => _likeController.reverse());
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    _commentController.clear();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    String userName = 'Me';
    String userAvatar = _myAvatar;
    if (uid != null) {
      final userData = await _postService.getUserData(uid);
      userName = userData['nickName'] ?? userData['fullName'] ?? 'Me';
      userAvatar = userData['avatarUrl'] ?? '';
    }
    await _postService.addComment(widget.post.id, {
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
    });

    if (mounted) {
      setState(() => _sending = false);
      // Scroll to bottom after posting
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _sharePost(Post post) {
    Share.share("""
🏃 WeRun — ${post.userName}
📍 ${post.location}
📏 ${post.distance}  ⏱ ${post.duration}  ⚡ ${post.pace}

${post.description}
""");
  }

  static const _anon =
      'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y';

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;

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
          final comments = Post.parseComments(data['comments']);
          final likes = data['likes'] ?? 0;

          return Column(
            children: [
              // ── Scrollable content ──────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back + author header
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                              CircleAvatar(
                                radius: 18,
                                backgroundImage: NetworkImage(
                                  post.userAvatar.isNotEmpty
                                      ? post.userAvatar
                                      : _anon,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  post.userName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Post image
                      Image.network(
                        post.imageUrl.isNotEmpty
                            ? post.imageUrl
                            : 'https://via.placeholder.com/400x250',
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 250,
                          color: Colors.grey[800],
                          child: const Icon(Icons.broken_image,
                              color: Colors.white38, size: 50),
                        ),
                      ),

                      // Run stats row
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _infoItem(Icons.location_on, post.distance),
                            _infoItem(Icons.access_time, post.duration),
                            _infoItem(Icons.directions_run, post.pace),
                          ],
                        ),
                      ),

                      const Divider(color: Colors.white12, height: 1),

                      // Action bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            ScaleTransition(
                              scale: _likeAnimation,
                              child: IconButton(
                                icon: Icon(
                                  isLiked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_outlined,
                                  color: isLiked ? primary : Colors.white70,
                                  size: 22,
                                ),
                                onPressed: _toggleLike,
                              ),
                            ),
                            Text('$likes',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const SizedBox(width: 16),
                            Icon(Icons.chat_bubble_outline,
                                color: Colors.white70, size: 22),
                            const SizedBox(width: 6),
                            Text('${comments.length}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _sharePost(post),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ]),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.share,
                                        size: 16, color: Colors.black),
                                    SizedBox(width: 6),
                                    Text('Share',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Description
                      if (post.description.isNotEmpty) ...[
                        const Divider(color: Colors.white12, height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          child: Text(
                            post.description,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],

                      // Comments header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Text(
                              'Comments',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontSize: 15),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${comments.length}',
                                style: TextStyle(
                                    color: primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Comment list
                      if (comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          child: Text(
                            'No comments yet. Be the first!',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: comments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) =>
                              _CommentItem(comment: comments[i]),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Sticky comment input ─────────────────────────────
              Container(
                color: surface,
                padding: EdgeInsets.fromLTRB(
                    12, 10, 12, MediaQuery.of(context).viewInsets.bottom + 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage:
                          NetworkImage(_myAvatar.isNotEmpty ? _myAvatar : _anon),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        focusNode: _commentFocusNode,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Write a comment…',
                          hintStyle: const TextStyle(
                              color: Colors.white38, fontSize: 14),
                          filled: true,
                          fillColor: Colors.grey[850],
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _submitComment(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _sending
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : IconButton(
                            icon: Icon(Icons.send_rounded, color: primary),
                            onPressed: _submitComment,
                          ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Map<String, dynamic> comment;
  const _CommentItem({required this.comment});

  static const _anon =
      'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y';

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final avatarUrl = (comment['userAvatar'] as String?)?.isNotEmpty == true
        ? comment['userAvatar'] as String
        : _anon;
    final userName = comment['userName'] as String? ?? '';
    final text = comment['text'] as String? ?? '';

    // Parse relative timestamp
    String timeLabel = '';
    final raw = comment['createdAt'];
    if (raw is String) {
      final dt = DateTime.tryParse(raw);
      if (dt != null) timeLabel = _relativeTime(dt);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (timeLabel.isNotEmpty)
                      Text(
                        timeLabel,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
