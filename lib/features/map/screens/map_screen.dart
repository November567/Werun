import 'package:flutter/material.dart';

import '../components/map_view.dart';
import '../components/map_search_bar.dart';
import '../components/run_place_card.dart';
import '../../../components/bottom_navbar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _currentIndex = 1; // Map = active

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        debugPrint('Go Home');
        break;
      case 1:
        debugPrint('Map');
        break;
      case 2:
        debugPrint('Start Run');
        break;
      case 3:
        debugPrint('Chat');
        break;
      case 4:
        debugPrint('Profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: const [
          MapView(), // 🗺 แผนที่
          MapSearchBar(), // 🔍 Search ด้านบน
          RunPlaceCard(), // 🏞 Card ด้านล่าง
        ],
      ),
      bottomNavigationBar: WeRunBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
