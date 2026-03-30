import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

class CellComponent extends PositionComponent with TapCallbacks {
  final int row;
  final int col;
  int value;
  final bool isFixed;
  final Function(CellComponent) onSelect;

  bool selected = false;
  bool isError = false;

  CellComponent({
    required this.row,
    required this.col,
    required this.value,
    required this.isFixed,
    required this.onSelect,
    required super.position,
    required super.size,
  });

  @override
  void render(Canvas canvas) {
    // Background color with smooth gradients
    Color bgColor = Colors.white;
    if (selected) {
      bgColor = const Color(0xFF90CAF9); // Medium blue
    } else if (isError) {
      bgColor = const Color(0xFFEF9A9A); // Medium red
    } else if (isFixed) {
      bgColor = const Color(0xFFEEEEEE); // Light gray
    }

    final paint = Paint()..color = bgColor;
    canvas.drawRect(size.toRect(), paint);

    // Grid lines with varying thickness
    final borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Thicker lines for 3x3 boxes
    if (row % 3 == 0) {
      borderPaint.strokeWidth = 3;
      borderPaint.color = Colors.grey.shade700;
    }
    if (col % 3 == 0) {
      borderPaint.strokeWidth = 3;
      borderPaint.color = Colors.grey.shade700;
    }

    canvas.drawRect(size.toRect(), borderPaint);

    // Draw number with better styling
    if (value != 0) {
      final tp = TextPainter(
        text: TextSpan(
          text: value.toString(),
          style: TextStyle(
            color: isFixed ? Colors.black87 : const Color(0xFF1565C0),
            fontSize: 24,
            fontWeight: isFixed ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: 0.5,
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

    // Highlight effect for selected cell
    if (selected) {
      final highlightPaint = Paint()
        ..color = const Color(0xFF1976D2).withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(size.toRect().deflate(1.5), highlightPaint);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!isFixed) {
      selected = true;
      onSelect(this);
    }
  }

  void updateValue(int newValue) {
    if (!isFixed) {
      value = newValue;
      isError = false;
    }
  }

  void setError(bool error) {
    isError = error;
  }
}