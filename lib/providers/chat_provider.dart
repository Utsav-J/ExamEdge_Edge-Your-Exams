import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_conversation.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _documentId;
  late StorageService _storageService;
  bool _isInitialized = false;
  final ApiService _apiService = ApiService();

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> initialize(String documentId) async {
    if (_isInitialized && _documentId == documentId) return;

    _documentId = documentId;
    _storageService = await StorageService.init();

    // Load cached conversation
    final conversation = await _storageService.getChatConversation(documentId);
    if (conversation != null) {
      _messages.clear();
      _messages.addAll(conversation.messages);
    } else {
      _messages.clear();
    }

    _isInitialized = true;
    notifyListeners();
  }

  void addMessage(String content, bool isUser, {List<String>? citations}) {
    _messages.add(
      ChatMessage(
        content: content,
        isUser: isUser,
        timestamp: DateTime.now(),
        citations: citations,
      ),
    );
    _saveConversation();
    notifyListeners();
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    addMessage(message, true);

    // Check if we have a cached response for this exact message
    final conversation =
        await _storageService.getChatConversation(_documentId!);
    if (conversation != null) {
      final lastUserMessage = conversation.messages.lastWhere(
        (msg) => msg.isUser && msg.content == message,
        orElse: () => ChatMessage(
          content: '',
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );

      if (lastUserMessage.content.isNotEmpty) {
        final nextMessageIndex =
            conversation.messages.indexOf(lastUserMessage) + 1;
        if (nextMessageIndex < conversation.messages.length) {
          final nextMessage = conversation.messages[nextMessageIndex];
          if (!nextMessage.isUser) {
            addMessage(
              nextMessage.content,
              false,
              citations: nextMessage.citations,
            );
            return;
          }
        }
      }
    }

    // If no cached response, make API call
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.chatWithPdf(_documentId!, message);
      final aiMessage = response['response'] as String;
      final pages = response['pages_used'] as List;
      final citations = pages.map((page) => "Page $page").toList();

      addMessage(aiMessage, false, citations: citations);
    } catch (e) {
      addMessage(
        'Sorry, something went wrong while fetching the response.',
        false,
      );
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveConversation() async {
    if (_documentId == null) return;

    final conversation = ChatConversation(
      documentId: _documentId!,
      messages: List.from(_messages),
      lastUpdated: DateTime.now(),
    );

    await _storageService.saveChatConversation(conversation);
  }

  Future<void> clearChat() async {
    _messages.clear();
    if (_documentId != null) {
      await _storageService.clearChatConversation(_documentId!);
    }
    notifyListeners();
  }
}
