import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.lime.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.lime.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  "https://lh3.googleusercontent.com/aida-public/AB6AXuDgbt1XVTVBDp2Ibn_IvE593O--NTijzDOclOSBw7-VR433ZdIUwh1AoiEDgp_LYkbnoCezi8reF9ROckH-gHwUHOOeY8HnQ7pk-2jBU0CsoZhyIkKD0Z6oBX_vi0qBSraux_8_Oa8nYRKvYPod3zXhx-XODMTOBcGruzb5fyHLO69ZHgQo-4w5IO6s1xomqhWpPh4rSA_yLsh5ADoahqMpgvVtArSmPjU-frK1Z6uOVbhRCS4CGJHtWkDeFi9N_4A-hJSm_Es-Q6d8",
                ),
              ),
            ),

            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.lime,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "PRO",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        const Text(
          "Marcus Chen",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          "RUNNER",
          style: TextStyle(color: Colors.lime, letterSpacing: 2),
        ),
      ],
    );
  }
}
