import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../sudoku_game.dart';

class NumberPad extends StatelessWidget {
  final SudokuGame game;

  const NumberPad({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.white,
            AppColors.white.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Number buttons 1-9 in 3 rows
          ...List.generate(3, (rowIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (colIndex) {
                  final number = rowIndex * 3 + colIndex + 1;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _buildNumberButton(number),
                    ),
                  );
                }),
              ),
            );
          }),
          
          // Clear button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                game.sudokuWorld.clearCell();
              },
              icon: const Icon(Icons.backspace_outlined, size: 20),
              label: Text(
                'Clear',
                style: AppTextStyles.button.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                elevation: 3,
                shadowColor: AppColors.error.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: () {
          game.sudokuWorld.updateCell(number);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.2),
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
        child: Text(
          '$number',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}