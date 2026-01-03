import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0084FF);
  static const Color primaryHover = Color(0xFF0073E6);
  static const Color background = Color(0xFFF0F2F5);
  static const Color sidebarBg = Colors.white;
  static const Color textMain = Color(0xFF1C1E21);
  static const Color textMuted = Color(0xFF65676B);
  static const Color msgSent = Color(0xFF0084FF);
  static const Color msgReceived = Color(0xFFE4E6EB);
  static const Color online = Color(0xFF31A24C);
  static const Color border = Color(0xFFE4E6EB);
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primary,
      fontFamily: 'Inter', // Ensure Inter is in pubspec or use default sans
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textMain,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
