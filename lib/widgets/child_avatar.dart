import 'package:flutter/material.dart';

/// Circular avatar for a child with auto-generated color
class ChildAvatar extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;

  const ChildAvatar({
    super.key,
    required this.name,
    this.size = 40,
    this.color,
  });

  Color _getColor() {
    if (color != null) return color!;
    final colors = [
      const Color(0xFFFF8C9E),
      const Color(0xFF5AC8FA),
      const Color(0xFFAF52DE),
      const Color(0xFFFF9500),
      const Color(0xFF4CD964),
      const Color(0xFFFF6482),
    ];
    return colors[name.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _getColor(),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '?',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.45,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
