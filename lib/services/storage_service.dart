import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recent_document.dart';

class StorageService {
  static const String _recentDocumentsKey = 'recent_documents';
  static const String _themeModeKey = 'theme_mode';
  static const int _maxRecentDocuments = 10;

  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService._(prefs);
  }

  // Recent Documents
  List<RecentDocument> getRecentDocuments() {
    final String? documentsJson = _prefs.getString(_recentDocumentsKey);
    if (documentsJson == null) return [];

    try {
      final List<dynamic> documentsList = json.decode(documentsJson);
      return documentsList.map((doc) => RecentDocument.fromJson(doc)).toList();
    } catch (e) {
      print('Error parsing recent documents: $e');
      // If there's an error, clear the corrupted data
      _prefs.remove(_recentDocumentsKey);
      return [];
    }
  }

  Future<void> addRecentDocument(RecentDocument document) async {
    try {
      final documents = getRecentDocuments();

      // Remove if document with same name exists
      documents.removeWhere((doc) => doc.fileName == document.fileName);

      // Add new document at the beginning
      documents.insert(0, document);

      // Keep only the most recent documents
      if (documents.length > _maxRecentDocuments) {
        documents.removeRange(_maxRecentDocuments, documents.length);
      }

      final List<Map<String, dynamic>> documentsJson =
          documents.map((doc) => doc.toJson()).toList();

      await _prefs.setString(
        _recentDocumentsKey,
        json.encode(documentsJson),
      );
    } catch (e) {
      print('Error adding recent document: $e');
      // If there's an error, clear the corrupted data
      await _prefs.remove(_recentDocumentsKey);
    }
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
}
