import 'package:flutter/material.dart';

const int rows = 20;
const int cols = 10;
const double blockSize = 20.0; // Reduced from 30 to 20 for better fit

// Tetromino types
enum TetrominoType { I, O, T, S, Z, J, L }

// Colors for each piece type
const Map<TetrominoType, Color> tetrominoColors = {
  TetrominoType.I: Color(0xFF00F0F0), // Cyan
  TetrominoType.O: Color(0xFFF0F000), // Yellow
  TetrominoType.T: Color(0xFFA000F0), // Purple
  TetrominoType.S: Color(0xFF00F000), // Green
  TetrominoType.Z: Color(0xFFF00000), // Red
  TetrominoType.J: Color(0xFF0000F0), // Blue
  TetrominoType.L: Color(0xFFF0A000), // Orange
};

// Tetromino shapes (relative positions)
const Map<TetrominoType, List<List<int>>> tetrominoShapes = {
  TetrominoType.I: [
    [0, 0, 0, 0],
    [1, 1, 1, 1],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ],
  TetrominoType.O: [
    [1, 1],
    [1, 1],
  ],
  TetrominoType.T: [
    [0, 1, 0],
    [1, 1, 1],
    [0, 0, 0],
  ],
  TetrominoType.S: [
    [0, 1, 1],
    [1, 1, 0],
    [0, 0, 0],
  ],
  TetrominoType.Z: [
    [1, 1, 0],
    [0, 1, 1],
    [0, 0, 0],
  ],
  TetrominoType.J: [
    [1, 0, 0],
    [1, 1, 1],
    [0, 0, 0],
  ],
  TetrominoType.L: [
    [0, 0, 1],
    [1, 1, 1],
    [0, 0, 0],
  ],
};

// Game speeds (seconds per drop)
const double initialSpeed = 0.8;
const double speedIncrement = 0.05;
const double minSpeed = 0.1;

// Scoring
const int scorePerLine = 100;
const int scorePerLevel = 1000;