import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'theme_common.dart';

class LightTheme {
  static ThemeData get theme {
    final colorScheme = ColorSchemes.lightScheme;
    final base = ThemeCommon.baseTheme(colorScheme);

    return base.copyWith(
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: ThemeCommon.appBarTheme(colorScheme, isDark: false),
      elevatedButtonTheme: ThemeCommon.elevatedButtonTheme(colorScheme),
      textButtonTheme: ThemeCommon.textButtonTheme(colorScheme),
      inputDecorationTheme: ThemeCommon.inputDecorationTheme(colorScheme),
      cardTheme: ThemeCommon.cardTheme(colorScheme),
      dividerTheme: ThemeCommon.dividerTheme(colorScheme),
    );
  }
}
