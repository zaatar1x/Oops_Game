import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class NodeComponent extends PositionComponent with TapCallbacks {
  final int row;
  final int col;
  final String color;
  final VoidCallback onTap;
  double pulseAnimation = 0;

  NodeComponent({
    required this.row,
    required this.col,
    required this.color,
    required this.onTap,
    required super.position,
    required super.size,
  });

  @override
  void update(double dt) {
    super.update(dt);
    pulseAnimation += dt * 2;
  }

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    final baseRadius = size.x / 3;
    final pulseRadius = baseRadius + math.sin(pulseAnimation) * 3;
    
    // Outer glow
    final glowPaint = Paint()
      ..color = _color().withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, pulseRadius + 8, glowPaint);
    
    // Main circle with gradient
    final rect = Rect.fromCircle(center: center, radius: baseRadius);
    final gradient = RadialGradient(
      colors: [
        _color(),
        _color().withValues(alpha: 0.7),
      ],
    );
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawCircle(center, baseRadius, paint);
    
    // Inner highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4);
    canvas.drawCircle(
      Offset(center.dx - baseRadius / 4, center.dy - baseRadius / 4),
      baseRadius / 3,
      highlightPaint,
    );
    
    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, baseRadius, borderPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap();
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