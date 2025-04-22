import 'package:cloud_firestore/cloud_firestore.dart';

class DocumentSummary {
  final String documentOverview;
  final List<String> keyPoints;
  final List<String> mainTopics;
  final DateTime createdAt;
  final String userId;

  DocumentSummary({
    required this.documentOverview,
    required this.keyPoints,
    required this.mainTopics,
    required this.userId,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory DocumentSummary.fromJson(Map<String, dynamic> json) {
    return DocumentSummary(
      documentOverview: json['document_overview'] as String,
      keyPoints: List<String>.from(json['key_points']),
      mainTopics: List<String>.from(json['main_topics']),
      userId: json['user_id'] as String,
      createdAt: json['created_at'] != null
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_overview': documentOverview,
      'key_points': keyPoints,
      'main_topics': mainTopics,
      'user_id': userId,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  factory DocumentSummary.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentSummary(
      documentOverview: data['document_overview'] as String,
      keyPoints: List<String>.from(data['key_points']),
      mainTopics: List<String>.from(data['main_topics']),
      userId: data['user_id'] as String,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }
}
