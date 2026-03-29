import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:werun_projct/features/models/post.dart';

void main() {
  group('Post.fromJson', () {
    test('parses all fields correctly', () {
      final json = {
        'id': 'abc123',
        'userId': 'user1',
        'userName': 'Alice',
        'userAvatar': 'https://example.com/avatar.png',
        'title': 'Morning Run',
        'description': 'Great run!',
        'tags': ['run', 'morning'],
        'privacy': 'public',
        'imageUrl': 'https://example.com/img.png',
        'location': 'Bangkok',
        'distance': '5.0 km',
        'duration': '00:30:00',
        'pace': "6'00\"",
        'createdAt': '2024-01-01T00:00:00.000',
        'likes': 10,
        'saves': 2,
        'comments': ['user2: nice!'],
      };

      final post = Post.fromJson(json);

      expect(post.id, 'abc123');
      expect(post.userId, 'user1');
      expect(post.userName, 'Alice');
      expect(post.title, 'Morning Run');
      expect(post.tags, ['run', 'morning']);
      expect(post.likes, 10);
      expect(post.comments.length, 1);
    });

    // BUG DETECTOR: fromJson without 'id' key returns empty id.
    // This caused the "document path must be non-empty" crash in ViewDetailScreen
    // when post was fetched via doc.data() instead of Post.fromFirestore(doc).
    test('returns empty id when id key is missing', () {
      final json = {
        'userId': 'user1',
        'userName': 'Alice',
        'description': 'test',
        'tags': <String>[],
        'privacy': 'public',
        'imageUrl': '',
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final post = Post.fromJson(json);
      expect(post.id, '',
          reason:
              'fromJson cannot read Firestore doc ID — use fromFirestore() instead');
    });

    test('handles Firestore Timestamp for createdAt', () {
      final ts = Timestamp.fromDate(DateTime(2024, 6, 15));
      final json = {
        'userId': '',
        'userName': '',
        'description': '',
        'tags': <String>[],
        'privacy': 'public',
        'imageUrl': '',
        'createdAt': ts,
      };

      final post = Post.fromJson(json);
      expect(post.createdAt.year, 2024);
      expect(post.createdAt.month, 6);
      expect(post.createdAt.day, 15);
    });

    test('handles null createdAt without crashing', () {
      final json = {
        'userId': '',
        'userName': '',
        'description': '',
        'tags': <String>[],
        'privacy': 'public',
        'imageUrl': '',
        'createdAt': null,
      };

      expect(() => Post.fromJson(json), returnsNormally);
    });

    test('defaults likes and saves to 0 when missing', () {
      final json = {
        'userId': '',
        'userName': '',
        'description': '',
        'tags': <String>[],
        'privacy': 'public',
        'imageUrl': '',
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final post = Post.fromJson(json);
      expect(post.likes, 0);
      expect(post.saves, 0);
    });

    test('defaults comments to empty list when missing', () {
      final json = {
        'userId': '',
        'userName': '',
        'description': '',
        'tags': <String>[],
        'privacy': 'public',
        'imageUrl': '',
        'createdAt': '2024-01-01T00:00:00.000',
      };

      final post = Post.fromJson(json);
      expect(post.comments, isEmpty);
    });
  });

  group('Post.toJson', () {
    test('does not include id field (Firestore generates it)', () {
      final post = Post(
        id: 'should-not-appear',
        userId: 'u1',
        userName: 'Bob',
        description: 'test',
        tags: [],
        privacy: 'public',
        imageUrl: '',
        createdAt: DateTime(2024),
      );

      final json = post.toJson();
      expect(json.containsKey('id'), isFalse,
          reason: 'id must not be stored as a Firestore field');
    });

    test('round-trip preserves all fields except id', () {
      final original = Post(
        id: 'ignored',
        userId: 'u1',
        userName: 'Carol',
        userAvatar: 'https://avatar.png',
        title: 'Evening Jog',
        description: 'Felt good',
        tags: ['night'],
        privacy: 'private',
        imageUrl: 'https://img.png',
        location: 'Chiang Mai',
        distance: '3.1 km',
        duration: '00:20:00',
        pace: "6'27\"",
        createdAt: DateTime(2024, 3, 10),
        likes: 5,
        saves: 1,
        comments: ['x: well done'],
      );

      final roundTripped = Post.fromJson(original.toJson());

      expect(roundTripped.userName, original.userName);
      expect(roundTripped.title, original.title);
      expect(roundTripped.distance, original.distance);
      expect(roundTripped.pace, original.pace);
      expect(roundTripped.likes, original.likes);
      expect(roundTripped.tags, original.tags);
    });
  });
}
