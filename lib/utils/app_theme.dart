import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  // ==================== LIGHT THEME (Standard Contrast) ====================
  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff7E69AB), // viola
      surfaceTint: Color(0xff7E69AB),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffeaddff),
      onPrimaryContainer: Color(0xff2e1a56),
      secondary: Color(0xff416834), // verde
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffc2efae),
      onSecondaryContainer: Color(0xff0b2b02),
      tertiary: Color(0xff1b6585), // azzurro
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc3e8ff),
      onTertiaryContainer: Color(0xff001e2c),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      surface: Color(0xfffef7ff),
      onSurface: Color(0xff1d1b20),
      onSurfaceVariant: Color(0xff49454e),
      outline: Color(0xff7a757f),
      outlineVariant: Color(0xffcbc4cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff322f35),
      inversePrimary: Color(0xffd2bcfd),
      primaryFixed: Color(0xffeaddff),
      onPrimaryFixed: Color(0xff220f46),
      primaryFixedDim: Color(0xffd2bcfd),
      onPrimaryFixedVariant: Color(0xff4f3d75),
      secondaryFixed: Color(0xffc2efae),
      onSecondaryFixed: Color(0xff032100),
      secondaryFixedDim: Color(0xffa7d394),
      onSecondaryFixedVariant: Color(0xff2a4f1f),
      tertiaryFixed: Color(0xffc3e8ff),
      onTertiaryFixed: Color(0xff001e2c),
      tertiaryFixedDim: Color(0xff8fcef3),
      onTertiaryFixedVariant: Color(0xff004c68),
      surfaceDim: Color(0xffded8e0),
      surfaceBright: Color(0xfffef7ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff8f1fa),
      surfaceContainer: Color(0xfff2ecf4),
      surfaceContainerHigh: Color(0xffece6ee),
      surfaceContainerHighest: Color(0xffe7e0e8),
    );
  }

  // ==================== DARK THEME (High Contrast) ====================
  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff1DB954), // verde Spotify
      surfaceTint: Color(0xff1DB954),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff2e8e3e),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xff7E69AB), // viola (tuo primary light)
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff9a87c4),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xff1ED760), // verde hover Spotify
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff0f9a3a),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffff5449),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff121212), // sfondo principale dark
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffc7c0cb),
      outlineVariant: Color(0xff49454e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe7e0e8),
      inversePrimary: Color(0xff7E69AB),
      primaryFixed: Color(0xff1DB954),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff0f7a2e),
      onPrimaryFixedVariant: Color(0xff000000),
      secondaryFixed: Color(0xff7E69AB),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff9a87c4),
      onSecondaryFixedVariant: Color(0xff000000),
      tertiaryFixed: Color(0xff1ED760),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff0f9a3a),
      onTertiaryFixedVariant: Color(0xff000000),
      surfaceDim: Color(0xff121212),
      surfaceBright: Color(0xff3b383e),
      surfaceContainerLowest: Color(0xff0a0a0a),
      surfaceContainerLow: Color(0xff1d1b20),
      surfaceContainer: Color(0xff2b292f),
      surfaceContainerHigh: Color(0xff36343a),
      surfaceContainerHighest: Color(0xff49454c),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );
}

class AppTheme {
  // ==================== LIGHT THEME ====================
  static ThemeData get lightTheme {
    final materialTheme = MaterialTheme(GoogleFonts.poppinsTextTheme());
    final theme = materialTheme.light();

    return theme.copyWith(
      scaffoldBackgroundColor: theme.colorScheme.surface,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
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
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        labelStyle:
            GoogleFonts.openSans(color: theme.colorScheme.onSurfaceVariant),
        hintStyle:
            GoogleFonts.openSans(color: theme.colorScheme.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        // invece di CardTheme
        color: theme.colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: theme.colorScheme.outlineVariant,
        thickness: 1,
      ),
    );
  }

  // ==================== DARK THEME ====================
  static ThemeData get darkTheme {
    final materialTheme = MaterialTheme(GoogleFonts.poppinsTextTheme());
    final theme = materialTheme.darkHighContrast();

    return theme.copyWith(
      scaffoldBackgroundColor: theme.colorScheme.surface,
      appBarTheme: theme.appBarTheme.copyWith(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: theme.colorScheme.secondary,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        labelStyle:
            GoogleFonts.openSans(color: theme.colorScheme.onSurfaceVariant),
        hintStyle:
            GoogleFonts.openSans(color: theme.colorScheme.onSurfaceVariant),
      ),
      cardTheme: CardThemeData(
        // invece di CardTheme
        color: theme.colorScheme.surfaceContainerHighest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant, width: 0.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: theme.colorScheme.outlineVariant,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}
