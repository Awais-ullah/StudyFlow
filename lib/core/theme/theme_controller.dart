import 'package:flutter/material.dart';
import '../services/theme_preference_service.dart';

class ThemeController extends ChangeNotifier {
  final ThemePreferenceService _service = ThemePreferenceService();

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeController() {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final saved = await _service.getThemeMode();
    if (saved != null) {
      _themeMode = _stringToThemeMode(saved);
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _service.saveThemeMode(_themeModeToString(mode));
  }

  String _themeModeToString(ThemeMode mode) => mode.name;

  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}