import 'package:flutter/material.dart';

class BlockCell extends StatelessWidget {
  final Color color;
  final bool isGhost;
  final double size;

  static final Map<int, Color> _lightCache = {};
  static final Map<int, Color> _darkCache = {};

  const BlockCell({
    super.key,
    required this.color,
    required this.size,
    this.isGhost = false,
  });

  Color _lightenColor(Color c, double amount) {
    if (_lightCache.containsKey(c.toARGB32())) return _lightCache[c.toARGB32()]!;
    final r = ((c.r * 255.0) + (255 - (c.r * 255.0)) * amount).clamp(0, 255).truncate();
    final g = ((c.g * 255.0) + (255 - (c.g * 255.0)) * amount).clamp(0, 255).truncate();
    final b = ((c.b * 255.0) + (255 - (c.b * 255.0)) * amount).clamp(0, 255).truncate();
    final a = (c.a * 255.0).truncate();
    final out = Color.fromARGB(a, r, g, b);
    _lightCache[c.toARGB32()] = out;
    return out;
  }

  Color _darkenColor(Color c, double amount) {
    if (_darkCache.containsKey(c.toARGB32())) return _darkCache[c.toARGB32()]!;
    final r = ((c.r * 255.0) * (1 - amount)).clamp(0, 255).truncate();
    final g = ((c.g * 255.0) * (1 - amount)).clamp(0, 255).truncate();
    final b = ((c.b * 255.0) * (1 - amount)).clamp(0, 255).truncate();
    final a = (c.a * 255.0).truncate();
    final out = Color.fromARGB(a, r, g, b);
    _darkCache[c.toARGB32()] = out;
    return out;
  }

  @override
  Widget build(BuildContext context) {
    Decoration decoration;
    
    if (isGhost) {
      decoration = BoxDecoration(
        color: Colors.white.withAlpha(90), 
        border: Border.all(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(6),
        // Removed EXPENSIVE blur shadow completely
      );
    } else {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _lightenColor(color, 0.5),
            color,
            _darkenColor(color, 0.4),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        border: Border.all(color: Colors.white.withAlpha(50), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 0, // Sharp, solid drop shadows are INSTANT to render! Blur causes lag.
            spreadRadius: 0,
            offset: const Offset(1.5, 1.5),
          ),
        ],
        borderRadius: BorderRadius.circular(6),
      );
    }

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: decoration,
      ),
    );
  }
}
