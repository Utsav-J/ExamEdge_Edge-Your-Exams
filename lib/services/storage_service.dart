import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recent_document.dart';
import '../models/mcq.dart';
import '../models/chat_conversation.dart';

class StorageService {
  static const String _recentDocumentsKey = 'recent_documents';
  static const String _themeModeKey = 'theme_mode';
  static const String _documentSummariesKey = 'document_summaries';
  static const String _mcqsKey = 'document_mcqs';
  static const String _chatConversationsKey = 'chat_conversations';
  // static const int _maxRecentDocuments = 10;

  late SharedPreferences _prefs;
  static late StorageService _instance;

  StorageService._();

  static Future<StorageService> init() async {
    _instance = StorageService._();
    _instance._prefs = await SharedPreferences.getInstance();
    return _instance;
  }

  // Recent Documents
  List<RecentDocument> getRecentDocuments() {
    final documentsJson = _prefs.getString(_recentDocumentsKey);
    if (documentsJson == null) {
      return [];
    }

    final List<dynamic> documentsList = json.decode(documentsJson);
    return documentsList.map((doc) => RecentDocument.fromJson(doc)).toList();
  }

  Future<void> saveRecentDocument(RecentDocument document) async {
    final documents = getRecentDocuments();
    documents.insert(0, document);
    print("documents $documents");
    if (documents.length > 10) {
      documents.removeLast();
    }
    print("documents $documents");
    print("got here");
    await _prefs.setString(_recentDocumentsKey,
        json.encode(documents.map((doc) => doc.toJson()).toList()));
    print("got here again");
  }

  Future<void> deleteDocument(String uniqueFilename) async {
    // Store the document and summary before deletion
    final documents = getRecentDocuments();
    final documentToDelete =
        documents.firstWhere((doc) => doc.uniqueFilename == uniqueFilename);
    final summaries = _getDocumentSummaries();
    final summaryToDelete = summaries[uniqueFilename];

    // Delete from recent documents
    documents.removeWhere((doc) => doc.uniqueFilename == uniqueFilename);
    await _prefs.setString(_recentDocumentsKey,
        json.encode(documents.map((doc) => doc.toJson()).toList()));

    // Delete summary from cache
    summaries.remove(uniqueFilename);
    await _prefs.setString(_documentSummariesKey, json.encode(summaries));

    // Store deleted document info for potential undo
    await _prefs.setString(
        'deleted_document_$uniqueFilename',
        json.encode({
          'document': documentToDelete.toJson(),
          'summary': summaryToDelete,
        }));
  }

  Future<void> restoreDocument(String uniqueFilename) async {
    // Get the stored document and summary
    final deletedDataJson =
        _prefs.getString('deleted_document_$uniqueFilename');
    if (deletedDataJson == null) return;

    final deletedData = json.decode(deletedDataJson);
    final document = RecentDocument.fromJson(deletedData['document']);
    final summary = deletedData['summary'];

    // Restore document to recent documents
    final documents = getRecentDocuments();
    documents.insert(0, document);
    if (documents.length > 10) {
      documents.removeLast();
    }
    await _prefs.setString(_recentDocumentsKey,
        json.encode(documents.map((doc) => doc.toJson()).toList()));

    // Restore summary to cache
    final summaries = _getDocumentSummaries();
    summaries[uniqueFilename] = summary;
    await _prefs.setString(_documentSummariesKey, json.encode(summaries));

    // Remove the temporary storage
    await _prefs.remove('deleted_document_$uniqueFilename');
  }

  Future<void> clearRecentDocuments() async {
    await _prefs.remove(_recentDocumentsKey);
  }

  // Theme Mode
  ThemeMode getThemeMode() {
    final String? themeMode = _prefs.getString(_themeModeKey);
    if (themeMode == null) return ThemeMode.system;

    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == themeMode,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themeModeKey, mode.toString());
  }

  // Document Summaries
  Future<void> saveDocumentSummary(
      String uniqueFilename, Map<String, dynamic> summary) async {
    final summaries = _getDocumentSummaries();
    summaries[uniqueFilename] = summary;
    await _prefs.setString(_documentSummariesKey, json.encode(summaries));
  }

  Map<String, dynamic>? getDocumentSummary(String uniqueFilename) {
    final summaries = _getDocumentSummaries();
    return summaries[uniqueFilename];
  }

  Map<String, Map<String, dynamic>> _getDocumentSummaries() {
    final summariesJson = _prefs.getString(_documentSummariesKey);
    if (summariesJson == null) return {};

    try {
      final Map<String, dynamic> decoded = json.decode(summariesJson);
      return decoded
          .map((key, value) => MapEntry(key, value as Map<String, dynamic>));
    } catch (e) {
      print('Error parsing document summaries: $e');
      return {};
    }
  }

  // MCQ Caching Methods
  Future<void> cacheMCQs(String uniqueFilename, List<MCQ> mcqs) async {
    final summaries = await getCachedMCQs();
    summaries[uniqueFilename] = mcqs;
    await _prefs.setString(
        _mcqsKey,
        jsonEncode({
          for (var entry in summaries.entries)
            entry.key: entry.value
                .map((mcq) => {
                      'question': mcq.question,
                      'options': mcq.options,
                      'answer': mcq.answer,
                    })
                .toList(),
        }));
  }

  Future<Map<String, List<MCQ>>> getCachedMCQs() async {
    final String? data = _prefs.getString(_mcqsKey);
    if (data == null) return {};

    final Map<String, dynamic> json = jsonDecode(data);
    return {
      for (var entry in json.entries)
        entry.key: (entry.value as List)
            .map((mcqJson) => MCQ.fromJson(mcqJson))
            .toList(),
    };
  }

  Future<List<MCQ>?> getCachedMCQsForDocument(String uniqueFilename) async {
    final summaries = await getCachedMCQs();
    return summaries[uniqueFilename];
  }

  Future<void> clearMCQs() async {
    await _prefs.remove(_mcqsKey);
  }

  // Cache videos for a document
  Future<void> cacheVideos(
      String uniqueFilename, Map<String, dynamic> videos) async {
    await _prefs.setString('videos_$uniqueFilename', json.encode(videos));
  }

  // Get cached videos for a document
  Map<String, dynamic>? getCachedVideos(String uniqueFilename) {
    final cachedData = _prefs.getString('videos_$uniqueFilename');
    if (cachedData != null) {
      return json.decode(cachedData) as Map<String, dynamic>;
    }
    return null;
  }

  // Cache books for a document
  Future<void> cacheBooks(
      String uniqueFilename, Map<String, dynamic> books) async {
    await _prefs.setString('books_$uniqueFilename', json.encode(books));
  }

  // Get cached books for a document
  Map<String, dynamic>? getCachedBooks(String uniqueFilename) {
    final cachedData = _prefs.getString('books_$uniqueFilename');
    if (cachedData != null) {
      return json.decode(cachedData) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear cache for a document
  Future<void> clearDocumentCache(String uniqueFilename) async {
    await _prefs.remove('videos_$uniqueFilename');
    await _prefs.remove('books_$uniqueFilename');
  }

  // Chat Conversations
  Future<void> saveChatConversation(ChatConversation conversation) async {
    final conversations = await getChatConversations();
    conversations[conversation.documentId] = conversation;

    final conversationsJson = conversations.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    await _prefs.setString(
        _chatConversationsKey, json.encode(conversationsJson));
  }

  Future<Map<String, ChatConversation>> getChatConversations() async {
    final conversationsJson = _prefs.getString(_chatConversationsKey);
    if (conversationsJson == null) return {};

    try {
      final Map<String, dynamic> decoded = json.decode(conversationsJson);
      return decoded.map(
        (key, value) => MapEntry(key, ChatConversation.fromJson(value)),
      );
    } catch (e) {
      print('Error parsing chat conversations: $e');
      return {};
    }
  }

  Future<ChatConversation?> getChatConversation(String documentId) async {
    final conversations = await getChatConversations();
    return conversations[documentId];
  }

  Future<void> clearChatConversation(String documentId) async {
    final conversations = await getChatConversations();
    conversations.remove(documentId);

    final conversationsJson = conversations.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    await _prefs.setString(
        _chatConversationsKey, json.encode(conversationsJson));
  }

  Future<void> clearAllChatConversations() async {
    await _prefs.remove(_chatConversationsKey);
  }
}
