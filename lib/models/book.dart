class Book {
  final String topic;
  final String title;
  final String authors;
  final String description;
  final String preview;
  final String thumbnail;

  Book({
    required this.topic,
    required this.title,
    required this.authors,
    required this.description,
    required this.preview,
    required this.thumbnail,
  });

  factory Book.fromJson(String topic, Map<String, dynamic> json) {
    return Book(
      topic: topic,
      title: json['title'] as String,
      authors: json['authors'] as String,
      description: json['description'] as String,
      preview: json['preview'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }
}
