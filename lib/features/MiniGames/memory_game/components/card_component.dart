import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../models/memory_card_model.dart';

class CardComponent extends PositionComponent with TapCallbacks {
  final MemoryCardModel model;
  final Function(MemoryCardModel) onTap;

  CardComponent({
    required this.model,
    required this.onTap,
    required super.position,
    required super.size,
  });

  @override
  void render(Canvas canvas) {
    final rect = size.toRect();
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // Card background with gradient
    if (model.isMatched) {
      // Matched card - green gradient
      final paint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ).createShader(rect);
      canvas.drawRRect(rrect, paint);
    } else if (model.isFlipped) {
      // Flipped card - white with shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(rrect.shift(const Offset(0, 2)), shadowPaint);

      final paint = Paint()..color = Colors.white;
      canvas.drawRRect(rrect, paint);
    } else {
      // Face down card - gradient
      final paint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF2196F3)],
        ).createShader(rect);
      canvas.drawRRect(rrect, paint);

      // Pattern on back of card
      final patternPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 3,
        patternPaint,
      );
    }

    // Border
    final borderPaint = Paint()
      ..color = model.isMatched
          ? const Color(0xFF4CAF50)
          : Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, borderPaint);

    // Draw emoji if flipped or matched
    if (model.isFlipped || model.isMatched) {
      final tp = TextPainter(
        text: TextSpan(
          text: model.image,
          style: TextStyle(
            fontSize: size.x * 0.5,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      tp.layout();
      final offset = Offset(
        (size.x - tp.width) / 2,
        (size.y - tp.height) / 2,
      );
      tp.paint(canvas, offset);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!model.isMatched && !model.isFlipped) {
      onTap(model);
    }
  }
}