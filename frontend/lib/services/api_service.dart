import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:5000";
  static const String endpoint = "$baseUrl/caption";

  static Future<String> generateCaption(File image) async {
    final uri = Uri.parse(endpoint);

    final request = http.MultipartRequest("POST", uri);

    request.files.add(
      await http.if (kIsWeb) {
  final bytes = await image.readAsBytes();

  request.files.add(
    http.MultipartFile.fromBytes(
      'image',
      bytes,
      filename: image.name,
    ),
  );
} else {
  request.files.add(
    await http.MultipartFile.fromPath(
      'image',
      image.path,
    ),
  );
}
    );

    final response = await request.send();

    final res = await http.Response.fromStream(response);

    final data = jsonDecode(res.body);

    return data[0]["generated_text"];
  }
}