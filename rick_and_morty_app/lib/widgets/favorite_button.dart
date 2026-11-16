import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/character_model.dart';
import '../providers/favorite_provider.dart';

class FavoriteButton extends StatefulWidget {
  final Character character;
  final double size;

  const FavoriteButton({
    super.key,
    required this.character,
    this.size = 26,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoriteProvider>();
    final isFav = favProvider.isFavorite(widget.character.id);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        iconSize: widget.size,
        splashRadius: widget.size + 4,
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? const Color(0xFFEF4444) : Colors.white70,
        ),
        onPressed: () async {
          _controller.forward(from: 0.0);
          final added = await favProvider.toggleFavorite(widget.character);

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                added
                    ? '${widget.character.name} ditambahkan ke favorit!'
                    : '${widget.character.name} dihapus dari favorit.',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: added ? const Color(0xFF1E293B) : const Color(0xFF334155),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
      ),
    );
  }
}
