import 'package:flutter/material.dart';
import 'pages/welcome.dart';
import 'theme/modern_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'യാത്ര രേഖ',
      theme: ModernTheme.themeData,
      home: const WelcomeWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}