import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../../models/post.dart';
import '../../services/post_service.dart';
import '../../../core/theme/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  String _selectedPrivacy = 'public';
  final _descController = TextEditingController();
  List<String> _tags = ['KHON KAEN', 'NIGHT RUN'];
  bool _shareToSuggested = true;
  bool _isLoading = false;
  String? _imageUrl;
  bool _uploading = false;

  final PostService _postService = PostService();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('post_images/${DateTime.now().millisecondsSinceEpoch}_${file.name}');
      final snap = await ref.putFile(File(file.path));
      final url = await snap.ref.getDownloadURL();
      setState(() => _imageUrl = url);
    } catch (e) {
      _showSnack('Upload failed: $e', Colors.red);
    } finally {
      setState(() => _uploading = false);
    }
  }

  void _addTag() {
    showDialog<String>(
      context: context,
      builder: (ctx) {
        String newTag = '';
        return AlertDialog(
          backgroundColor: AppTheme.surfaceBg,
          title: const Text('Add Tag', style: TextStyle(color: Colors.white)),
          content: TextField(
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Tag name'),
            onChanged: (v) => newTag = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, newTag.trim()),
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).then((tag) {
      if (tag != null && tag.isNotEmpty) {
        setState(() => _tags.add(tag.toUpperCase()));
      }
    });
  }

  Future<void> _savePost() async {
    if (_imageUrl == null) {
      _showSnack('Please add a photo', Colors.red);
      return;
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnack('Please login again', Colors.red);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() ?? {};

      final post = Post(
        id: FirebaseFirestore.instance.collection('posts').doc().id,
        userId: user.uid,
        userName: userData['nickName'] ?? userData['fullName'] ?? 'Runner',
        userAvatar: userData['avatarUrl'] ?? '',
        description: _descController.text.trim(),
        tags: _tags,
        privacy: _selectedPrivacy,
        imageUrl: _imageUrl!,
        location: _tags.isNotEmpty ? _tags.first : '',
        distance: '5.32 กม.',
        duration: '1 ชม.',
        pace: '12:00 นาที/กม.',
        createdAt: DateTime.now(),
        likes: 0,
        comments: [],
      );

      await _postService.createPost(post);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      _showSnack('Failed: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CREATE NEW POST',
          style: TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePost,
            child: Text(
              'SHARE',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats Card ──────────────────────────────────────
                  _StatsCard(imageUrl: _imageUrl, uploading: _uploading),
                  const SizedBox(height: 20),

                  // ── Add Media ───────────────────────────────────────
                  _SectionLabel('ADD MEDIA'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _MediaButton(
                        icon: Icons.camera_alt,
                        label: 'CAMERA',
                        onTap: () => _pickImage(ImageSource.camera),
                      ),
                      const SizedBox(width: 12),
                      _MediaButton(
                        icon: Icons.image,
                        label: 'GALLERY',
                        onTap: () => _pickImage(ImageSource.gallery),
                      ),
                      const SizedBox(width: 12),
                      _MediaButton(
                        icon: Icons.videocam,
                        label: 'SHORTS',
                        onTap: () => _showSnack('Coming soon', Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Description ─────────────────────────────────────
                  TextField(
                    controller: _descController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'แบ่งความรู้สึกเกี่ยวกับรอบนี้...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                      filled: true,
                      fillColor: AppTheme.cardBg,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Tags ────────────────────────────────────────────
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._tags.map((tag) => _TagChip(
                            label: tag,
                            onRemove: () =>
                                setState(() => _tags.remove(tag)),
                          )),
                      GestureDetector(
                        onTap: _addTag,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.cardBg,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Icon(Icons.add, color: primary, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Set Privacy ─────────────────────────────────────
                  _SectionLabel('SET PRIVACY'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _PrivacyButton(
                        label: 'PUBLIC',
                        value: 'public',
                        selected: _selectedPrivacy == 'public',
                        onTap: () => setState(() => _selectedPrivacy = 'public'),
                      ),
                      const SizedBox(width: 8),
                      _PrivacyButton(
                        label: 'FOLLOWERS',
                        value: 'followers',
                        selected: _selectedPrivacy == 'followers',
                        onTap: () =>
                            setState(() => _selectedPrivacy = 'followers'),
                      ),
                      const SizedBox(width: 8),
                      _PrivacyButton(
                        label: 'PRIVATE',
                        value: 'private',
                        selected: _selectedPrivacy == 'private',
                        onTap: () =>
                            setState(() => _selectedPrivacy = 'private'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Share to Suggested Places ───────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ALSO SHARE TO SUGGESTED PLACES',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Your run will be visible in destination feeds',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _shareToSuggested,
                          onChanged: (v) =>
                              setState(() => _shareToSuggested = v),
                          activeColor: primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Share Post button (sticky bottom) ───────────────────────
          Container(
            color: AppTheme.scaffoldBg,
            padding: EdgeInsets.fromLTRB(
                16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _savePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'SHARE POST',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white60,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String? imageUrl;
  final bool uploading;
  const _StatsCard({this.imageUrl, required this.uploading});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, color: primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'อุทยานสวนเกษตร มข.',
                      style: TextStyle(
                          color: primary, fontSize: 12, letterSpacing: 0.3),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _BigStat(
                          value: '5.32', unit: 'KM', label: 'DISTANCE'),
                    ),
                    Expanded(
                      child: _BigStat(value: '1', unit: 'HR', label: 'TIME'),
                    ),
                    Expanded(
                      child: _BigStat(
                          value: '12:00', unit: '', label: 'MIN/KM'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map preview / image
          Stack(
            children: [
              if (imageUrl != null)
                Image.network(
                  imageUrl!,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _MapPlaceholder(),
                )
              else
                _MapPlaceholder(),
              if (uploading)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: Center(
                      child: CircularProgressIndicator(color: primary),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  const _BigStat(
      {required this.value, required this.unit, required this.label});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: primary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  unit,
                  style: TextStyle(
                      color: primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white54, fontSize: 10, letterSpacing: 1),
        ),
      ],
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      color: const Color(0xFF111111),
      child: Stack(
        children: [
          Center(
            child: CustomPaint(
              size: const Size(180, 100),
              painter: _RoutePainter(),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 12,
            child: Text(
              'TAP MEDIA TO ADD PHOTO',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withValues(alpha: 0.7)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.6);
    path.cubicTo(
      size.width * 0.2, size.height * 0.2,
      size.width * 0.4, size.height * 0.1,
      size.width * 0.5, size.height * 0.4,
    );
    path.cubicTo(
      size.width * 0.6, size.height * 0.7,
      size.width * 0.75, size.height * 0.8,
      size.width * 0.85, size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.95, size.height * 0.3,
      size.width * 0.9, size.height * 0.15,
      size.width * 0.75, size.height * 0.25,
    );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_RoutePainter old) => false;
}

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MediaButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white70, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    letterSpacing: 1,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _TagChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
                color: primary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, color: primary, size: 14),
          ),
        ],
      ),
    );
  }
}

class _PrivacyButton extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;
  const _PrivacyButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.transparent : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? primary : Colors.white12,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? primary : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
