class Video {
  final String topic;
  final String title;
  final String channel;
  final String description;
  final String url;
  final String thumbnail;

  Video({
    required this.topic,
    required this.title,
    required this.channel,
    required this.description,
    required this.url,
    required this.thumbnail,
  });

  factory Video.fromJson(String topic, Map<String, dynamic> json) {
    return Video(
      topic: topic,
      title: json['title'] as String,
      channel: json['channel'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }
}
