import 'dart:collection';
import 'flow_grid.dart';

/// SOLVER - Backtracking solver for validation (optional but recommended)
class FlowSolver {
  
  /// Attempt to solve puzzle using backtracking
  static bool canSolve(FlowGrid grid, Map<String, List<Point>> nodes) {
    final colors = nodes.keys.toList();
    return _backtrack(grid.clone(), nodes, colors, 0);
  }
  
  /// Backtracking algorithm
  static bool _backtrack(
    FlowGrid grid,
    Map<String, List<Point>> nodes,
    List<String> colors,
    int colorIndex,
  ) {
    if (colorIndex >= colors.length) return true;
    
    final color = colors[colorIndex];
    final start = nodes[color]![0];
    final end = nodes[color]![1];
    
    // Find all possible paths
    final paths = _findPaths(grid, start, end, color);
    
    for (final path in paths) {
      // Apply path
      for (final p in path) {
        if (grid.getCell(p.row, p.col).isEmpty) {
          grid.getCell(p.row, p.col).setPath(color);
        }
      }
      
      // Recurse
      if (_backtrack(grid, nodes, colors, colorIndex + 1)) {
        return true;
      }
      
      // Undo
      for (final p in path) {
        final cell = grid.getCell(p.row, p.col);
        if (cell.isPath && cell.color == color) {
          cell.clear();
        }
      }
    }
    
    return false;
  }
  
  /// Find all possible paths between two points
  static List<List<Point>> _findPaths(FlowGrid grid, Point start, Point end, String color) {
    final allPaths = <List<Point>>[];
    final queue = Queue<_PathState>();
    
    queue.add(_PathState([start], start));
    
    while (allPaths.length < 5 && queue.isNotEmpty) {
      final state = queue.removeFirst();
      
      if (state.current == end) {
        allPaths.add(state.path);
        continue;
      }
      
      for (final next in grid.getAdjacentCells(state.current.row, state.current.col)) {
        final cell = grid.getCell(next.row, next.col);
        
        if (cell.isEmpty || (cell.color == color)) {
          if (!state.path.contains(next)) {
            queue.add(_PathState([...state.path, next], next));
          }
        }
      }
    }
    
    return allPaths;
  }
}

class _PathState {
  final List<Point> path;
  final Point current;
  
  _PathState(this.path, this.current);
}
