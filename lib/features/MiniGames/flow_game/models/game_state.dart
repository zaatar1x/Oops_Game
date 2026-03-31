class GameState {
  final int gridSize;
  final List<List<String?>> grid;
  final List<List<String?>> paths;
  final Map<String, List<Position>> activePaths;
  final String? currentColor;
  final int moves;
  final int time;
  final int level;
  final bool isComplete;

  GameState({
    required this.gridSize,
    required this.grid,
    required this.paths,
    required this.activePaths,
    this.currentColor,
    this.moves = 0,
    this.time = 0,
    this.level = 1,
    this.isComplete = false,
  });

  GameState copyWith({
    int? gridSize,
    List<List<String?>>? grid,
    List<List<String?>>? paths,
    Map<String, List<Position>>? activePaths,
    String? Function()? currentColor,
    int? moves,
    int? time,
    int? level,
    bool? isComplete,
  }) {
    return GameState(
      gridSize: gridSize ?? this.gridSize,
      grid: grid ?? this.grid,
      paths: paths ?? this.paths,
      activePaths: activePaths ?? this.activePaths,
      currentColor: currentColor != null ? currentColor() : this.currentColor,
      moves: moves ?? this.moves,
      time: time ?? this.time,
      level: level ?? this.level,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class Position {
  final int row;
  final int col;

  Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
  
  @override
  String toString() => 'Position($row, $col)';
}
