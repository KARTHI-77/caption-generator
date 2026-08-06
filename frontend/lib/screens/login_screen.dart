import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/google_sign_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _login() async {
    setState(() {
      _loading = true;
    });

    try {
      await AuthService.instance.signInWithGoogle();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 90,
                  color: Colors.deepPurple,
                ),

                const SizedBox(height: 30),

                const Text(
                  "AI Social Media",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),

                const Text(
                  "Content Assistant",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Generate amazing captions\nusing Artificial Intelligence",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 60),

                GoogleSignButton(onPressed: _login, isLoading: _loading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
