import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void addMessage(String content, bool isUser, {List<String>? citations}) {
    _messages.add(
      ChatMessage(
        content: content,
        isUser: isUser,
        timestamp: DateTime.now(),
        citations: citations,
      ),
    );
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    addMessage(message, true);

    // Simulate AI response
    _isLoading = true;
    notifyListeners();

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Add AI response with citations
    addMessage(
      "This is a simulated response with citations from the document.",
      false,
      citations: ['Document 1, Page 2', 'Document 2, Page 5'],
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
