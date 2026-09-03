import 'package:shared_preferences/shared_preferences.dart';

/// Handles persisting and retrieving the user's chosen theme mode.
/// Kept isolated from UI/state-management so it can be swapped or tested
/// independently later.
class ThemePreferenceService {
  static const _themeKey = 'theme_mode';

  Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
  }

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }
}