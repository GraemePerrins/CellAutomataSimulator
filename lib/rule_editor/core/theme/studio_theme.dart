import 'package:flutter/material.dart';

class StudioTheme {
  // Slate background tiers
  static const Color background = Color(0xFF0B1326);
  static const Color surfaceLowest = Color(0xFF060E20);
  static const Color surfaceLow = Color(0xFF131B2E);
  static const Color surfaceContainer = Color(0xFF171F33);
  static const Color surfaceHigh = Color(0xFF222A3D);
  static const Color surfaceHighest = Color(0xFF2D3449);

  // Borders & outlines
  static const Color outline = Color(0xFF8C909F);
  static const Color outlineVariant = Color(0xFF424754);
  static const Color borderSubtle = Color(0x33424754);

  // Accents
  static const Color primary = Color(0xFFADC6FF);
  static const Color primaryAccent = Color(0xFF4D8EFF);
  static const Color primaryContainer = Color(0xFF1E3A8A);
  static const Color onPrimary = Color(0xFF002E6A);

  static const Color secondary = Color(0xFF4EDEA3);
  static const Color secondaryAccent = Color(0xFF00A572);
  static const Color secondaryContainer = Color(0xFF064E3B);
  static const Color onSecondary = Color(0xFF003824);

  static const Color tertiary = Color(0xFFFFB95F);
  static const Color error = Color(0xFFFFB4AB);
  static const Color errorAccent = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFF93000A);

  static const Color onSurface = Color(0xFFDAE2FD);
  static const Color onSurfaceVariant = Color(0xFFC2C6D6);

  // Center cell evaluation transition colors
  static const Color centerCellUpdatedAlive = Color(0xFF38BDF8); // Electric cyan glow
  static const Color centerCellUpdatedDead = Color(0xFF475569);  // Quiescent slate

  // Fonts
  static const String monoFont = 'DejaVu Sans Mono';
  static const List<String> monoFontFamilyFallback = [
    'DejaVu Sans Mono',
    'Liberation Mono',
    'Ubuntu Mono',
    'Noto Sans Mono',
    'JetBrains Mono',
    'Fira Code',
    'Consolas',
    'Courier New',
    'monospace'
  ];

  static const String bodyFont = 'Inter';
  static const List<String> bodyFontFamilyFallback = [
    'Inter',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'sans-serif'
  ];

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      colorScheme: const ColorScheme.dark(
        surface: surfaceContainer,
        primary: primary,
        secondary: secondary,
        error: error,
        onSurface: onSurface,
      ),
      fontFamily: bodyFont,
      fontFamilyFallback: bodyFontFamilyFallback,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          color: onSurface,
          fontSize: 13,
          fontFamily: bodyFont,
        ),
        bodySmall: TextStyle(
          color: onSurfaceVariant,
          fontSize: 11,
          fontFamily: bodyFont,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: surfaceHighest,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: outlineVariant.withOpacity(0.5)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        textStyle: const TextStyle(
          color: onSurface,
          fontSize: 11,
          fontFamily: bodyFont,
        ),
      ),
    );
  }
}
