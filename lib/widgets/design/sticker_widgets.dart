import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../themes/app_theme.dart';

class OrganicBackground extends StatelessWidget {
  final Widget child;
  const OrganicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(painter: _GrainPainter()),
        ),
        child,
      ],
    );
  }
}

class StickerCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final double radius;
  final VoidCallback? onTap;
  final bool rotated;

  const StickerCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.color = AppTheme.surface,
    this.radius = 28,
    this.onTap,
    this.rotated = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppTheme.oat.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.clay.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );

    final transformed = rotated
        ? Transform.rotate(angle: -0.012, child: card)
        : card;

    if (onTap == null) return transformed;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: transformed,
    );
  }
}

class StickerIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final double size;

  const StickerIcon({
    super.key,
    required this.icon,
    this.color = AppTheme.textInverse,
    this.backgroundColor = AppTheme.primary,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.24),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: size * 0.48),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const SectionTitle({super.key, required this.title, this.trailing, this.onTrailingTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
          if (trailing != null)
            TextButton(onPressed: onTrailingTap, child: Text(trailing!)),
        ],
      ),
    );
  }
}

class SoftChip extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SoftChip({
    super.key,
    required this.label,
    this.selected = false,
    this.icon,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: ChoiceChip(
          selected: selected,
          onSelected: (_) => onTap?.call(),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
              Text(label),
            ],
          ),
          labelStyle: TextStyle(
            color: selected ? AppTheme.textInverse : AppTheme.textSecondary,
            fontWeight: FontWeight.w800,
          ),
          selectedColor: AppTheme.primary,
          backgroundColor: AppTheme.surface,
          side: BorderSide(color: selected ? AppTheme.primary : AppTheme.oat),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        ),
      ),
    );
  }
}

class OrganicProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const OrganicProgressBar({super.key, required this.value, this.color = AppTheme.primary, this.height = 10});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        backgroundColor: color.withValues(alpha: 0.18),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.clay.withValues(alpha: 0.018);
    for (var i = 0; i < 420; i++) {
      final x = (math.sin(i * 12.9898) * 43758.5453).abs() % size.width;
      final y = (math.sin(i * 78.233) * 24634.6345).abs() % size.height;
      canvas.drawCircle(Offset(x, y), 0.7, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
