import 'package:flutter/material.dart';

class ProfileMenuItem extends StatelessWidget {
  final String title;

  const ProfileMenuItem({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(
            width: 30,
            child: Divider(color: Colors.white70, thickness: 2),
          ),
        ],
      ),
    );
  }
}
