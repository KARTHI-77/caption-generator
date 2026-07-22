class CaptionResponse {
  final String caption;
  final List<String> hashtags;
  final List<String> emojis;

  const CaptionResponse({
    required this.caption,
    required this.hashtags,
    required this.emojis,
  });

  factory CaptionResponse.fromJson(Map<String, dynamic> json) {
    return CaptionResponse(
      caption: json["generated_text"] ?? "",
      hashtags: List<String>.from(json["hashtags"] ?? []),
      emojis: List<String>.from(json["emojis"] ?? []),
    );
  }
}
