import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_button.dart';
import 'tetris_game.dart';
import 'tetris_service.dart';
import 'constants.dart';

class TetrisPage extends StatefulWidget {
  const TetrisPage({super.key});

  @override
  State<TetrisPage> createState() => _TetrisPageState();
}

class _TetrisPageState extends State<TetrisPage> {
  late TetrisGame game;
  final tetrisService = TetrisService();
  int score = 0;
  int level = 1;
  int lines = 0;
  bool showGameOver = false;
  bool scoreSaved = false;

  @override
  void initState() {
    super.initState();
    game = TetrisGame()
      ..onScoreUpdate = (newScore, newLevel, newLines) {
        setState(() {
          score = newScore;
          level = newLevel;
          lines = newLines;
        });
      }
      ..onGameOverCallback = () {
        setState(() {
          showGameOver = true;
        });
        _saveScore();
      };
  }

  @override
  void dispose() {
    // Save score when leaving the page
    if (!scoreSaved && score > 0) {
      _saveScore();
    }
    super.dispose();
  }

  void _restart() {
    setState(() {
      showGameOver = false;
      score = 0;
      level = 1;
      lines = 0;
      scoreSaved = false;
    });
    game.restart();
  }

  void _togglePause() {
    game.togglePause();
    setState(() {});
  }

  Future<void> _saveScore() async {
    if (scoreSaved) return; // Prevent saving multiple times
    scoreSaved = true;

    try {
      await tetrisService.saveScore(
        score: score,
        level: level,
        linesCleared: lines,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Score saved! +$score XP & RP'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save score: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - 200; // Reserve space for appbar, stats, and controls
    final gameHeight = rows * blockSize;
    final scale = availableHeight < gameHeight ? availableHeight / gameHeight : 1.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tetris'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: Icon(game.isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: _togglePause,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Score Display - More compact
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard('Score', score.toString(), Icons.star),
                  _buildStatCard('Level', level.toString(), Icons.trending_up),
                  _buildStatCard('Lines', lines.toString(), Icons.grid_on),
                ],
              ),
            ),

            // Game Area
            Expanded(
              child: Center(
                child: Transform.scale(
                  scale: scale,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Game Widget
                      Container(
                        width: cols * blockSize,
                        height: rows * blockSize,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: GameWidget(game: game),
                      ),

                      // Pause Overlay
                      if (game.isPaused && !showGameOver)
                        Container(
                          width: cols * blockSize,
                          height: rows * blockSize,
                          color: Colors.black.withOpacity(0.7),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.pause_circle_outline,
                                  size: 60,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'PAUSED',
                                  style: AppTextStyles.title.copyWith(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Game Over Overlay
                      if (showGameOver)
                        Container(
                          width: cols * blockSize,
                          height: rows * blockSize,
                          color: Colors.black.withOpacity(0.9),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.gamepad,
                                  size: 60,
                                  color: AppColors.error,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'GAME OVER',
                                  style: AppTextStyles.title.copyWith(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Final Score: $score',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Level $level • $lines Lines',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.grey,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    border: Border.all(
                                      color: AppColors.success,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '✓ Score Saved',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                ElevatedButton(
                                  onPressed: _restart,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm,
                                    ),
                                  ),
                                  child: const Text('Play Again'),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Controls - More compact
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.background,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rotate and Hard Drop
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        Icons.rotate_right,
                        'Rotate',
                        () => game.rotatePiece(),
                      ),
                      _buildControlButton(
                        Icons.vertical_align_bottom,
                        'Drop',
                        () => game.hardDrop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Movement Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton(
                        Icons.arrow_back,
                        'Left',
                        () => game.moveLeft(),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _buildControlButton(
                        Icons.arrow_downward,
                        'Down',
                        () => game.softDrop(),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _buildControlButton(
                        Icons.arrow_forward,
                        'Right',
                        () => game.moveRight(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
