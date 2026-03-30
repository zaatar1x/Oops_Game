import 'dart:math';

class SudokuGenerator {
  final _random = Random();

  List<List<int>> generateFullBoard() {
    List<List<int>> board =
        List.generate(9, (_) => List.filled(9, 0));

    _fill(board);
    return board;
  }

  bool _fill(List<List<int>> board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          var nums = List.generate(9, (i) => i + 1)..shuffle();

          for (var n in nums) {
            if (_safe(board, r, c, n)) {
              board[r][c] = n;

              if (_fill(board)) return true;

              board[r][c] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _safe(List<List<int>> b, int r, int c, int n) {
    for (int i = 0; i < 9; i++) {
      if (b[r][i] == n || b[i][c] == n) return false;
    }

    int sr = r - r % 3;
    int sc = c - c % 3;

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (b[sr + i][sc + j] == n) return false;
      }
    }

    return true;
  }

  List<List<int>> createPuzzle(List<List<int>> full, String diff) {
    int remove = diff == "hard" ? 50 : diff == "medium" ? 40 : 30;

    var puzzle = full.map((r) => [...r]).toList();

    while (remove > 0) {
      int r = _random.nextInt(9);
      int c = _random.nextInt(9);

      if (puzzle[r][c] != 0) {
        puzzle[r][c] = 0;
        remove--;
      }
    }

    return puzzle;
  }
}