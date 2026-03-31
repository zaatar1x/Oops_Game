import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'tetris/tetris_page.dart';
import 'sudoku/sudoku_page.dart';
import 'memory_game/widgets/difficulty_selector.dart';
import 'flow_game/flow_game_complete.dart'; // NEW COMPLETE SYSTEM

class MiniGamesMenuPage extends StatelessWidget {
  const MiniGamesMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mini Games'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a Game',
                style: AppTextStyles.title.copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Play mini games to earn points and climb the leaderboard!',
                style: AppTextStyles.body.copyWith(color: AppColors.grey),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  children: [
                    _buildGameCard(
                      context: context,
                      title: 'Tetris',
                      icon: Icons.grid_on_rounded,
                      gradient: AppColors.primaryGradient,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TetrisPage(),
                          ),
                        );
                      },
                    ),
                    _buildGameCard(
                      context: context,
                      title: 'Sudoku',
                      icon: Icons.grid_4x4_rounded,
                      gradient: AppColors.accentGradient,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SudokuPage(),
                          ),
                        );
                      },
                    ),
                    _buildGameCard(
                      context: context,
                      title: 'Memory',
                      icon: Icons.psychology_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DifficultySelector(),
                          ),
                        );
                      },
                    ),
                    _buildGameCard(
                      context: context,
                      title: 'Flow',
                      icon: Icons.blur_on_rounded,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF00E5FF),
                          Color(0xFF00B0FF),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FlowGameComplete(), // USING NEW SYSTEM
                          ),
                        );
                      },
                    ),
                    _buildGameCard(
                      context: context,
                      title: 'Coming Soon',
                      icon: Icons.lock_rounded,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.grey.withValues(alpha: 0.5),
                          AppColors.grey.withValues(alpha: 0.3),
                        ],
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('More games coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.white,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
