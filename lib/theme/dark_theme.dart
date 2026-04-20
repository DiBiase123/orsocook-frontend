import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'common_theme.dart';

class DarkTheme {
  static const Color registerColor = Color(0xFF4F46E5);

  static ThemeData get theme {
    final colorScheme = ColorSchemes.darkScheme;
    final base = ThemeCommon.baseTheme(colorScheme);

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: ThemeCommon.appBarTheme(colorScheme, isDark: true),
      elevatedButtonTheme: ThemeCommon.elevatedButtonTheme(colorScheme),
      textButtonTheme: ThemeCommon.textButtonTheme(colorScheme),
      inputDecorationTheme: ThemeCommon.inputDecorationTheme(colorScheme),
      cardTheme: ThemeCommon.cardTheme(colorScheme),
      dividerTheme: ThemeCommon.dividerTheme(colorScheme),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
