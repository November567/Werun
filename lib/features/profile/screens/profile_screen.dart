import 'package:flutter/material.dart';
import '../components/profile_header_card.dart';
import '../components/weekly_chart.dart';
import '../../auth/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),

      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        elevation: 0,
        title: const Text(
          "WeRun",
          style: TextStyle(color: Colors.lime, fontWeight: FontWeight.bold),
        ),
        leading: const Icon(Icons.arrow_back, color: Colors.lime),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const ProfileHeader(),
              const SizedBox(height: 20),
              const StatsSection(),
              const SizedBox(height: 20),
              const WeeklyChart(),
              const SizedBox(height: 20),
              const RecentRuns(),
            ],
          ),
        ),
      ),
    );
  }
}

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1A1A1A),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Total Distance", style: TextStyle(color: Colors.grey)),
              Row(
                children: [
                  Text(
                    "1,284",
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.lime,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text("KM", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _statBox("Avg Pace", "4'12\" /km")),
            const SizedBox(width: 10),
            Expanded(child: _statBox("Runs", "156")),
          ],
        ),
      ],
    );
  }

  Widget _statBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
