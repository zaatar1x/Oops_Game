import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import 'sudoku_game.dart';
import 'widgets/number_pad.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  late SudokuGame game;

  @override
  void initState() {
    super.initState();
    game = SudokuGame();
  }

  void _newGame() {
    setState(() {
      game = SudokuGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sudoku'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _newGame,
            tooltip: 'New Game',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final availableWidth = constraints.maxWidth;
            
            // Calculate grid size to fit screen without scrolling
            final maxGridSize = (availableWidth < availableHeight * 0.55) 
                ? availableWidth * 0.9 
                : availableHeight * 0.5;
            final gridSize = maxGridSize.clamp(280.0, 400.0);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1),
                
                // Sudoku grid
                Container(
                  width: gridSize,
                  height: gridSize,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    child: GameWidget(game: game),
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // Number pad
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: gridSize + 40),
                    child: NumberPad(game: game),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
              ],
            );
          },
        ),
      ),
    );
  }
}