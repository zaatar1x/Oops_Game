import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../controllers/flow_controller.dart';
import 'node_component.dart';
import 'path_component.dart';

class GridComponent extends PositionComponent with DragCallbacks {
  final FlowController controller;
  final Function(bool) onWinStateChanged;
  final double cellSize = 70;
  final Map<String, List<PathComponent>> pathComponents = {};

  GridComponent({
    required this.controller,
    required this.onWinStateChanged,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildGrid();
  }

  void _buildGrid() {
    final size = controller.grid.length;

    // Draw grid background
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        add(_GridCell(
          position: Vector2(c * cellSize, r * cellSize),
          size: Vector2.all(cellSize),
        ));
      }
    }

    // Add nodes
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final color = controller.grid[r][c];
        if (color != null) {
          add(NodeComponent(
            row: r,
            col: c,
            color: color,
            position: Vector2(c * cellSize, r * cellSize),
            size: Vector2.all(cellSize),
            onTap: () {
              controller.startPath(color);
              _addPathAtPosition(r, c);
            },
          ));
        }
      }
    }
  }

  void clearPaths() {
    for (var paths in pathComponents.values) {
      for (var path in paths) {
        path.removeFromParent();
      }
    }
    pathComponents.clear();
  }

  void _addPathAtPosition(int row, int col) {
    if (controller.currentColor == null) return;
    if (controller.paths[row][col] == controller.currentColor) return;

    final success = controller.addPath(row, col);
    if (!success) return;

    final pathComponent = PathComponent(
      row: row,
      col: col,
      color: controller.currentColor!,
      position: Vector2(col * cellSize, row * cellSize),
      size: Vector2.all(cellSize),
    );

    pathComponents.putIfAbsent(controller.currentColor!, () => []);
    pathComponents[controller.currentColor!]!.add(pathComponent);
    add(pathComponent);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    
    final pos = event.localPosition;
    final col = (pos.x / cellSize).floor();
    final row = (pos.y / cellSize).floor();

    if (!controller.isInside(row, col)) return;
    
    final color = controller.grid[row][col];
    if (color != null) {
      controller.startPath(color);
      _addPathAtPosition(row, col);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (controller.currentColor == null) return;

    final pos = event.localEndPosition;
    final col = (pos.x / cellSize).floor();
    final row = (pos.y / cellSize).floor();

    if (!controller.isInside(row, col)) return;
    
    _addPathAtPosition(row, col);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (controller.checkWin()) {
      onWinStateChanged(true);
    }
    controller.currentColor = null;
  }
}

class _GridCell extends PositionComponent {
  _GridCell({required super.position, required super.size});

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF2C2C3E)
      ..style = PaintingStyle.fill;
    
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2, 2, size.x - 4, size.y - 4),
      const Radius.circular(8),
    );
    
    canvas.drawRRect(rect, paint);
    
    // Border
    final borderPaint = Paint()
      ..color = const Color(0xFF1A1A24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(rect, borderPaint);
  }
}