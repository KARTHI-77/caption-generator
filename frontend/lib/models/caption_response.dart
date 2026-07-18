class CaptionResponse {
  final String caption;
  final List<String> hashtags;

  const CaptionResponse({required this.caption, required this.hashtags});

  factory CaptionResponse.fromJson(Map<String, dynamic> json) {
    return CaptionResponse(
      caption: json["generated_text"] ?? "",
      hashtags: List<String>.from(json["hashtags"] ?? []),
    );
  }
}
