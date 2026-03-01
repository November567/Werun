import 'package:flutter/material.dart';
import '../components/profile_header_card.dart';
import '../components/profile_menu_item.dart';
import '../components/weekly_chart.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 10),

            /// Top Bar
            _TopBar(),

            SizedBox(height: 20),

            /// Profile Header Card
            ProfileHeaderCard(),

            SizedBox(height: 25),

            /// Menu + Chart Card
            _MenuSection(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// TOP BAR
////////////////////////////////////////////////////////////

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.menu, color: Colors.white),
        SizedBox(width: 15),
        Expanded(
          child: Text(
            "Search Locations",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        Icon(Icons.search, color: Colors.white),
      ],
    );
  }
}

////////////////////////////////////////////////////////////
/// MENU SECTION
////////////////////////////////////////////////////////////

class _MenuSection extends StatelessWidget {
  const _MenuSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          ProfileMenuItem(title: "Activity"),
          ProfileMenuItem(title: "Statistics"),
          ProfileMenuItem(title: "Routes"),

          SizedBox(height: 20),

          Text(
            "This week",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),

          SizedBox(height: 15),

          WeeklyChart(),

          SizedBox(height: 10),

          Center(
            child: Text("Dec", style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
