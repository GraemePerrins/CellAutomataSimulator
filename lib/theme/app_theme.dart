import 'package:flutter/material.dart';

class AppTheme {
  // Dark cyber aesthetic color palette
  static const Color background = Color(0xFF070B12);
  static const Color surface900 = Color(0xFF0B0F19);
  static const Color surface800 = Color(0xFF111827);
  static const Color surface700 = Color(0xFF1F2937);
  static const Color surface600 = Color(0xFF374151);

  static const Color border = Color(0xFF334155);
  static const Color borderLight = Color(0xFF475569);

  static const Color aliveColor = Color(0xFF10B981);
  static const Color aliveGlow = Color(0xFF34D399);
  static const Color deadColor = Color(0xFF070B12);

  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color redAccent = Color(0xFFEF4444);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      canvasColor: surface900,
      primaryColor: aliveColor,
      colorScheme: const ColorScheme.dark(
        primary: aliveColor,
        secondary: cyanAccent,
        surface: surface800,
        error: redAccent,
      ),
      fontFamily: 'Roboto',
      cardTheme: CardThemeData(
        color: surface800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surface700,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border),
        ),
        textStyle: const TextStyle(color: textPrimary, fontSize: 11),
      ),
    );
  }
}
