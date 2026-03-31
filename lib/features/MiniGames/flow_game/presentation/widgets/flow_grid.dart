import 'package:flutter/material.dart';
import '../../controllers/game_controller.dart';
import 'dart:math' as math;

class FlowGrid extends StatelessWidget {
  final FlowGameController controller;

  const FlowGrid({super.key, required this.controller});

  Color _getColor(String color) {
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

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final screenSize = MediaQuery.of(context).size;
    final gridPadding = 40.0;
    final availableSize = math.min(screenSize.width, screenSize.height - 200) - gridPadding * 2;
    final cellSize = availableSize / state.gridSize;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(gridPadding),
        child: GestureDetector(
          onPanStart: (details) {
            final localPos = details.localPosition;
            final row = (localPos.dy / cellSize).floor();
            final col = (localPos.dx / cellSize).floor();
            controller.startPath(row, col);
          },
          onPanUpdate: (details) {
            final localPos = details.localPosition;
            final row = (localPos.dy / cellSize).floor();
            final col = (localPos.dx / cellSize).floor();
            controller.updatePath(row, col);
          },
          onPanEnd: (_) {
            controller.endPath();
          },
          child: Container(
            width: availableSize,
            height: availableSize,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C3E),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: FlowGridPainter(
                  state: state,
                  cellSize: cellSize,
                  getColor: _getColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlowGridPainter extends CustomPainter {
  final dynamic state;
  final double cellSize;
  final Color Function(String) getColor;

  FlowGridPainter({
    required this.state,
    required this.cellSize,
    required this.getColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas);
    _drawLines(canvas);
    _drawNodes(canvas);
  }

  void _drawGrid(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF1A1A24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int r = 0; r <= state.gridSize; r++) {
      canvas.drawLine(
        Offset(0, r * cellSize),
        Offset(state.gridSize * cellSize, r * cellSize),
        paint,
      );
    }

    for (int c = 0; c <= state.gridSize; c++) {
      canvas.drawLine(
        Offset(c * cellSize, 0),
        Offset(c * cellSize, state.gridSize * cellSize),
        paint,
      );
    }
  }

  void _drawLines(Canvas canvas) {
    // Draw lines connecting the path
    for (var entry in state.activePaths.entries) {
      final color = entry.key;
      final path = entry.value;
      
      if (path.length < 2) continue;

      final lineColor = getColor(color);
      
      // Draw glow
      final glowPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.3)
        ..strokeWidth = cellSize * 0.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      final glowPath = Path();
      glowPath.moveTo(
        path[0].col * cellSize + cellSize / 2,
        path[0].row * cellSize + cellSize / 2,
      );
      for (int i = 1; i < path.length; i++) {
        glowPath.lineTo(
          path[i].col * cellSize + cellSize / 2,
          path[i].row * cellSize + cellSize / 2,
        );
      }
      canvas.drawPath(glowPath, glowPaint);

      // Draw main line
      final linePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.9)
        ..strokeWidth = cellSize * 0.25
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final linePath = Path();
      linePath.moveTo(
        path[0].col * cellSize + cellSize / 2,
        path[0].row * cellSize + cellSize / 2,
      );
      for (int i = 1; i < path.length; i++) {
        linePath.lineTo(
          path[i].col * cellSize + cellSize / 2,
          path[i].row * cellSize + cellSize / 2,
        );
      }
      canvas.drawPath(linePath, linePaint);

      // Draw highlight line
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..strokeWidth = cellSize * 0.12
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(linePath, highlightPaint);
    }
  }

  void _drawNodes(Canvas canvas) {
    for (int r = 0; r < state.gridSize; r++) {
      for (int c = 0; c < state.gridSize; c++) {
        final color = state.grid[r][c];
        if (color != null) {
          final center = Offset(
            c * cellSize + cellSize / 2,
            r * cellSize + cellSize / 2,
          );
          final radius = cellSize / 3.5;

          // Outer glow
          final glowPaint = Paint()
            ..color = getColor(color).withValues(alpha: 0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
          canvas.drawCircle(center, radius + 8, glowPaint);

          // Main circle with gradient
          final rect = Rect.fromCircle(center: center, radius: radius);
          final gradient = RadialGradient(
            colors: [
              getColor(color),
              getColor(color).withValues(alpha: 0.7),
            ],
          );
          final paint = Paint()..shader = gradient.createShader(rect);
          canvas.drawCircle(center, radius, paint);

          // Inner highlight
          final highlightPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.5);
          canvas.drawCircle(
            Offset(center.dx - radius / 4, center.dy - radius / 4),
            radius / 3,
            highlightPaint,
          );

          // Border
          final borderPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5;
          canvas.drawCircle(center, radius, borderPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(FlowGridPainter oldDelegate) => true;
}
