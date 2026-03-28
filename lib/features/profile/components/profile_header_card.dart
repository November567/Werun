import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const SizedBox();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingCard();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return _errorCard();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2B2B2B),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundImage: NetworkImage(
                      data['photoUrl'] ?? 'https://i.pravatar.cc/150',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['fullName'] ?? 'No name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['location'] ?? 'Unknown location',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data['email'] ?? user.email ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Friend ${data['friendsCount'] ?? 0}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatItem(
                    title: 'Total distance',
                    value: '${data['totalDistance'] ?? 0} KM',
                    isHighlight: true,
                  ),
                  _StatItem(
                    title: 'Total runs',
                    value: '${data['totalRuns'] ?? 0}',
                  ),
                  _StatItem(
                    title: 'Average pace',
                    value: '${data['avgPace'] ?? '-'} Km/hr',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _loadingCard() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.green),
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Text(
        'User data not found',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isHighlight;

  const _StatItem({
    required this.title,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? const Color(0xFF00FF5F) : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isHighlight ? 22 : 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
