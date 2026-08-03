import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/caption_response.dart';

class ApiService {
  static const String baseUrl = "http://192.168.36.231:5000";
  static const String endpoint = "$baseUrl/caption";

  static Future<CaptionResponse> generateCaption(
    XFile image,
    String style,
    String language,
    String platform,
  ) async {
    final uri = Uri.parse(endpoint);

    final request = http.MultipartRequest("POST", uri);
    request.fields["style"] = style;
    request.fields["language"] = language;
    request.fields["platform"] = platform;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes("image", bytes, filename: image.name),
      );
    } else {
      request.files.add(await http.MultipartFile.fromPath("image", image.path));
    }

    final response = await request.send();

    final res = await http.Response.fromStream(response);

    final data = jsonDecode(res.body);

    return CaptionResponse.fromJson(data);
  }
}
