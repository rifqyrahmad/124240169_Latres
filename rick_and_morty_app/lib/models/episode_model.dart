class Episode {
  final int id;
  final String name;
  final String airDate;
  final String episode;

  Episode({
    required this.id,
    required this.name,
    required this.airDate,
    required this.episode,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      airDate: json['air_date'] as String? ?? '-',
      episode: json['episode'] as String? ?? '',
    );
  }
}
