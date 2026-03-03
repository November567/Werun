import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String description;
  final List<String> tags;
  final String privacy;
  final String imageUrl;
  final DateTime createdAt;
  final int likes;
  final int saves;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.description,
    required this.tags,
    required this.privacy,
    required this.imageUrl,
    required this.createdAt,
    this.likes = 0,
    this.saves = 0,
  });

  // Convert Post to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'description': description,
      'tags': tags,
      'privacy': privacy,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'likes': likes,
      'saves': saves,
    };
  }

  // Alias for toJson (used in post_service.dart)
  Map<String, dynamic> toMap() => toJson();

  // Create Post from Firestore document
  factory Post.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    final raw = json['createdAt'];
    if (raw is Timestamp) {
      createdAt = raw.toDate();
    } else if (raw is String) {
      createdAt = DateTime.tryParse(raw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return Post(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      privacy: json['privacy'] ?? 'public',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: createdAt,
      likes: json['likes'] ?? 0,
      saves: json['saves'] ?? 0,
    );
  }

  // Alias for fromJson (used in post_service.dart)
  factory Post.fromMap(Map<String, dynamic> map) => Post.fromJson(map);
}