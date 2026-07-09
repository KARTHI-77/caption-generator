import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../utils/image_picker_helper.dart';
import 'package:flutter/services.dart';

class CaptionScreen extends StatefulWidget {
  const CaptionScreen({super.key});

  @override
  State<CaptionScreen> createState() => _CaptionScreenState();
}

class _CaptionScreenState extends State<CaptionScreen> {
  XFile? _image;
  String _caption = "";
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
          await ApiService.generateCaption(_image!, _selectedStyle);

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
  Future<void> _copyCaption() async {
   if (_caption.isEmpty) return;

    await Clipboard.setData(
      ClipboardData(text: _caption),
    );

   if (!mounted) return;

   ScaffoldMessenger.of(context).showSnackBar(
     const SnackBar(
       content: Text("Caption copied to clipboard!"),
       duration: Duration(seconds: 2),
     ),
   );
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

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: _selectedStyle,
              decoration: InputDecoration(
               labelText: "Caption Style",
               border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
               ),
              ),
            items: _captionStyles.map((style) {
              return DropdownMenuItem(
               value: style,
               child: Text(style),
              );
              }).toList(),
              onChanged: (value) {
                setState(() {
                 _selectedStyle = value!;
              });
            },
        ),

       const SizedBox(height: 20),

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
            if (!_isLoading && _caption.isNotEmpty)
             Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
               width: double.infinity,
               child: OutlinedButton.icon(
                onPressed: _copyCaption,
                icon: const Icon(Icons.copy),
                label: const Text("Copy Caption"),
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