import 'dart:io';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/image_picker_helper.dart';

class CaptionScreen extends StatefulWidget {
  const CaptionScreen({super.key});

  @override
  State<CaptionScreen> createState() => _CaptionScreenState();
}

class _CaptionScreenState extends State<CaptionScreen> {
  File? _image;
  String _caption = "";
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final selectedImage = await ImagePickerHelper.pickImage();

    if (selectedImage != null) {
      setState(() {
        _image = selectedImage;
        _caption = "";
      });
    }
  }

  Future<void> _generateCaption() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an image first."),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final caption =
          await ApiService.generateCaption(_image!);

      setState(() {
        _caption = caption;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Caption Generator"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Expanded(
              child: Center(
                child: _image == null
                    ? const Icon(
                        Icons.image,
                        size: 150,
                        color: Colors.grey,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _image!,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text("Pick Image"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : _generateCaption,
                icon: const Icon(Icons.auto_awesome),
                label: const Text("Generate Caption"),
              ),
            ),

            const SizedBox(height: 25),

            if (_isLoading)
              const CircularProgressIndicator(),

            if (!_isLoading && _caption.isNotEmpty)
              Card(
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _caption,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}