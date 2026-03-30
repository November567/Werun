// lib/services/post_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/post.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'posts';

  Future<void> createPost(Post post) async {
    try {
      debugPrint('[PostService] Creating post: ${post.id}');
      final postData = post.toMap();
      postData['createdAt'] = FieldValue.serverTimestamp();
      await _firestore.collection(_collection).doc(post.id).set(postData);
      debugPrint('[PostService] Post created successfully: ${post.id}');
    } on FirebaseException catch (e) {
      debugPrint('[PostService] Firebase error: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[PostService] Unknown error: $e');
      rethrow;
    }
  }

  Stream<List<Post>> getPostsStream() {
    try {
      return _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        final posts = snapshot.docs
            .map((doc) {
              try {
                return Post.fromMap(doc.data());
              } catch (e) {
                debugPrint('[PostService] Error parsing post: $e');
                return null;
              }
            })
            .whereType<Post>()
            .toList();
        debugPrint('[PostService] Loaded ${posts.length} posts from Firestore');
        return posts;
      });
    } catch (e) {
      debugPrint('[PostService] Error getting posts stream: $e');
      rethrow;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'likes': FieldValue.increment(1),
      });
      debugPrint('[PostService] Liked post: $postId');
    } catch (e) {
      debugPrint('[PostService] Error liking post: $e');
      rethrow;
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'likes': FieldValue.increment(-1),
      });
      debugPrint('[PostService] Unliked post: $postId');
    } catch (e) {
      debugPrint('[PostService] Error unliking post: $e');
      rethrow;
    }
  }

  Future<void> savePost(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'saves': FieldValue.increment(1),
      });
      debugPrint('[PostService] Saved post: $postId');
    } catch (e) {
      debugPrint('[PostService] Error saving post: $e');
      rethrow;
    }
  }

  Future<void> unsavePost(String postId) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'saves': FieldValue.increment(-1),
      });
      debugPrint('[PostService] Unsaved post: $postId');
    } catch (e) {
      debugPrint('[PostService] Error unsaving post: $e');
      rethrow;
    }
  }

  Future<void> toggleLike(String postId, String uid, {required bool isLiked}) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'likes': FieldValue.increment(isLiked ? 1 : -1),
        'likedBy': isLiked
            ? FieldValue.arrayUnion([uid])
            : FieldValue.arrayRemove([uid]),
      });
    } catch (e) {
      debugPrint('[PostService] Error toggling like: $e');
      rethrow;
    }
  }

  Future<void> addComment(String postId, Map<String, dynamic> comment) async {
    try {
      await _firestore.collection(_collection).doc(postId).update({
        'comments': FieldValue.arrayUnion([comment]),
      });
    } catch (e) {
      debugPrint('[PostService] Error adding comment: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data() ?? {};
  }
}