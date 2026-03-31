import 'dart:math';
import 'dart:collection';

/// Advanced level generator with difficulty scaling and full-grid solutions
class AdvancedLevelGenerator {
  static const int maxAttempts = 200;
  
  /// Generate a level with specific difficulty parameters
  /// [size] - Grid size (5x5, 6x6, etc.)
  /// [colorPairs] - Number of color pairs to place
  /// [difficulty] - 0.0 (easy) to 1.0 (hard)
  /// [requireFullGrid] - If true, ensures the solution fills all cells
  static List<List<String?>> generateLevel({
    required int size,
    required int colorPairs,
    double difficulty = 0.5,
    bool requireFullGrid = false,
  }) {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      attempts++;
      
      // Generate candidate based on difficulty
      final grid = _generateCandidateWithDifficulty(size, colorPairs, difficulty);
      
      // Validate
      if (_isValidLevel(grid, requireFullGrid: requireFullGrid)) {
        print('✓ Valid level (difficulty: ${(difficulty * 100).toInt()}%) generated in $attempts attempts');
        return grid;
      }
    }
    
    print('⚠ Max attempts reached, using fallback');
    return _generateFallbackLevel(size, colorPairs);
  }
  
  /// Generate candidate with difficulty-based placement
  static List<List<String?>> _generateCandidateWithDifficulty(
    int size,
    int colorPairs,
    double difficulty,
  ) {
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final colors = ['red', 'blue', 'green', 'yellow', 'purple', 'orange', 'pink', 'cyan'];
    final random = Random();
    
    for (int i = 0; i < colorPairs && i < colors.length; i++) {
      final color = colors[i];
      
      // Find available positions
      final available = <_Point>[];
      for (int r = 0; r < size; r++) {
        for (int c = 0; c < size; c++) {
          if (grid[r][c] == null) {
            available.add(_Point(r, c));
          }
        }
      }
      
      if (available.length < 2) break;
      
      // Place first node randomly
      available.shuffle(random);
      final pos1 = available.removeAt(0);
      grid[pos1.row][pos1.col] = color;
      
      // Place second node based on difficulty
      // Higher difficulty = greater distance between pairs
      final minDistance = (difficulty * size * 0.7).toInt();
      
      // Try to find a position with appropriate distance
      _Point? pos2;
      for (var candidate in available) {
        final distance = _manhattanDistance(pos1, candidate);
        if (distance >= minDistance) {
          pos2 = candidate;
          break;
        }
      }
      
      // Fallback: use any available position
      pos2 ??= available[random.nextInt(available.length)];
      grid[pos2.row][pos2.col] = color;
    }
    
    return grid;
  }
  
  /// Calculate Manhattan distance between two points
  static int _manhattanDistance(_Point a, _Point b) {
    return (a.row - b.row).abs() + (a.col - b.col).abs();
  }
  
  /// Validate level with optional full-grid requirement
  static bool _isValidLevel(List<List<String?>> grid, {bool requireFullGrid = false}) {
    // Extract color pairs
    final colorNodes = <String, List<_Point>>{};
    
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid[r].length; c++) {
        if (grid[r][c] != null) {
          colorNodes.putIfAbsent(grid[r][c]!, () => []);
          colorNodes[grid[r][c]!]!.add(_Point(r, c));
        }
      }
    }
    
    // Validate each color has exactly 2 nodes
    for (var entry in colorNodes.entries) {
      if (entry.value.length != 2) return false;
    }
    
    // Check basic connectivity
    for (var entry in colorNodes.entries) {
      if (!_hasPath(grid, entry.value[0], entry.value[1])) {
        return false;
      }
    }
    
    // If full grid required, check if solution exists that fills all cells
    if (requireFullGrid) {
      return _hasFullGridSolution(grid, colorNodes);
    }
    
    return true;
  }
  
  /// Check if path exists between two points (BFS)
  static bool _hasPath(List<List<String?>> grid, _Point start, _Point end) {
    final size = grid.length;
    final visited = List.generate(size, (_) => List<bool>.filled(size, false));
    final queue = Queue<_Point>();
    
    queue.add(start);
    visited[start.row][start.col] = true;
    
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      
      if (current == end) return true;
      
      for (var dir in [_Point(-1, 0), _Point(1, 0), _Point(0, -1), _Point(0, 1)]) {
        final newRow = current.row + dir.row;
        final newCol = current.col + dir.col;
        
        if (newRow < 0 || newRow >= size || newCol < 0 || newCol >= size) continue;
        if (visited[newRow][newCol]) continue;
        
        final cell = grid[newRow][newCol];
        if (cell == null || (newRow == end.row && newCol == end.col)) {
          visited[newRow][newCol] = true;
          queue.add(_Point(newRow, newCol));
        }
      }
    }
    
    return false;
  }
  
  /// Check if a solution exists that fills the entire grid
  /// Uses backtracking to attempt to solve the puzzle
  static bool _hasFullGridSolution(
    List<List<String?>> grid,
    Map<String, List<_Point>> colorNodes,
  ) {
    final size = grid.length;
    final paths = List.generate(size, (_) => List<String?>.filled(size, null));
    
    // Initialize paths with node positions
    for (var entry in colorNodes.entries) {
      for (var node in entry.value) {
        paths[node.row][node.col] = entry.key;
      }
    }
    
    // Try to solve using backtracking
    return _backtrackSolve(paths, colorNodes, 0);
  }
  
  /// Backtracking solver to check if full grid solution exists
  static bool _backtrackSolve(
    List<List<String?>> paths,
    Map<String, List<_Point>> colorNodes,
    int colorIndex,
  ) {
    final colors = colorNodes.keys.toList();
    
    // Base case: all colors connected
    if (colorIndex >= colors.length) {
      // Check if grid is full
      for (var row in paths) {
        if (row.contains(null)) return false;
      }
      return true;
    }
    
    final color = colors[colorIndex];
    final start = colorNodes[color]![0];
    final end = colorNodes[color]![1];
    
    // Try to find a path for this color
    final pathFound = _findPathForColor(paths, start, end, color);
    
    if (pathFound.isNotEmpty) {
      // Apply path
      for (var point in pathFound) {
        paths[point.row][point.col] = color;
      }
      
      // Recurse to next color
      if (_backtrackSolve(paths, colorNodes, colorIndex + 1)) {
        return true;
      }
      
      // Backtrack: remove path
      for (var point in pathFound) {
        if (point != start && point != end) {
          paths[point.row][point.col] = null;
        }
      }
    }
    
    return false;
  }
  
  /// Find a path for a specific color using BFS
  static List<_Point> _findPathForColor(
    List<List<String?>> paths,
    _Point start,
    _Point end,
    String color,
  ) {
    final size = paths.length;
    final visited = List.generate(size, (_) => List<bool>.filled(size, false));
    final parent = <_Point, _Point?>{};
    final queue = Queue<_Point>();
    
    queue.add(start);
    visited[start.row][start.col] = true;
    parent[start] = null;
    
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      
      if (current == end) {
        // Reconstruct path
        final path = <_Point>[];
        _Point? node = end;
        while (node != null) {
          path.add(node);
          node = parent[node];
        }
        return path.reversed.toList();
      }
      
      for (var dir in [_Point(-1, 0), _Point(1, 0), _Point(0, -1), _Point(0, 1)]) {
        final newRow = current.row + dir.row;
        final newCol = current.col + dir.col;
        
        if (newRow < 0 || newRow >= size || newCol < 0 || newCol >= size) continue;
        if (visited[newRow][newCol]) continue;
        
        final cell = paths[newRow][newCol];
        if (cell == null || cell == color) {
          visited[newRow][newCol] = true;
          parent[_Point(newRow, newCol)] = current;
          queue.add(_Point(newRow, newCol));
        }
      }
    }
    
    return [];
  }
  
  /// Fallback level generator
  static List<List<String?>> _generateFallbackLevel(int size, int colorPairs) {
    final grid = List.generate(size, (_) => List<String?>.filled(size, null));
    final colors = ['red', 'blue', 'green', 'yellow', 'purple', 'orange', 'pink', 'cyan'];
    
    int pairsPlaced = 0;
    
    // Simple edge placement
    for (int i = 0; i < size ~/ 2 && pairsPlaced < colorPairs && pairsPlaced < colors.length; i++) {
      final color = colors[pairsPlaced];
      grid[0][i * 2] = color;
      grid[size - 1][i * 2] = color;
      pairsPlaced++;
    }
    
    return grid;
  }
}

class _Point {
  final int row;
  final int col;
  
  _Point(this.row, this.col);
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Point && row == other.row && col == other.col;
  
  @override
  int get hashCode => row.hashCode ^ col.hashCode;
  
  @override
  String toString() => '($row, $col)';
}
