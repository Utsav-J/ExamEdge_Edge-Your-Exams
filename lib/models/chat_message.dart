class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? citations;

  ChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.citations,
  });
}
