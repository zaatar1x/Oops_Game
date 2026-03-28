import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'pixel.dart';

class Board extends Component {
  List<List<int>> grid = List.generate(
    rows,
    (_) => List.filled(cols, 0),
  );

  List<List<Color?>> colorGrid = List.generate(
    rows,
    (_) => List.filled(cols, null),
  );

  List<Pixel> lockedPixels = [];

  bool isCellEmpty(int row, int col) {
    if (row >= rows || col < 0 || col >= cols) return false;
    if (row < 0) return true;
    return grid[row][col] == 0;
  }

  void lockPiece(List<Vector2> blocks, Color color) {
    for (var block in blocks) {
      int row = block.y.toInt();
      int col = block.x.toInt();
      if (row >= 0 && row < rows && col >= 0 && col < cols) {
        grid[row][col] = 1;
        colorGrid[row][col] = color;

        // Create locked pixel
        final pixel = Pixel(
          gridPosition: Vector2(col.toDouble(), row.toDouble()),
          color: color,
        );
        lockedPixels.add(pixel);
        parent?.add(pixel);
      }
    }
  }

  int clearLines() {
    int linesCleared = 0;
    List<int> linesToClear = [];

    // Find completed lines
    for (int row = 0; row < rows; row++) {
      if (grid[row].every((cell) => cell == 1)) {
        linesToClear.add(row);
      }
    }

    // Clear lines
    for (int row in linesToClear.reversed) {
      grid.removeAt(row);
      colorGrid.removeAt(row);
      grid.insert(0, List.filled(cols, 0));
      colorGrid.insert(0, List.filled(cols, null));
      linesCleared++;
    }

    // Update locked pixels
    if (linesCleared > 0) {
      _updateLockedPixels();
    }

    return linesCleared;
  }

  void _updateLockedPixels() {
    // Remove all locked pixels
    for (var pixel in lockedPixels) {
      pixel.removeFromParent();
    }
    lockedPixels.clear();

    // Recreate locked pixels from grid
    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        if (grid[row][col] == 1 && colorGrid[row][col] != null) {
          final pixel = Pixel(
            gridPosition: Vector2(col.toDouble(), row.toDouble()),
            color: colorGrid[row][col]!,
          );
          lockedPixels.add(pixel);
          parent?.add(pixel);
        }
      }
    }
  }

  bool isGameOver() {
    // Check if any blocks in the top row
    return grid[0].any((cell) => cell == 1);
  }

  void reset() {
    grid = List.generate(rows, (_) => List.filled(cols, 0));
    colorGrid = List.generate(rows, (_) => List.filled(cols, null));

    for (var pixel in lockedPixels) {
      pixel.removeFromParent();
    }
    lockedPixels.clear();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw grid background
    final bgPaint = Paint()..color = Colors.black.withOpacity(0.8);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, cols * blockSize, rows * blockSize),
      bgPaint,
    );

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    for (int i = 0; i <= rows; i++) {
      canvas.drawLine(
        Offset(0, i * blockSize),
        Offset(cols * blockSize, i * blockSize),
        gridPaint,
      );
    }

    for (int i = 0; i <= cols; i++) {
      canvas.drawLine(
        Offset(i * blockSize, 0),
        Offset(i * blockSize, rows * blockSize),
        gridPaint,
      );
    }
  }
}
