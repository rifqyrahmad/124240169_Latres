import 'dart:convert';

class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String originName;
  final String locationName;
  final String image;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.originName,
    required this.locationName,
    required this.image,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      status: json['status'] as String? ?? 'unknown',
      species: json['species'] as String? ?? 'Unknown',
      gender: json['gender'] as String? ?? 'Unknown',
      originName: (json['origin'] != null && json['origin']['name'] != null)
          ? json['origin']['name'] as String
          : 'Unknown',
      locationName: (json['location'] != null && json['location']['name'] != null)
          ? json['location']['name'] as String
          : 'Unknown',
      image: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'gender': gender,
      'origin': {'name': originName},
      'location': {'name': locationName},
      'image': image,
    };
  }

  static String encodeList(List<Character> list) =>
      jsonEncode(list.map((c) => c.toJson()).toList());

  static List<Character> decodeList(String str) {
    if (str.isEmpty) return [];
    final Iterable l = jsonDecode(str);
    return List<Character>.from(l.map((model) => Character.fromJson(model)));
  }
}
