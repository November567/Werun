import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// screens
import 'components/bottom_navbar.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/map/screens/map_screen.dart';
import 'features/view/screens/view_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();

  final SharedPreferencesWithCache prefs =
      await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      );

  runApp(WeRunApp(prefs: prefs));
}

class WeRunApp extends StatelessWidget {
  const WeRunApp({super.key, required this.prefs});
  final SharedPreferencesWithCache prefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: AuthGate(prefs: prefs),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.prefs});
  final SharedPreferencesWithCache prefs;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ยังไม่ login
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // login แล้ว
        return MainScreen(prefs: prefs);
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.prefs});
  final SharedPreferencesWithCache prefs;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 1; // ← ใช้ 1 แทน 0

  final List<Widget> _pages = const [
    Center(child: Text("Home")),
    MapScreen(),
    Center(child: Text("Start Run")),
    ViewScreen(),
    ProfileScreen(),
  ];

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_currentIndex],
      bottomNavigationBar: WeRunBottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
