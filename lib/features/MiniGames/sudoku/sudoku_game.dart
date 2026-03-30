import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'sudoku_world.dart';

class SudokuGame extends FlameGame {
  // Safe access to your world
  SudokuWorld get sudokuWorld => world as SudokuWorld;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Assign your world
    world = SudokuWorld();
    
    // Center the camera on the grid
    camera.viewfinder.anchor = Anchor.center;
    camera.viewfinder.position = Vector2(180, 180); // Center of 9x9 grid (40px cells)
  }
}