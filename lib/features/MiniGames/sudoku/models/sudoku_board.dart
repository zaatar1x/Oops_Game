class SudokuBoard {
  List<List<int>> puzzle;
  List<List<int>> solution;

  SudokuBoard({
    required this.puzzle,
    required this.solution,
  });

  bool isComplete() {
    for (var row in puzzle) {
      if (row.contains(0)) return false;
    }
    return true;
  }
}