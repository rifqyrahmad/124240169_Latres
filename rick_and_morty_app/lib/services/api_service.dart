import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';
import '../models/episode_model.dart';

class ApiService {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  Future<Map<String, dynamic>> getCharacters({
    int page = 1,
    String? status,
    String? name,
  }) async {
    final queryParams = <String, String>{'page': page.toString()};
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }
    if (name != null && name.trim().isNotEmpty) {
      queryParams['name'] = name.trim();
    }

    final uri = Uri.parse('$baseUrl/character').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      // Jika filter/pencarian menghasilkan 0 data, API mengembalikan 404
      if (response.statusCode == 404) {
        return {'characters': <Character>[], 'totalPages': 0};
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List? ?? [];
        final info = data['info'] as Map<String, dynamic>? ?? {};

        final characters = results.map((item) => Character.fromJson(item)).toList();
        final totalPages = (info['pages'] as int?) ?? 1;

        return {'characters': characters, 'totalPages': totalPages};
      } else {
        throw Exception('Gagal memuat karakter (Kode: ${response.statusCode})');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
        throw Exception('Tidak ada koneksi internet. Periksa jaringan Anda.');
      }
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan tidak terduga: $e');
    }
  }

  Future<Character> getCharacterDetail(int id) async {
    final uri = Uri.parse('$baseUrl/character/$id');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode == 200) {
        return Character.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Detail karakter tidak ditemukan');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
        throw Exception('Tidak ada koneksi internet.');
      }
      if (e is Exception) rethrow;
      throw Exception('Gagal memuat detail karakter');
    }
  }

  Future<List<Episode>> getAllEpisodes() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('$baseUrl/episode?page=1')),
        http.get(Uri.parse('$baseUrl/episode?page=2')),
        http.get(Uri.parse('$baseUrl/episode?page=3')),
      ]).timeout(const Duration(seconds: 15));

      final List<Episode> allEpisodes = [];

      for (var response in responses) {
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final results = data['results'] as List? ?? [];
          allEpisodes.addAll(results.map((e) => Episode.fromJson(e)));
        }
      }

      return allEpisodes;
    } catch (e) {
      if (e.toString().contains('SocketException') || e.toString().contains('ClientException')) {
        throw Exception('Tidak ada koneksi internet.');
      }
      throw Exception('Gagal memuat daftar episode.');
    }
  }
}
