import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 56);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surface;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // WERUN + avatar + bell
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'WERUN',
                style: TextStyle(
                  color: primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              Row(
                children: [
                  if (uid != null)
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final avatarUrl = snapshot.hasData && snapshot.data!.exists
                            ? (snapshot.data!.data()
                                    as Map<String, dynamic>)['avatarUrl'] as String? ?? ''
                            : '';
                        return CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[800],
                          backgroundImage: NetworkImage(
                            avatarUrl.isNotEmpty
                                ? avatarUrl
                                : 'https://www.gravatar.com/avatar/00000000000000000000000000000000?d=mp&f=y',
                          ),
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),

          // Goal search bar
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.add, color: primary, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    "What's your next goal today?",
                    style: TextStyle(color: Colors.white38, fontSize: 14),
                  ),
                ),
                const Icon(Icons.qr_code_scanner,
                    color: Colors.white38, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
