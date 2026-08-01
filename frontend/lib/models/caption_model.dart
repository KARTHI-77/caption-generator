import 'package:cloud_firestore/cloud_firestore.dart';

class CaptionModel {
  final String id;
  final String caption;
  final List<String> hashtags;
  final List<String> emojis;
  final String style;
  final String language;
  final String imageUrl;
  final bool favorite;
  final Timestamp createdAt;

  CaptionModel({
    required this.id,
    required this.caption,
    required this.hashtags,
    required this.emojis,
    required this.style,
    required this.language,
    required this.imageUrl,
    required this.favorite,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "caption": caption,
      "hashtags": hashtags,
      "emojis": emojis,
      "style": style,
      "language": language,
      "imageUrl": imageUrl,
      "favorite": favorite,
      "createdAt": createdAt,
    };
  }

  factory CaptionModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return CaptionModel(
      id: id,
      caption: map["caption"] ?? "",
      hashtags: List<String>.from(map["hashtags"] ?? []),
      emojis: List<String>.from(map["emojis"] ?? []),
      style: map["style"] ?? "",
      language: map["language"] ?? "",
      imageUrl: map["imageUrl"] ?? "",
      favorite: map["favorite"] ?? false,
      createdAt: map["createdAt"] ?? Timestamp.now(),
    );
  }
}