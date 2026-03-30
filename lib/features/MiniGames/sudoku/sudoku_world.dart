import 'package:flame/components.dart';
import 'components/grid_component.dart';
import 'services/sudoku_service.dart';

class SudokuWorld extends World {
  final service = SudokuService();

  late List<List<int>> board;
  late List<List<int>> solution;
  late GridComponent grid;

  @override
  Future<void> onLoad() async {
    final sudoku = service.generate("medium");

    board = sudoku.puzzle;
    solution = sudoku.solution;

    grid = GridComponent(board: board, solution: solution);
    add(grid);
  }

  void updateCell(int value) {
    grid.updateSelectedCell(value);
  }

  void clearCell() {
    grid.clearSelectedCell();
  }
}