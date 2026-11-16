import 'package:flutter/material.dart';
import '../models/character_model.dart';
import '../services/api_service.dart';

class CharacterProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<Character> _characters = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  String _selectedStatus = 'All';
  String _searchQuery = '';

  List<Character> get characters => _characters;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;
  bool get hasMore => _currentPage < _totalPages;

  Future<void> fetchCharacters({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _characters = [];
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    } else {
      if (_isLoading || _isLoadingMore || !hasMore) return;
      _isLoadingMore = true;
      notifyListeners();
    }

    try {
      final result = await _api.getCharacters(
        page: _currentPage,
        status: _selectedStatus,
        name: _searchQuery,
      );

      final List<Character> newCharacters = result['characters'];
      _totalPages = result['totalPages'];

      if (refresh) {
        _characters = newCharacters;
      } else {
        _characters.addAll(newCharacters);
      }

      if (hasMore) {
        _currentPage++;
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String status) {
    if (_selectedStatus == status) return;
    _selectedStatus = status;
    fetchCharacters(refresh: true);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchCharacters(refresh: true);
  }
}
