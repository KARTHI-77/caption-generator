import 'package:flutter/material.dart';
import 'screens/caption_screen.dart';

void main() {
  runApp(const CaptionApp());
}

class CaptionApp extends StatelessWidget {
  const CaptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caption Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CaptionScreen(),
    );
  }
}