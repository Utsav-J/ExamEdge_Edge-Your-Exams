class DocumentSummary {
  final String documentOverview;
  final List<String> keyPoints;
  final List<String> mainTopics;

  DocumentSummary({
    required this.documentOverview,
    required this.keyPoints,
    required this.mainTopics,
  });

  factory DocumentSummary.fromJson(Map<String, dynamic> json) {
    return DocumentSummary(
      documentOverview: json['document_overview'] as String,
      keyPoints: List<String>.from(json['key_points']),
      mainTopics: List<String>.from(json['main_topics']),
    );
  }
}
