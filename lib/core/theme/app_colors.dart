import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primary = Color(0xFF6C63FF);
  static const secondary = Color(0xFF00C9A7);
  static const accent = Color(0xFFFFC857);
  static const background = Color(0xFFF5F6FA);

  // Neutral Colors
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const grey = Color(0xFF9E9E9E);
  static const greyLight = Color(0xFFE0E0E0);
  static const greyDark = Color(0xFF424242);

  // Semantic Colors
  static const success = Color(0xFF00C9A7);
  static const error = Color(0xFFFF6B6B);
  static const warning = Color(0xFFFFC857);
  static const info = Color(0xFF6C63FF);

  // Gradient
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF8B83FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const accentGradient = LinearGradient(
    colors: [Color(0xFFFFC857), Color(0xFFFFD97D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
