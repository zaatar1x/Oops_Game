import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'memory_world.dart';

class MemoryGame extends FlameGame {
  final String difficulty;

  MemoryGame({required this.difficulty}) : super();

  MemoryWorld get memoryWorld => world as MemoryWorld;

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    world = MemoryWorld(difficulty: difficulty);
    
    // Center camera
    camera.viewfinder.anchor = Anchor.center;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Center camera on canvas center
    camera.viewfinder.position = size / 2;
  }
}