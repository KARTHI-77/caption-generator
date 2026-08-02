import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/caption_firestore_service.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Caption History")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: CaptionFirestoreService.instance.getCaptionHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
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

                      if ((data["hashtags"] as List?)?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (data["hashtags"] as List)
                              .map((tag) => Chip(label: Text(tag.toString())))
                              .toList(),
                        ),
                      ],

                      const SizedBox(height: 15),

                      if ((data["emojis"] as List?)?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 16),

                        const Text(
                          "Emojis",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Center(
                          child: Text(
                            (data["emojis"] as List)
                                .map((e) => e.toString())
                                .join(" "),
                            style: const TextStyle(fontSize: 30),
                          ),
                        ),
                      ],

                      Row(
                        children: [
                          Chip(label: Text(data["style"] ?? "")),

                          const SizedBox(width: 8),

                          Chip(label: Text(data["language"] ?? "")),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Text(
                        DateFormat(
                          "dd MMM yyyy • hh:mm a",
                        ).format((data["createdAt"] as Timestamp).toDate()),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            tooltip: "Copy",
                            icon: const Icon(Icons.copy),
                            onPressed: () async {
                              final hashtags =
                                  (data["hashtags"] as List?)
                                      ?.map((e) => e.toString())
                                      .join(" ") ??
                                  "";

                              final emojis =
                                  (data["emojis"] as List?)
                                      ?.map((e) => e.toString())
                                      .join(" ") ??
                                  "";

                              await Clipboard.setData(
                                ClipboardData(
                                  text: [
                                    data["caption"] ?? "",
                                    "",
                                    hashtags,
                                    "",
                                    emojis,
                                  ].join("\n"),
                                ),
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Caption copied"),
                                  ),
                                );
                              }
                            },
                          ),
                          IconButton(
                            tooltip: "Share",
                            icon: const Icon(Icons.share),
                            onPressed: () async {
                              final hashtags =
                                  (data["hashtags"] as List?)
                                      ?.map((e) => e.toString())
                                      .join(" ") ??
                                  "";

                              final emojis =
                                  (data["emojis"] as List?)
                                      ?.map((e) => e.toString())
                                      .join(" ") ??
                                  "";

                              await Share.share(
                                [
                                  data["caption"] ?? "",
                                  "",
                                  hashtags,
                                  "",
                                  emojis,
                                ].join("\n"),
                                subject: "AI Generated Caption",
                              );
                            },
                          ),
                          IconButton(
                            tooltip: "Favorite",
                            icon: Icon(
                              data["favorite"] == true
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              await CaptionFirestoreService.instance
                                  .toggleFavorite(
                                    docs[index].id,
                                    data["favorite"] ?? false,
                                  );
                            },
                          ),

                          IconButton(
                            tooltip: "Delete",
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text("Delete Caption"),
                                  content: const Text(
                                    "Are you sure you want to delete this caption?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context, false);
                                      },
                                      child: const Text("Cancel"),
                                    ),

                                    FilledButton(
                                      onPressed: () {
                                        Navigator.pop(context, true);
                                      },
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await CaptionFirestoreService.instance
                                    .deleteCaption(docs[index].id);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Caption deleted"),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ],
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
