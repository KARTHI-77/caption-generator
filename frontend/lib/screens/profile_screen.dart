import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/caption_firestore_service.dart';
import '../widgets/stat_card.dart';
import '../screens/history_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: CaptionFirestoreService.instance.getProfileStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final stats = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  child: user.photoURL == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),

                const SizedBox(height: 20),

                Text(
                  user.displayName ?? "Unknown User",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  user.email ?? "",
                  style: TextStyle(color: Colors.grey.shade600),
                ),

                const SizedBox(height: 35),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 1.0,
                  children: [
                    Card(
                      child: SwitchListTile(
                        secondary: const Icon(Icons.dark_mode),
                        title: const Text("Dark Mode"),
                        value: context.watch<ThemeProvider>().isDarkMode,
                        onChanged: (value) {
                          context.read<ThemeProvider>().toggleTheme(value);
                        },
                      ),
                    ),
                    StatCard(
                      title: "Captions",
                      value: stats["totalCaptions"].toString(),
                      icon: Icons.auto_awesome,
                    ),

                    StatCard(
                      title: "Favorites",
                      value: stats["favoriteCount"].toString(),
                      icon: Icons.favorite,
                    ),

                    StatCard(
                      title: "Languages",
                      value: stats["languageCount"].toString(),
                      icon: Icons.language,
                    ),

                    StatCard(
                      title: "Top Style",
                      value: stats["mostUsedStyle"],
                      icon: Icons.star,
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text("Caption History"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HistoryScreen(),
                      ),
                    );
                  },
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    await AuthService.instance.signOut();

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
