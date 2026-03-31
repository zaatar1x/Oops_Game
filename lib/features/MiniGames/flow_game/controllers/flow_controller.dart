class FlowController {
  final List<List<String?>> grid;
  late List<List<String?>> paths;
  final Map<String, List<List<int>>> colorPaths = {};
  
  String? currentColor;
  int moves = 0;
  bool isComplete = false;

  FlowController(this.grid) {
    paths = List.generate(
      grid.length,
      (_) => List.filled(grid.length, null),
    );
  }

  void startPath(String color) {
    currentColor = color;
    clearPath(color);
    colorPaths[color] = [];
  }

  bool addPath(int row, int col) {
    if (currentColor == null) return false;
    
    // Don't allow overwriting other colors' paths or nodes
    if (paths[row][col] != null && paths[row][col] != currentColor) {
      return false;
    }
    
    // Don't allow overwriting other colors' nodes
    if (grid[row][col] != null && grid[row][col] != currentColor) {
      return false;
    }
    
    // Check if this is a valid adjacent move (only if we already have a path)
    if (colorPaths[currentColor]!.isNotEmpty) {
      final lastPos = colorPaths[currentColor]!.last;
      final distance = (row - lastPos[0]).abs() + (col - lastPos[1]).abs();
      if (distance != 1) return false; // Only allow adjacent moves
    }

    // If we're starting from a node, allow it
    if (colorPaths[currentColor]!.isEmpty && grid[row][col] == currentColor) {
      paths[row][col] = currentColor;
      colorPaths[currentColor]!.add([row, col]);
      return true;
    }

    paths[row][col] = currentColor;
    colorPaths[currentColor]!.add([row, col]);
    moves++;
    return true;
  }

  void clearPath(String color) {
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid.length; c++) {
        if (paths[r][c] == color) {
          paths[r][c] = null;
        }
      }
    }
    colorPaths[color] = [];
  }

  void clearAllPaths() {
    paths = List.generate(
      grid.length,
      (_) => List.filled(grid.length, null),
    );
    colorPaths.clear();
    currentColor = null;
    moves = 0;
    isComplete = false;
  }

  bool isInside(int r, int c) {
    return r >= 0 && c >= 0 && r < grid.length && c < grid.length;
  }

  bool checkWin() {
    // Check if all cells are filled
    for (var row in paths) {
      if (row.contains(null)) return false;
    }
    
    // Check if all color pairs are connected
    final colorNodes = <String, List<List<int>>>{};
    for (int r = 0; r < grid.length; r++) {
      for (int c = 0; c < grid.length; c++) {
        if (grid[r][c] != null) {
          colorNodes.putIfAbsent(grid[r][c]!, () => []);
          colorNodes[grid[r][c]!]!.add([r, c]);
        }
      }
    }
    
    // Verify each color connects its two nodes
    for (var entry in colorNodes.entries) {
      if (entry.value.length != 2) continue;
      final start = entry.value[0];
      final end = entry.value[1];
      
      if (paths[start[0]][start[1]] != entry.key || 
          paths[end[0]][end[1]] != entry.key) {
        return false;
      }
    }
    
    isComplete = true;
    return true;
  }
}