import 'package:flutter/material.dart';
import 'pages/welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'യാത്ര രേഖ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'NotoSansMalayalam',
      ),
      home: WelcomeWidget(),
      debugShowCheckedModeBanner: false,
    );
  }
}