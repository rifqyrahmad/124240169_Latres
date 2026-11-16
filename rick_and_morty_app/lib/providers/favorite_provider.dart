import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/preferences_service.dart';

class FavoriteProvider with ChangeNotifier {
  final PreferencesService _prefs = PreferencesService();
  List<Character> _favorites = [];

  List<Character> get favorites => List.unmodifiable(_favorites);

  FavoriteProvider() {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _favorites = await _prefs.loadFavorites();
    notifyListeners();
  }

  bool isFavorite(int characterId) {
    return _favorites.any((c) => c.id == characterId);
  }

  Future<bool> toggleFavorite(Character character) async {
    final exists = isFavorite(character.id);
    if (exists) {
      _favorites.removeWhere((c) => c.id == character.id);
    } else {
      _favorites.add(character);
    }
    await _prefs.saveFavorites(_favorites);
    notifyListeners();
    return !exists;
  }

  Future<void> removeFavorite(int characterId) async {
    _favorites.removeWhere((c) => c.id == characterId);
    await _prefs.saveFavorites(_favorites);
    notifyListeners();
  }
}
