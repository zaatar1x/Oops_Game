import '../models/sudoku_board.dart';
import 'sudoku_generator.dart';
import 'sudoku_solver.dart';

class SudokuService {
  final generator = SudokuGenerator();
  final solver = SudokuSolver();

  SudokuBoard generate(String difficulty) {
    final full = generator.generateFullBoard();
    final puzzle = generator.createPuzzle(full, difficulty);

    return SudokuBoard(
      puzzle: puzzle,
      solution: full,
    );
  }

  bool isValidMove(
      List<List<int>> board, int row, int col, int value) {
    final temp = board.map((r) => [...r]).toList();
    temp[row][col] = value;

    return solver.solve(temp);
  }
}