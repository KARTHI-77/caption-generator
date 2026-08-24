import 'package:caption_generator/firebase_options.dart';
import 'package:caption_generator/screens/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const CaptionGeneratorApp(),
    ),
  );
}

class CaptionGeneratorApp extends StatelessWidget {
  const CaptionGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Caption Generator',

      theme: themeProvider.lightTheme,

      darkTheme: themeProvider.darkTheme,

      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: const AuthWrapper(),
    );
  }
}