import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeCommon {
  // ==================== TEXT STYLES RESPONSIVE ====================

  static double _getAppBarTitleSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return 28;
    if (width >= 768) return 26;
    return 24;
  }

  static TextStyle appBarTitleStyle(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: _getAppBarTitleSize(context),
      fontWeight: FontWeight.w600,
    );
  }

  // ==================== BASE THEME ====================

  static ThemeData baseTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
    );
  }

  static AppBarTheme appBarTheme(ColorScheme colorScheme,
      {required bool isDark}) {
    return AppBarTheme(
      backgroundColor: isDark ? colorScheme.surface : colorScheme.primary,
      foregroundColor: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
      elevation: isDark ? 0 : 1,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? colorScheme.onSurface : colorScheme.onPrimary,
      ),
    );
  }

  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
    );
  }

  static TextButtonThemeData textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        textStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static InputDecorationTheme inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      labelStyle: GoogleFonts.openSans(color: colorScheme.onSurfaceVariant),
      hintStyle: GoogleFonts.openSans(color: colorScheme.onSurfaceVariant),
    );
  }

  static CardThemeData cardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surfaceContainerHigh,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      ),
    );
  }

  static DividerThemeData dividerTheme(ColorScheme colorScheme) {
    return DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
    );
  }
  // ==================== COLORI INFORMATIVI GENERICI ====================

  static Color informativeSectionBg(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFFF0F9FF)
        : const Color(0xFF0C4A6E);
  }

  static Color informativeBorder(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFFBAE6FD)
        : const Color(0xFF38BDF8);
  }

  static Color informativeAccent(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFF0284C7)
        : const Color(0xFF7DD3FC);
  }

  static Color informativeHeaderBg(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? informativeAccent(colorScheme)
        : const Color(0xFF0C4A6E);
  }
}
