import 'package:flutter/material.dart';

// import หน้า register
import 'features/auth/screens/register_screen.dart';

void main() {
  runApp(const WeRunApp());
}

class WeRunApp extends StatelessWidget {
  const WeRunApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WeRun',
      theme: ThemeData.dark(),
      home: const RegisterScreen(),
    );
  }
}
