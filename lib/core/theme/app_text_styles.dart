import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Title
  static const title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.greyDark,
  );

  // Subtitle
  static const subtitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.greyDark,
  );

  // Body
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.grey,
  );

  // Button
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // Caption
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.grey,
  );

  // Label
  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.greyDark,
  );
}
