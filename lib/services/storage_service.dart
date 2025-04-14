import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recent_document.dart';

class StorageService {
  static const String _recentDocumentsKey = 'recent_documents';
  static const String _themeModeKey = 'theme_mode';
  static const String _documentSummariesKey = 'document_summaries';
  // static const int _maxRecentDocuments = 10;

  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> init() async {
    final service = StorageService._();
    service._prefs = await SharedPreferences.getInstance();
    return service;
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
}
