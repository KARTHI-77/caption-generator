import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/caption_response.dart';

class ApiService {
  // Live Render backend
  static const String baseUrl =
    "https://caption-generator-api-d1q1.onrender.com";

  static const String endpoint = "$baseUrl/caption";

  static Future<CaptionResponse> generateCaption(
    XFile image,
    String style,
    String language,
    String platform,
  ) async {
    final uri = Uri.parse(endpoint);

    final request = http.MultipartRequest(
      "POST",
      uri,
    );

    // Send caption options to Flask backend
    request.fields["style"] = style;
    request.fields["language"] = language;
    request.fields["platform"] = platform;

    // Handle Flutter Web
    if (kIsWeb) {
      final bytes = await image.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          "image",
          bytes,
          filename: image.name,
        ),
      );
    } else {
      // Handle Android / iOS / Desktop
      request.files.add(
        await http.MultipartFile.fromPath(
          "image",
          image.path,
        ),
      );
    }

    final response = await request.send();

    final res = await http.Response.fromStream(response);

    // Check HTTP status before decoding
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        "Backend error (${res.statusCode}): ${res.body}",
      );
    }

    final data = jsonDecode(res.body);

    return CaptionResponse.fromJson(data);
  }
}