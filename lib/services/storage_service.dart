import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recent_document.dart';

class StorageService {
  static const String _recentDocumentsKey = 'recent_documents';
  static const String _themeModeKey = 'theme_mode';
  static const int _maxRecentDocuments = 10;

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
