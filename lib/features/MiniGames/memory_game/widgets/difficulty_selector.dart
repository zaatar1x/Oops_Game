import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../memory_page.dart';

class DifficultySelector extends StatelessWidget {
  const DifficultySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Memory Game"),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose Difficulty',
                style: AppTextStyles.title.copyWith(fontSize: 28),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Test your memory skills!',
                style: AppTextStyles.body.copyWith(color: AppColors.grey),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _buildDifficultyCard(
                context,
                level: 'easy',
                title: 'Easy',
                subtitle: '4x3 Grid • 12 Cards',
                icon: Icons.sentiment_satisfied_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDifficultyCard(
                context,
                level: 'medium',
                title: 'Medium',
                subtitle: '4x4 Grid • 16 Cards',
                icon: Icons.sentiment_neutral_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDifficultyCard(
                context,
                level: 'hard',
                title: 'Hard',
                subtitle: '4x5 Grid • 20 Cards',
                icon: Icons.sentiment_very_dissatisfied_rounded,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF44336), Color(0xFFEF5350)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard(
    BuildContext context, {
    required String level,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MemoryPage(difficulty: level),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}