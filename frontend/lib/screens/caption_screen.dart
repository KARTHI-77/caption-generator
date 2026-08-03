import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/image_picker_helper.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/caption_model.dart';
import '../services/caption_firestore_service.dart';
import 'profile_screen.dart';
import 'dart:async';

class CaptionScreen extends StatefulWidget {
  const CaptionScreen({super.key});

  @override
  State<CaptionScreen> createState() => _CaptionScreenState();
}

class _CaptionScreenState extends State<CaptionScreen> {
  XFile? _image;
  String _caption = "";
  List<String> _hashtags = [];
  List<String> _emojis = [];
  final List<String> _captionStyles = [
    "Short & Crispy",
    "Instagram",
    "Funny",
    "Professional",
    "Travel",
    "Motivational",
    "Poetic",
  ];
  String _selectedStyle = "Short & Crispy";

  bool _isLoading = false;

  final List<String> _loadingMessages = [
    "🖼️ Analyzing image...",
    "🧠 Understanding content...",
    "✍️ Writing caption...",
    "🏷️ Generating hashtags...",
    "😊 Selecting emojis...",
  ];
  int _loadingIndex = 0;

  Timer? _loadingTimer;

  final List<String> _languages = [
    "English",
    "Tamil",
    "Hindi",
    "French",
    "Spanish",
    "German",
    "Japanese",
  ];

  final List<String> _platforms = [
  "General",
  "Instagram",
  "LinkedIn",
  "Facebook",
  "X (Twitter)",
  "WhatsApp",
];

  String _selectedLanguage = "English";
  String _selectedPlatform = "General";

  Future<void> _pickImage() async {
    final selectedImage = await ImagePickerHelper.pickImage();

    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
        _caption = "";
        _hashtags = [];
        _emojis = [];
      });
    }
  }

  void _startLoadingAnimation() {
    _loadingIndex = 0;

    _loadingTimer?.cancel();

    _loadingTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) return;

      setState(() {
        _loadingIndex = (_loadingIndex + 1) % _loadingMessages.length;
      });
    });
  }

  void _stopLoadingAnimation() {
    _loadingTimer?.cancel();
  }

  Future<void> _generateCaption() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingIndex = 0;
    });

    _startLoadingAnimation();

    try {
      final response = await ApiService.generateCaption(
        _image!,
        _selectedStyle,
        _selectedLanguage,
        _selectedPlatform,
      );

      setState(() {
        _caption = response.caption;
        _hashtags = response.hashtags;
        _emojis = response.emojis;
      });
      await CaptionFirestoreService.instance.saveCaption(
        CaptionModel(
          id: "",
          caption: _caption,
          hashtags: _hashtags,
          emojis: _emojis,
          style: _selectedStyle,
          language: _selectedLanguage,
          imageUrl: "",
          favorite: false,
          createdAt: Timestamp.now(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      _stopLoadingAnimation();

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _copyCaption() async {
    if (_caption.isEmpty) return;

    final textToCopy = [
      _caption,
      if (_hashtags.isNotEmpty) "",
      if (_hashtags.isNotEmpty) _hashtags.join(" "),
      if (_emojis.isNotEmpty) "",
      if (_emojis.isNotEmpty) _emojis.join(" "),
    ].join("\n");

    await Clipboard.setData(ClipboardData(text: textToCopy));

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Caption copied")));
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Caption copied to clipboard!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareCaption() async {
    if (_caption.isEmpty || _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No image or caption to share.")),
      );
      return;
    }

    await _image!.readAsBytes();

    final textToShare = [
      _caption,
      if (_hashtags.isNotEmpty) "",
      if (_hashtags.isNotEmpty) _hashtags.join(" "),
      if (_emojis.isNotEmpty) "",
      if (_emojis.isNotEmpty) _emojis.join(" "),
    ].join("\n");

    await Share.share(textToShare, subject: "AI Generated Caption");
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Caption Generator"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),

            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedStyle,
                    decoration: InputDecoration(
                      labelText: "Caption Style",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _captionStyles.map((style) {
                      return DropdownMenuItem(value: style, child: Text(style));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStyle = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedLanguage,
                    decoration: InputDecoration(
                      labelText: "Language",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _languages.map((language) {
                      return DropdownMenuItem(
                        value: language,
                        child: Text(language),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLanguage = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
  initialValue: _selectedPlatform,
  decoration: InputDecoration(
    labelText: "Platform",
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  items: _platforms.map((platform) {
    return DropdownMenuItem(
      value: platform,
      child: Text(platform),
    );
  }).toList(),
  onChanged: (value) {
    setState(() {
      _selectedPlatform = value!;
    });
  },
),

const SizedBox(height: 20),

                  SizedBox(
                    height: 250,
                    child: Center(
                      child: _image == null
                          ? const Icon(
                              Icons.image,
                              size: 150,
                              color: Colors.grey,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: FutureBuilder(
                                future: _image!.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const CircularProgressIndicator();
                                  }

                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.contain,
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text("Pick Image"),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_caption.isEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _generateCaption,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text("Generate Caption"),
                      ),
                    ),

                  const SizedBox(height: 25),

                  if (!_isLoading && _caption.isNotEmpty)
                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          _caption,
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  if (_hashtags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Hashtags",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _hashtags.map((tag) {
                                  return Chip(label: Text(tag));
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (_emojis.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Card(
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Emojis",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Center(
                                child: Text(
                                  _emojis.join(" "),
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (!_isLoading && _caption.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _copyCaption,
                              icon: const Icon(Icons.copy),
                              label: const Text(""),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _shareCaption,
                              icon: const Icon(Icons.share),
                              label: const Text(""),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _isLoading ? null : _generateCaption,
                              icon: const Icon(Icons.refresh),
                              label: const Text(""),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),

                    SizedBox(height: 20),

                    Text(
                      "Generating AI Caption...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 8),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _loadingMessages[_loadingIndex],
                        key: ValueKey<int>(_loadingIndex),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
