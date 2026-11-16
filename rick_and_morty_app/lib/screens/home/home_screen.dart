import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/character_provider.dart';
import '../../widgets/character_card.dart';
import '../../widgets/error_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  final List<String> _statusOptions = ['All', 'Alive', 'Dead', 'unknown'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterProvider>().fetchCharacters(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CharacterProvider>().fetchCharacters();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<CharacterProvider>().setSearchQuery(query);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CharacterProvider>();

    return Column(
      children: [
        // Search Bar (Bonus)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Cari karakter (misal: Rick, Morty)...',
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF97CE4C)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.white54),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFF171E26),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
          ),
        ),

        // Status Filter Chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: _statusOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final status = _statusOptions[index];
              final isSelected = provider.selectedStatus.toLowerCase() == status.toLowerCase();

              return ChoiceChip(
                label: Text(status),
                selected: isSelected,
                selectedColor: const Color(0xFF97CE4C),
                backgroundColor: const Color(0xFF171E26),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF0F1419) : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF97CE4C) : Colors.white12,
                ),
                onSelected: (_) => provider.setStatusFilter(status),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Character List / Loading / Error
        Expanded(
          child: Builder(
            builder: (context) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF97CE4C)),
                );
              }

              if (provider.errorMessage != null && provider.characters.isEmpty) {
                return ErrorView(
                  message: provider.errorMessage!,
                  onRetry: () => provider.fetchCharacters(refresh: true),
                );
              }

              if (provider.characters.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 64, color: Colors.white24),
                      const SizedBox(height: 12),
                      const Text(
                        'Karakter tidak ditemukan.',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF97CE4C),
                backgroundColor: const Color(0xFF171E26),
                onRefresh: () async => provider.fetchCharacters(refresh: true),
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: provider.characters.length + (provider.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.characters.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF97CE4C)),
                        ),
                      );
                    }
                    return CharacterCard(character: provider.characters[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
