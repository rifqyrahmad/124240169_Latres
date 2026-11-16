import 'package:shared_preferences/shared_preferences.dart';
import '../models/character_model.dart';

class PreferencesService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'logged_in_username';
  static const String _keyFavorites = 'saved_favorites';

  Future<void> setLoginSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, username);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  Future<String?> getLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  Future<void> clearLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUsername);
  }

  Future<void> saveFavorites(List<Character> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = Character.encodeList(favorites);
    await prefs.setString(_keyFavorites, jsonStr);
  }

  Future<List<Character>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyFavorites);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    return Character.decodeList(jsonStr);
  }
}
