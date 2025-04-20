import 'chat_message.dart';

class ChatConversation {
  final String documentId;
  final List<ChatMessage> messages;
  final DateTime lastUpdated;

  ChatConversation({
    required this.documentId,
    required this.messages,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'documentId': documentId,
      'messages': messages
          .map((msg) => {
                'content': msg.content,
                'isUser': msg.isUser,
                'timestamp': msg.timestamp.toIso8601String(),
                'citations': msg.citations,
              })
          .toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      documentId: json['documentId'],
      messages: (json['messages'] as List)
          .map((msg) => ChatMessage(
                content: msg['content'],
                isUser: msg['isUser'],
                timestamp: DateTime.parse(msg['timestamp']),
                citations: msg['citations'] != null
                    ? List<String>.from(msg['citations'])
                    : null,
              ))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}
