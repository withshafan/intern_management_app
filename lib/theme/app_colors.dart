import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF7C6FF0);
  static const secondary = Color(0xFF2DD4BF);
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const danger = Color(0xFFF87171);

  static const darkBackground = Color(0xFF0F1115);
  static const darkSurface = Color(0xFF171A21);
  static const lightBackground = Color(0xFFF7F8FA);
  static const lightSurface = Color(0xFFFFFFFF);

  // Aliases for the default dark theme used in fixed gradients
  static const background = darkBackground;
  static const cardBackground = darkSurface;

  static Color glassFill(Brightness b) =>
      b == Brightness.dark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.55);

  static Color glassBorder(Brightness b) =>
      b == Brightness.dark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.06);
}
