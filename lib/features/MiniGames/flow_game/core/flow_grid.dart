/// GRID SYSTEM - Core data structure for Flow puzzle
class FlowGrid {
  final int size;
  final List<List<FlowCell>> cells;
  
  FlowGrid(this.size) : cells = List.generate(
    size,
    (r) => List.generate(size, (c) => FlowCell(r, c)),
  );
  
  FlowCell getCell(int row, int col) => cells[row][col];
  
  bool isValid(int row, int col) =>
      row >= 0 && row < size && col >= 0 && col < size;
  
  bool isEmpty(int row, int col) =>
      isValid(row, col) && cells[row][col].isEmpty;
  
  List<Point> getAdjacentCells(int row, int col) {
    final adjacent = <Point>[];
    final dirs = [[-1, 0], [1, 0], [0, -1], [0, 1]]; // UP, DOWN, LEFT, RIGHT
    
    for (final dir in dirs) {
      final newRow = row + dir[0];
      final newCol = col + dir[1];
      if (isValid(newRow, newCol)) {
        adjacent.add(Point(newRow, newCol));
      }
    }
    return adjacent;
  }
  
  FlowGrid clone() {
    final cloned = FlowGrid(size);
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        cloned.cells[r][c] = cells[r][c].clone();
      }
    }
    return cloned;
  }
  
  void clear() {
    for (var row in cells) {
      for (var cell in row) {
        cell.clear();
      }
    }
  }
}

/// CELL - Individual grid cell
class FlowCell {
  final int row;
  final int col;
  CellState state;
  String? color;
  
  FlowCell(this.row, this.col, {this.state = CellState.empty, this.color});
  
  bool get isEmpty => state == CellState.empty;
  bool get isNode => state == CellState.node;
  bool get isPath => state == CellState.path;
  
  void setNode(String nodeColor) {
    state = CellState.node;
    color = nodeColor;
  }
  
  void setPath(String pathColor) {
    state = CellState.path;
    color = pathColor;
  }
  
  void clear() {
    state = CellState.empty;
    color = null;
  }
  
  FlowCell clone() => FlowCell(row, col, state: state, color: color);
}

enum CellState { empty, node, path }

class Point {
  final int row;
  final int col;
  
  const Point(this.row, this.col);
  
  @override
  bool operator ==(Object other) =>
      other is Point && row == other.row && col == other.col;
  
  @override
  int get hashCode => row.hashCode ^ col.hashCode;
  
  @override
  String toString() => '($row, $col)';
}
