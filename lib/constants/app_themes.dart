import 'package:flutter/material.dart';

/// Want to build your own theme?
/// https://github.com/rxlabz/panache
class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: const Color(0xFF448AFF),
    textTheme: const TextTheme().apply(
      fontFamily: 'NotoSansArabic',
    ),
  )..setGradientColors(const [
      // Plum Plate
      Color(0xFFB0CDFF),
      Color(0xFFD8E5FB),
      Color(0xFFC3F9FE),
    ]);

  static final ThemeData darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
    textTheme: ThemeData.dark().textTheme.apply(
      fontFamily: 'NotoSansArabic',
    ),
  )..setGradientColors(const [
      Color(0xFF1F1B24),
      Color(0xFF2e2356),
    ]);

  /// Get theme with RTL support for Arabic
  static ThemeData getArabicTheme(ThemeData baseTheme) {
    return baseTheme.copyWith(
      // Ensure proper RTL layout
      visualDensity: VisualDensity.adaptivePlatformDensity,
      textTheme: baseTheme.textTheme.apply(
        fontFamily: 'NotoSansArabic',
      ),
      // RTL-specific button styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: 'NotoSansArabic',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: 'NotoSansArabic',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: 'NotoSansArabic',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // RTL-specific input decoration
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        labelStyle: const TextStyle(
          fontFamily: 'NotoSansArabic',
        ),
        hintStyle: const TextStyle(
          fontFamily: 'NotoSansArabic',
        ),
      ),
      // RTL-specific app bar theme
      appBarTheme: baseTheme.appBarTheme.copyWith(
        titleTextStyle: const TextStyle(
          fontFamily: 'NotoSansArabic',
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

extension GradientColorsTheme on ThemeData {
  static final Map<Brightness, List<Color>> _gradientColors = {};

  void setGradientColors(List<Color> colors) {
    _gradientColors[brightness] = colors;
  }

  List<Color> get gradientColors {
    return _gradientColors[brightness]!;
  }
}
