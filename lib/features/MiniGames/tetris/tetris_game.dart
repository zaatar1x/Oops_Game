import 'package:flame/game.dart';
import 'board.dart';
import 'piece.dart';
import 'constants.dart';

class TetrisGame extends FlameGame {
  late Board board;
  Piece? currentPiece;
  Piece? nextPiece;

  double fallTimer = 0;
  double currentSpeed = initialSpeed;

  int score = 0;
  int level = 1;
  int linesCleared = 0;

  bool isGameOver = false;
  bool isPaused = false;

  Function(int score, int level, int lines)? onScoreUpdate;
  Function()? onGameOverCallback;

  @override
  Future<void> onLoad() async {
    // Set camera to show the board
    camera.viewfinder.position = Vector2(cols * blockSize / 2, rows * blockSize / 2);
    camera.viewfinder.zoom = 1.0;

    board = Board();
    await add(board);

    nextPiece = Piece();
    spawnPiece();
  }

  void spawnPiece() {
    if (nextPiece != null) {
      currentPiece = nextPiece;
      add(currentPiece!);

      // Check if game over
      if (!currentPiece!.canMove(currentPiece!.position)) {
        gameOver();
        return;
      }
    }

    nextPiece = Piece();
  }

  void lockPiece() {
    if (currentPiece == null) return;

    // Lock the piece on the board
    board.lockPiece(currentPiece!.getCurrentBlocks(), currentPiece!.color);

    // Remove current piece
    currentPiece?.removeFromParent();
    currentPiece = null;

    // Clear lines and update score
    int cleared = board.clearLines();
    if (cleared > 0) {
      linesCleared += cleared;
      score += cleared * scorePerLine * level;

      // Level up every 10 lines
      int newLevel = (linesCleared / 10).floor() + 1;
      if (newLevel > level) {
        level = newLevel;
        currentSpeed = (initialSpeed - (level - 1) * speedIncrement).clamp(minSpeed, initialSpeed);
      }

      onScoreUpdate?.call(score, level, linesCleared);
    }

    // Check game over
    if (board.isGameOver()) {
      gameOver();
      return;
    }

    // Spawn next piece
    spawnPiece();
  }

  void gameOver() {
    isGameOver = true;
    onGameOverCallback?.call();
  }

  void restart() {
    // Remove current piece
    currentPiece?.removeFromParent();
    currentPiece = null;

    // Reset board
    board.reset();

    // Reset game state
    score = 0;
    level = 1;
    linesCleared = 0;
    currentSpeed = initialSpeed;
    isGameOver = false;
    isPaused = false;
    fallTimer = 0;

    // Spawn new piece
    nextPiece = Piece();
    spawnPiece();

    onScoreUpdate?.call(score, level, linesCleared);
  }

  void togglePause() {
    isPaused = !isPaused;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver || isPaused || currentPiece == null) return;

    fallTimer += dt;
    if (fallTimer >= currentSpeed) {
      currentPiece?.moveDown();
      fallTimer = 0;
    }
  }

  // Touch controls
  void moveLeft() {
    if (!isGameOver && !isPaused) {
      currentPiece?.moveLeft();
    }
  }

  void moveRight() {
    if (!isGameOver && !isPaused) {
      currentPiece?.moveRight();
    }
  }

  void rotatePiece() {
    if (!isGameOver && !isPaused) {
      currentPiece?.rotate();
    }
  }

  void softDrop() {
    if (!isGameOver && !isPaused) {
      currentPiece?.moveDown();
      fallTimer = 0;
    }
  }

  void hardDrop() {
    if (!isGameOver && !isPaused) {
      currentPiece?.hardDrop();
    }
  }
}
