import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PathComponent extends PositionComponent {
  final int row;
  final int col;
  final String color;
  double opacity = 0;

  PathComponent({
    required this.row,
    required this.col,
    required this.color,
    required super.position,
    required super.size,
  });

  @override
  void update(double dt) {
    super.update(dt);
    if (opacity < 1) {
      opacity = (opacity + dt * 4).clamp(0, 1);
    }
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 3.5;
    
    // Glow effect
    final glowPaint = Paint()
      ..color = _color().withValues(alpha: 0.2 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(center, radius + 6, glowPaint);
    
    // Main path circle
    final paint = Paint()..color = _color().withValues(alpha: 0.8 * opacity);
    canvas.drawCircle(center, radius, paint);
    
    // Inner shine
    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3 * opacity);
    canvas.drawCircle(center, radius / 2, shinePaint);
  }

  Color _color() {
    switch (color) {
      case "red":
        return const Color(0xFFFF5252);
      case "blue":
        return const Color(0xFF448AFF);
      case "green":
        return const Color(0xFF69F0AE);
      case "yellow":
        return const Color(0xFFFFD740);
      case "purple":
        return const Color(0xFFE040FB);
      case "orange":
        return const Color(0xFFFF9100);
      case "pink":
        return const Color(0xFFFF4081);
      case "cyan":
        return const Color(0xFF18FFFF);
      default:
        return Colors.white;
    }
  }
}