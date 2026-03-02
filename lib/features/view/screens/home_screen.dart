import 'package:flutter/material.dart';
import '../components/run_history_card.dart';
import '../components/suggested_places_card.dart';
import '../components/friend_activity_card.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // New Post Button with Text
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreatePostScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'New post',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Run History & Suggested Places (Horizontal)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const RunHistoryCard(),
                    const SizedBox(width: 12),
                    const SuggestedPlacesCard(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Friend Activities (Vertical List)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const FriendActivityCard(
                    name: "Mr.Gunny",
                    location: "อุทยานสวนเกษตร มข.",
                    distance: "5.32 km",
                    duration: "1 hr",
                    pace: "12:00/min/km",
                    likes: 20,
                    saves: 20,
                  ),
                  const SizedBox(height: 20),
                  const FriendActivityCard(
                    name: "Mr.Gunny",
                    location: "อุทยานสวนเกษตร มข.",
                    distance: "5.32 km",
                    duration: "1 hr",
                    pace: "12:00/min/km",
                    likes: 20,
                    saves: 20,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}