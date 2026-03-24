import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showGradient;

  const AppLogo({
    super.key,
    this.size = 120,
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: showGradient
          ? BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            )
          : null,
      child: Center(
        child: _buildLogoContent(),
      ),
    );
  }

  Widget _buildLogoContent() {
    // Try to load the logo image, fallback to placeholder if not found
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to a styled placeholder
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_emotions_rounded,
                  size: size * 0.4,
                  color: AppColors.white,
                ),
                SizedBox(height: size * 0.05),
                Text(
                  'Oops',
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
