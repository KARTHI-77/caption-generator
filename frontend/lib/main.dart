import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const CaptionApp());
}

class CaptionApp extends StatelessWidget {
  const CaptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Caption Generator",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const CaptionScreen(),
    );
  }
}

class CaptionScreen extends StatefulWidget {
  const CaptionScreen({super.key});

  @override
  State<CaptionScreen> createState() => _CaptionScreenState();
}

class _CaptionScreenState extends State<CaptionScreen> {
  File? image;
  String caption = "";
  bool loading = false;

  final picker = ImagePicker();

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
        caption = "";
      });
    }
  }

  Future generateCaption() async {
    if (image == null) return;

    setState(() {
      loading = true;
    });

    var uri = Uri.parse("http://127.0.0.1:5000/caption");

    var request = http.MultipartRequest('POST', uri);

    request.files.add(
      await http.MultipartFile.fromPath('image', image!.path),
    );

    var response = await request.send();

    var res = await http.Response.fromStream(response);

    var data = jsonDecode(res.body);

    setState(() {
      caption = data[0]["generated_text"];
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CAPTION GENERATOR"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            image != null
                ? Image.file(image!, height: 250)
                : const Icon(Icons.image, size: 120),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Pick Image"),
            ),

            ElevatedButton(
              onPressed: generateCaption,
              child: const Text("Generate Caption"),
            ),

            const SizedBox(height: 20),

            loading
                ? const CircularProgressIndicator()
                : Text(
                    caption,
                    style: const TextStyle(fontSize: 18),
                  )
          ],
        ),
      ),
    );
  }
}