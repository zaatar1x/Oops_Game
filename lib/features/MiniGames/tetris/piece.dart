import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'tetris_game.dart';
import 'pixel.dart';

class Piece extends Component with HasGameRef<TetrisGame> {
  TetrominoType type;
  List<List<int>> shape;
  Color color;
  Vector2 position; // Grid position (not pixel position)
  int rotationState = 0;
  List<Pixel> pixels = [];

  Piece({TetrominoType? type})
      : type = type ?? _randomType(),
        shape = [],
        color = Colors.white,
        position = Vector2(cols / 2 - 2, 0) {
    shape = List.from(tetrominoShapes[this.type]!.map((row) => List<int>.from(row)));
    color = tetrominoColors[this.type]!;
  }

  static TetrominoType _randomType() {
    final random = Random();
    return TetrominoType.values[random.nextInt(TetrominoType.values.length)];
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _updatePixels();
  }

  void _updatePixels() {
    // Remove old pixels
    for (var pixel in pixels) {
      pixel.removeFromParent();
    }
    pixels.clear();

    // Create new pixels based on current shape and position
    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          final pixel = Pixel(
            gridPosition: Vector2(
              position.x + col,
              position.y + row,
            ),
            color: color,
          );
          pixels.add(pixel);
          gameRef.add(pixel);
        }
      }
    }
  }

  List<Vector2> getCurrentBlocks() {
    List<Vector2> blocks = [];
    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          blocks.add(Vector2(position.x + col, position.y + row));
        }
      }
    }
    return blocks;
  }

  bool canMove(Vector2 newPosition) {
    for (int row = 0; row < shape.length; row++) {
      for (int col = 0; col < shape[row].length; col++) {
        if (shape[row][col] == 1) {
          int newRow = (newPosition.y + row).toInt();
          int newCol = (newPosition.x + col).toInt();

          // Check boundaries
          if (newCol < 0 || newCol >= cols || newRow >= rows) {
            return false;
          }

          // Check collision with locked pieces
          if (newRow >= 0 && !gameRef.board.isCellEmpty(newRow, newCol)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void moveDown() {
    Vector2 newPosition = Vector2(position.x, position.y + 1);
    if (canMove(newPosition)) {
      position = newPosition;
      _updatePixels();
    } else {
      // Lock the piece
      gameRef.lockPiece();
    }
  }

  void moveLeft() {
    Vector2 newPosition = Vector2(position.x - 1, position.y);
    if (canMove(newPosition)) {
      position = newPosition;
      _updatePixels();
    }
  }

  void moveRight() {
    Vector2 newPosition = Vector2(position.x + 1, position.y);
    if (canMove(newPosition)) {
      position = newPosition;
      _updatePixels();
    }
  }

  void rotate() {
    // Save current state
    List<List<int>> oldShape = List.from(shape.map((row) => List<int>.from(row)));
    int oldRotation = rotationState;

    // Rotate the shape 90 degrees clockwise
    int n = shape.length;
    List<List<int>> rotated = List.generate(n, (_) => List.filled(n, 0));

    for (int row = 0; row < n; row++) {
      for (int col = 0; col < n; col++) {
        rotated[col][n - 1 - row] = shape[row][col];
      }
    }

    shape = rotated;
    rotationState = (rotationState + 1) % 4;

    // Check if rotation is valid
    if (!canMove(position)) {
      // Try wall kicks
      List<Vector2> kicks = [
        Vector2(-1, 0), // Left
        Vector2(1, 0), // Right
        Vector2(-2, 0), // Left 2
        Vector2(2, 0), // Right 2
        Vector2(0, -1), // Up
      ];

      bool kickSuccessful = false;
      for (var kick in kicks) {
        Vector2 kickPosition = position + kick;
        if (canMove(kickPosition)) {
          position = kickPosition;
          kickSuccessful = true;
          break;
        }
      }

      // If no kick worked, revert rotation
      if (!kickSuccessful) {
        shape = oldShape;
        rotationState = oldRotation;
      }
    }

    _updatePixels();
  }

  void hardDrop() {
    while (canMove(Vector2(position.x, position.y + 1))) {
      position.y += 1;
    }
    _updatePixels();
    gameRef.lockPiece();
  }

  @override
  void onRemove() {
    for (var pixel in pixels) {
      pixel.removeFromParent();
    }
    super.onRemove();
  }
}
