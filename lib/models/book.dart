class Book {
  final String title;
  final String authors;
  final String description;
  final String preview;
  final String thumbnail;

  Book({
    required this.title,
    required this.authors,
    required this.description,
    required this.preview,
    required this.thumbnail,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] as String,
      authors: json['authors'] as String,
      description: json['description'] as String,
      preview: json['preview'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }
}
