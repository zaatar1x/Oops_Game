import 'package:flame/components.dart';
import 'cell_component.dart';

class GridComponent extends PositionComponent {
  final List<List<int>> board;
  final List<List<int>> solution;
  final double cellSize = 40;

  CellComponent? selected;
  List<List<CellComponent>> cells = [];

  GridComponent({required this.board, required this.solution});

  @override
  Future<void> onLoad() async {
    cells = List.generate(9, (_) => []);

    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        final cell = CellComponent(
          row: r,
          col: c,
          value: board[r][c],
          isFixed: board[r][c] != 0,
          position: Vector2(c * cellSize, r * cellSize),
          size: Vector2.all(cellSize),
          onSelect: (cell) {
            // Deselect previous cell
            if (selected != null) {
              selected!.selected = false;
            }
            selected = cell;
          },
        );
        cells[r].add(cell);
        add(cell);
      }
    }
  }

  void updateSelectedCell(int value) {
    if (selected != null && !selected!.isFixed) {
      selected!.updateValue(value);
      board[selected!.row][selected!.col] = value;

      // Validate the move
      if (!_isValidMove(selected!.row, selected!.col, value)) {
        selected!.setError(true);
      }

      // Check if puzzle is complete
      if (_isPuzzleComplete()) {
        _onPuzzleComplete();
      }
    }
  }

  bool _isValidMove(int row, int col, int value) {
    // Check row
    for (int c = 0; c < 9; c++) {
      if (c != col && board[row][c] == value) return false;
    }

    // Check column
    for (int r = 0; r < 9; r++) {
      if (r != row && board[r][col] == value) return false;
    }

    // Check 3x3 box
    int startRow = row - row % 3;
    int startCol = col - col % 3;
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        int currentRow = startRow + r;
        int currentCol = startCol + c;
        if ((currentRow != row || currentCol != col) &&
            board[currentRow][currentCol] == value) {
          return false;
        }
      }
    }

    return true;
  }

  bool _isPuzzleComplete() {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] == 0) return false;
        if (board[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }

  void _onPuzzleComplete() {
    // Visual feedback - could trigger a callback to show completion dialog
    for (var row in cells) {
      for (var cell in row) {
        cell.selected = false;
      }
    }
  }

  void clearSelectedCell() {
    if (selected != null && !selected!.isFixed) {
      selected!.updateValue(0);
      board[selected!.row][selected!.col] = 0;
    }
  }
}