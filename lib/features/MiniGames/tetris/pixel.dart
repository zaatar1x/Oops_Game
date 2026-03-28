import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class Pixel extends PositionComponent {
  final Color color;
  final bool isGhost;

  Pixel({
    required Vector2 gridPosition,
    required this.color,
    this.isGhost = false,
  }) : super(
          position: Vector2(
            gridPosition.x * blockSize,
            gridPosition.y * blockSize,
          ),
          size: Vector2.all(blockSize),
        );

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = isGhost ? color.withOpacity(0.3) : color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw filled block
    canvas.drawRect(size.toRect(), paint);

    // Draw border
    canvas.drawRect(size.toRect(), borderPaint);

    // Draw inner highlight for 3D effect
    if (!isGhost) {
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(2, 2, size.x - 4, size.y - 4),
        highlightPaint,
      );
    }
  }
}
