import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/caption_firestore_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Caption History"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: CaptionFirestoreService.instance.getCaptionHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No captions generated yet.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        data["caption"] ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Row(
                        children: [

                          Chip(
                            label: Text(data["style"] ?? ""),
                          ),

                          const SizedBox(width: 8),

                          Chip(
                            label: Text(data["language"] ?? ""),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        DateFormat("dd MMM yyyy • hh:mm a").format(
                          (data["createdAt"] as Timestamp).toDate(),
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}