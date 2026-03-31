import 'dart:collection';
import 'flow_grid.dart';

/// VALIDATOR - Ensures grid state is valid
class FlowValidator {
  
  /// Validate complete puzzle solution
  static bool validateSolution(FlowGrid grid, Map<String, List<Point>> nodes) {
    // 1. Check all pairs are connected
    for (final entry in nodes.entries) {
      if (entry.value.length != 2) return false;
      if (!areNodesConnected(grid, entry.value[0], entry.value[1], entry.key)) {
        return false;
      }
    }
    
    // 2. Optional: Check all cells filled (for full-grid puzzles)
    // Uncomment if needed:
    // if (!isGridFull(grid)) return false;
    
    return true;
  }
  
  /// Check if two nodes are connected via continuous path (BFS)
  static bool areNodesConnected(FlowGrid grid, Point start, Point end, String color) {
    final visited = <String>{};
    final queue = Queue<Point>();
    
    queue.add(start);
    visited.add(_key(start));
    
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      
      if (current == end) return true;
      
      for (final next in grid.getAdjacentCells(current.row, current.col)) {
        final cell = grid.getCell(next.row, next.col);
        
        if (!visited.contains(_key(next)) && cell.color == color) {
          visited.add(_key(next));
          queue.add(next);
        }
      }
    }
    
    return false;
  }
  
  /// Check if grid is completely filled
  static bool isGridFull(FlowGrid grid) {
    for (var row in grid.cells) {
      for (var cell in row) {
        if (cell.isEmpty) return false;
      }
    }
    return true;
  }
  
  /// Count connected empty regions (for deadlock detection)
  static int countEmptyRegions(FlowGrid grid) {
    final visited = List.generate(
      grid.size,
      (_) => List<bool>.filled(grid.size, false),
    );
    
    int regions = 0;
    
    for (int r = 0; r < grid.size; r++) {
      for (int c = 0; c < grid.size; c++) {
        if (grid.isEmpty(r, c) && !visited[r][c]) {
          _floodFill(grid, visited, r, c);
          regions++;
        }
      }
    }
    
    return regions;
  }
  
  /// Flood fill to mark connected empty cells
  static void _floodFill(FlowGrid grid, List<List<bool>> visited, int row, int col) {
    if (!grid.isValid(row, col)) return;
    if (visited[row][col] || !grid.isEmpty(row, col)) return;
    
    visited[row][col] = true;
    
    _floodFill(grid, visited, row - 1, col);
    _floodFill(grid, visited, row + 1, col);
    _floodFill(grid, visited, row, col - 1);
    _floodFill(grid, visited, row, col + 1);
  }
  
  /// Validate each color has exactly 2 nodes
  static bool validateNodePairs(Map<String, List<Point>> nodes) {
    for (final entry in nodes.entries) {
      if (entry.value.length != 2) return false;
    }
    return true;
  }
  
  static String _key(Point p) => '${p.row},${p.col}';
}
