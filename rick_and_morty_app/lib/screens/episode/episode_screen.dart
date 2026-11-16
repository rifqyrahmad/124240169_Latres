import 'package:flutter/material.dart';
import '../../models/episode_model.dart';
import '../../services/api_service.dart';
import '../../widgets/error_view.dart';

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  final ApiService _api = ApiService();
  late Future<List<Episode>> _episodesFuture;

  @override
  void initState() {
    super.initState();
    _loadEpisodes();
  }

  void _loadEpisodes() {
    setState(() {
      _episodesFuture = _api.getAllEpisodes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Episode>>(
      future: _episodesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF97CE4C)),
          );
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: snapshot.error.toString().replaceAll('Exception: ', ''),
            onRetry: _loadEpisodes,
          );
        }

        final episodes = snapshot.data ?? [];

        if (episodes.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada data episode.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: episodes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final ep = episodes[index];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF171E26),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF97CE4C).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ep.episode.isNotEmpty ? ep.episode : '#${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF97CE4C),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ep.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 12, color: Colors.white38),
                            const SizedBox(width: 6),
                            Text(
                              ep.airDate,
                              style: const TextStyle(color: Colors.white54, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
