import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../services/level_data.dart';

class FlowGameController extends ChangeNotifier {
  late GameState _state;

  FlowGameController({int level = 1}) {
    _initLevel(level);
  }

  GameState get state => _state;

  void _initLevel(int level) {
    final levelData = level <= allLevels.length ? allLevels[level - 1] : allLevels[0];
    final gridSize = levelData.length;

    _state = GameState(
      gridSize: gridSize,
      grid: levelData.map((row) => List<String?>.from(row)).toList(),
      paths: List.generate(gridSize, (_) => List<String?>.filled(gridSize, null)),
      activePaths: {},
      level: level,
    );
  }

  void startPath(int row, int col) {
    if (row < 0 || col < 0 || row >= _state.gridSize || col >= _state.gridSize) return;
    
    final color = _state.grid[row][col];
    if (color == null) return;

    // Clear existing path for this color
    _clearColorPath(color);

    // Create new active path
    final newActivePaths = Map<String, List<Position>>.from(_state.activePaths);
    newActivePaths[color] = [Position(row, col)];

    _state = _state.copyWith(
      currentColor: () => color,
      activePaths: newActivePaths,
    );

    // Mark starting position
    _state.paths[row][col] = color;
    notifyListeners();
  }

  void updatePath(int row, int col) {
    if (_state.currentColor == null) return;
    if (row < 0 || col < 0 || row >= _state.gridSize || col >= _state.gridSize) return;

    final currentPath = _state.activePaths[_state.currentColor!];
    if (currentPath == null || currentPath.isEmpty) return;

    final lastPos = currentPath.last;
    
    // Check if same position
    if (lastPos.row == row && lastPos.col == col) return;
    
    // Check if adjacent
    final distance = (row - lastPos.row).abs() + (col - lastPos.col).abs();
    if (distance != 1) return;

    // Don't allow crossing other colors' paths
    final existingColor = _state.paths[row][col];
    if (existingColor != null && existingColor != _state.currentColor) {
      // Check if it's the endpoint node
      if (_state.grid[row][col] != _state.currentColor) {
        return;
      }
    }

    // Check if backtracking
    if (currentPath.length > 1) {
      final secondLast = currentPath[currentPath.length - 2];
      if (secondLast.row == row && secondLast.col == col) {
        // Remove last position (backtrack)
        final newPath = List<Position>.from(currentPath)..removeLast();
        final newActivePaths = Map<String, List<Position>>.from(_state.activePaths);
        newActivePaths[_state.currentColor!] = newPath;
        
        _state = _state.copyWith(activePaths: newActivePaths);
        _state.paths[lastPos.row][lastPos.col] = null;
        notifyListeners();
        return;
      }
    }

    // Add new position
    final newPath = List<Position>.from(currentPath)..add(Position(row, col));
    final newActivePaths = Map<String, List<Position>>.from(_state.activePaths);
    newActivePaths[_state.currentColor!] = newPath;
    
    _state = _state.copyWith(
      activePaths: newActivePaths,
      moves: _state.moves + 1,
    );
    
    _state.paths[row][col] = _state.currentColor;
    notifyListeners();
  }

  void endPath() {
    if (_state.currentColor != null) {
      _checkWin();
      _state = _state.copyWith(currentColor: () => null);
      notifyListeners();
    }
  }

  void _clearColorPath(String color) {
    for (int r = 0; r < _state.gridSize; r++) {
      for (int c = 0; c < _state.gridSize; c++) {
        if (_state.paths[r][c] == color) {
          _state.paths[r][c] = null;
        }
      }
    }
    
    final newActivePaths = Map<String, List<Position>>.from(_state.activePaths);
    newActivePaths.remove(color);
    _state = _state.copyWith(activePaths: newActivePaths);
  }

  void _checkWin() {
    // Check if all cells are filled
    for (var row in _state.paths) {
      if (row.contains(null)) return;
    }

    // Check if all color pairs are connected
    final colorNodes = <String, List<Position>>{};
    for (int r = 0; r < _state.gridSize; r++) {
      for (int c = 0; c < _state.gridSize; c++) {
        final color = _state.grid[r][c];
        if (color != null) {
          colorNodes.putIfAbsent(color, () => []);
          colorNodes[color]!.add(Position(r, c));
        }
      }
    }

    // Verify each color connects its two nodes
    for (var entry in colorNodes.entries) {
      if (entry.value.length != 2) continue;
      final start = entry.value[0];
      final end = entry.value[1];

      if (_state.paths[start.row][start.col] != entry.key ||
          _state.paths[end.row][end.col] != entry.key) {
        return;
      }
    }

    _state = _state.copyWith(isComplete: true);
    notifyListeners();
  }

  void restartLevel() {
    final currentLevel = _state.level;
    _initLevel(currentLevel);
    notifyListeners();
  }

  void nextLevel() {
    _initLevel(_state.level + 1);
    notifyListeners();
  }

  void updateTime(int time) {
    _state = _state.copyWith(time: time);
    notifyListeners();
  }
}
