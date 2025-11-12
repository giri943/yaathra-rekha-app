import 'package:flutter/material.dart';
import 'pages/welcome.dart';
import 'theme/modern_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'യാത്ര രേഖ',
      theme: ModernTheme.themeData,
      home: WelcomeWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}