import 'package:flutter/material.dart';

class HermesTheme {
  static const String appVersion = '1.0.12';
  static const int appBuildNumber = 13;

  static const Color background = Color(0xFF090A0F);
  static const Color surface = Color(0xFF131620);
  static const Color cardColor = Color(0xFF191D2C);
  static const Color cardBorder = Color(0xFF262D42);

  static const Color primary = Color(0xFF38BDF8); // Electric Cyan
  static const Color primaryHover = Color(0xFF0284C7);
  static const Color secondary = Color(0xFF818CF8); // Soft Indigo
  static const Color accent = Color(0xFFA855F7); // Violet
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFEF4444); // Red
  static const Color error = Color(0xFFEF4444); // Alias for danger

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: danger,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
