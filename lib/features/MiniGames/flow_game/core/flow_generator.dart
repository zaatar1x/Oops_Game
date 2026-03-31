import 'dart:math';
import 'flow_grid.dart';
import 'flow_validator.dart';

/// GENERATOR - Creates guaranteed solvable puzzles using solution-first approach
class FlowGenerator {
  static final _random = Random();
  
  /// Generate a guaranteed solvable puzzle
  static GeneratedPuzzle generate({
    required int size,
    required int colorCount,
    double difficulty = 0.5,
  }) {
    const maxAttempts = 100;
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final result = _tryGenerate(size, colorCount, difficulty);
      if (result != null) {
        print('✓ Generated in ${attempt + 1} attempts');
        return result;
      }
    }
    
    print('⚠ Using fallback');
    return _generateFallback(size, colorCount);
  }
  
  /// Attempt to generate a valid puzzle
  static GeneratedPuzzle? _tryGenerate(int size, int colorCount, double difficulty) {
    final grid = FlowGrid(size);
    final colors = _getColors(colorCount);
    final paths = <String, List<Point>>{};
    
    // Generate paths in order (longest first to prevent blocking)
    for (final color in colors) {
      final path = _generateValidPath(grid, size, difficulty, colorCount - paths.length);
      
      if (path == null || path.length < 2) return null;
      
      // Validate: won't cause deadlock
      if (!_validatePathPlacement(grid, path, colorCount - paths.length - 1)) {
        return null;
      }
      
      // Apply path
      for (final point in path) {
        grid.getCell(point.row, point.col).setPath(color);
      }
      
      paths[color] = path;
    }
    
    // Extract puzzle (only endpoints)
    return _extractPuzzle(grid, paths);
  }
  
  /// Generate a single valid path
  static List<Point>? _generateValidPath(
    FlowGrid grid,
    int size,
    double difficulty,
    int remainingColors,
  ) {
    const maxAttempts = 20;
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final path = _randomWalk(grid, size, difficulty);
      
      if (path == null || path.length < 2) continue;
      
      // Check if path would fragment grid
      if (_wouldFragmentGrid(grid, path)) continue;
      
      return path;
    }
    
    return null;
  }

  /// Random walk to generate path
  static List<Point>? _randomWalk(FlowGrid grid, int size, double difficulty) {
    // Find empty start
    final empty = <Point>[];
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid.isEmpty(r, c)) empty.add(Point(r, c));
      }
    }
    
    if (empty.isEmpty) return null;
    
    final start = empty[_random.nextInt(empty.length)];
    final path = <Point>[start];
    final visited = <String>{_key(start)};
    var current = start;
    
    final minLen = (3 + difficulty * size * 0.5).toInt();
    final maxLen = (size * size * 0.3).toInt();
    
    for (int step = 0; step < maxLen * 2; step++) {
      final neighbors = _getEmptyNeighbors(grid, current, visited);
      if (neighbors.isEmpty) break;
      
      current = neighbors[_random.nextInt(neighbors.length)];
      path.add(current);
      visited.add(_key(current));
      
      if (path.length >= minLen && _random.nextDouble() < 0.2) break;
    }
    
    return path.length >= minLen ? path : null;
  }
  
  /// Get empty adjacent cells
  static List<Point> _getEmptyNeighbors(FlowGrid grid, Point p, Set<String> visited) {
    final neighbors = <Point>[];
    for (final adj in grid.getAdjacentCells(p.row, p.col)) {
      if (grid.isEmpty(adj.row, adj.col) && !visited.contains(_key(adj))) {
        neighbors.add(adj);
      }
    }
    return neighbors;
  }
  
  /// Check if path would fragment grid
  static bool _wouldFragmentGrid(FlowGrid grid, List<Point> path) {
    final tempGrid = grid.clone();
    for (final p in path) {
      tempGrid.getCell(p.row, p.col).setPath('temp');
    }
    return FlowValidator.countEmptyRegions(tempGrid) > 1;
  }
  
  /// Validate path placement won't cause deadlock
  static bool _validatePathPlacement(FlowGrid grid, List<Point> path, int remaining) {
    if (remaining == 0) return true;
    
    final tempGrid = grid.clone();
    for (final p in path) {
      tempGrid.getCell(p.row, p.col).setPath('temp');
    }
    
    // Count empty cells
    int empty = 0;
    for (var row in tempGrid.cells) {
      for (var cell in row) {
        if (cell.isEmpty) empty++;
      }
    }
    
    // Need minimum space
    if (empty < 3 * remaining) return false;
    
    // Check connectivity
    return FlowValidator.countEmptyRegions(tempGrid) <= 1;
  }
  
  /// Extract puzzle from solution
  static GeneratedPuzzle _extractPuzzle(FlowGrid grid, Map<String, List<Point>> paths) {
    final puzzle = FlowGrid(grid.size);
    final nodes = <String, List<Point>>{};
    
    for (final entry in paths.entries) {
      final color = entry.key;
      final path = entry.value;
      
      final start = path.first;
      final end = path.last;
      
      puzzle.getCell(start.row, start.col).setNode(color);
      puzzle.getCell(end.row, end.col).setNode(color);
      
      nodes[color] = [start, end];
    }
    
    return GeneratedPuzzle(puzzle, nodes);
  }
  
  /// Fallback pattern
  static GeneratedPuzzle _generateFallback(int size, int colorCount) {
    final grid = FlowGrid(size);
    final nodes = <String, List<Point>>{};
    final colors = _getColors(colorCount);
    
    int placed = 0;
    for (int i = 0; i < size && placed < colors.length; i += 2) {
      final color = colors[placed];
      grid.getCell(0, i).setNode(color);
      grid.getCell(size - 1, i).setNode(color);
      nodes[color] = [Point(0, i), Point(size - 1, i)];
      placed++;
    }
    
    return GeneratedPuzzle(grid, nodes);
  }
  
  static List<String> _getColors(int count) {
    const all = ['red', 'blue', 'green', 'yellow', 'purple', 'orange', 'pink', 'cyan'];
    return all.take(count).toList();
  }
  
  static String _key(Point p) => '${p.row},${p.col}';
}

class GeneratedPuzzle {
  final FlowGrid grid;
  final Map<String, List<Point>> nodes;
  
  GeneratedPuzzle(this.grid, this.nodes);
}
