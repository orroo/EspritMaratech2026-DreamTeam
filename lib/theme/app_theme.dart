import 'package:flutter/material.dart';

class AppColors {
  static const terracotta = Color(0xFFE44D2E);
  static const ivory = Color(0xFFF7F3E3);
  static const silver = Color(0xFFB3B6B7);
  static const coffee = Color(0xFF2B2118);
  static const stone = Color(0xFF5E574D);
}

class AppTheme {
  static ThemeData light(TextTheme textTheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.ivory,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.terracotta,
        brightness: Brightness.light,
        primary: AppColors.terracotta,
        surface: Colors.white,
        onSurface: const Color(0xFF111111),
        background: AppColors.ivory,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.45)),
        labelStyle: TextStyle(color: Colors.black.withOpacity(0.75)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.terracotta, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerColor: Colors.black.withOpacity(0.08),
      textTheme: textTheme,
    );
  }

  static ThemeData dark(TextTheme textTheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.coffee,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.terracotta,
        brightness: Brightness.dark,
        primary: AppColors.terracotta,
        surface: AppColors.stone,
        onSurface: Colors.white,
        background: AppColors.coffee,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.stone.withOpacity(0.55),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.55)),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.75)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.terracotta, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.stone.withOpacity(0.65),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dividerColor: Colors.white.withOpacity(0.10),
      textTheme: textTheme,
    );
  }
}
