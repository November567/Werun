import 'package:flutter/material.dart';
import 'components/bottom_navbar.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/map/screens/map_screen.dart';
import 'features/view/screens/view_screen.dart';

void main() {
  runApp(const WeRunApp());
}

class WeRunApp extends StatelessWidget {
  const WeRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Center(
      child: Text("Home", style: TextStyle(color: Colors.white)),
    ),
    MapScreen(),
    Center(
      child: Text("Start Run", style: TextStyle(color: Colors.white)),
    ),
    ViewScreen(), // ✅ เชื่อมตรงนี้
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_currentIndex],
      bottomNavigationBar: WeRunBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
