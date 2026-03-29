import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/run_stat_chip.dart';
import '../../../shared/widgets/bottom_sheet_container.dart';

class PostRunSheet extends StatefulWidget {
  final String distance;
  final String duration;
  final String pace;
  final Future<Uint8List?> snapshotFuture;
  final Future<String> imageUrlFuture;

  const PostRunSheet({
    super.key,
    required this.distance,
    required this.duration,
    required this.pace,
    required this.snapshotFuture,
    required this.imageUrlFuture,
  });

  @override
  State<PostRunSheet> createState() => _PostRunSheetState();
}

class _PostRunSheetState extends State<PostRunSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() ?? {};

      // Await the background upload — likely already done by now
      final imageUrl = await widget.imageUrlFuture;

      await FirebaseFirestore.instance.collection('posts').add({
        'userId': user.uid,
        'userName': userData['fullName'] ?? user.displayName ?? 'Runner',
        'userAvatar': userData['photoUrl'] ?? '',
        'title': title,
        'description': _descController.text.trim(),
        'tags': ['run'],
        'privacy': 'public',
        'imageUrl': imageUrl,
        'distance': widget.distance,
        'duration': widget.duration,
        'pace': widget.pace,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'saves': 0,
        'comments': [],
      });

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Share Your Run',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Run stats summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RunStatChip(label: 'Distance', value: widget.distance),
                RunStatChip(label: 'Time', value: widget.duration),
                RunStatChip(label: 'Pace', value: widget.pace),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Map snapshot — loads in background while user types
          FutureBuilder<Uint8List?>(
            future: widget.snapshotFuture,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done ||
                  snap.data == null) {
                return Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary, strokeWidth: 2),
                  ),
                );
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  snap.data!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Title
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Run title (e.g. Morning Sprint)',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Description
          TextField(
            controller: _descController,
            style: const TextStyle(color: Colors.white),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'How did it go? (optional)',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Post button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isPosting ? null : _post,
              child: _isPosting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'POST RUN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
