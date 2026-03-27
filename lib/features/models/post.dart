import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String title;
  final String description;
  final List<String> tags;
  final String privacy;
  final String imageUrl;
  final String location;
  final String distance;
  final String duration;
  final String pace;
  final DateTime createdAt;
  final int likes;
  final int saves;
  final List<String> comments;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    this.title = '',
    required this.description,
    required this.tags,
    required this.privacy,
    required this.imageUrl,
    this.location = '',
    this.distance = '',
    this.duration = '',
    this.pace = '',
    required this.createdAt,
    this.likes = 0,
    this.saves = 0,
    this.comments = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'title': title,
      'description': description,
      'tags': tags,
      'privacy': privacy,
      'imageUrl': imageUrl,
      'location': location,
      'distance': distance,
      'duration': duration,
      'pace': pace,
      'createdAt': createdAt,
      'likes': likes,
      'saves': saves,
      'comments': comments,
    };
  }

  Map<String, dynamic> toMap() => toJson();

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
      userAvatar: json['userAvatar'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      privacy: json['privacy'] ?? 'public',
      imageUrl: json['imageUrl'] ?? '',
      location: json['location'] ?? '',
      distance: json['distance'] ?? '',
      duration: json['duration'] ?? '',
      pace: json['pace'] ?? '',
      createdAt: createdAt,
      likes: json['likes'] ?? 0,
      saves: json['saves'] ?? 0,
      comments: List<String>.from(json['comments'] ?? []),
    );
  }

  factory Post.fromMap(Map<String, dynamic> map) => Post.fromJson(map);
}