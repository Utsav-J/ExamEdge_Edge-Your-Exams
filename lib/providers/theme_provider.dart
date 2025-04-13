import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  late StorageService _storageService;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _storageService = await StorageService.init();
    _themeMode = _storageService.getThemeMode();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    await _storageService.setThemeMode(mode);
    notifyListeners();
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  bool get isLightMode => _themeMode == ThemeMode.light;

  bool get isSystemMode => _themeMode == ThemeMode.system;
}
