import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff67558e),
      surfaceTint: Color(0xff67558e),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffeaddff),
      onPrimaryContainer: Color(0xff4f3d75),
      secondary: Color(0xff416834),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffc2efae),
      onSecondaryContainer: Color(0xff2a4f1f),
      tertiary: Color(0xff1b6585),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffc3e8ff),
      onTertiaryContainer: Color(0xff004c68),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
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

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff6ecff),
      surfaceTint: Color(0xffd2bcfd),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffceb8f9),
      onPrimaryContainer: Color(0xff110031),
      secondary: Color(0xffcffdba),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffa3cf90),
      onSecondaryContainer: Color(0xff010f00),
      tertiary: Color(0xffe1f2ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xff8bcbef),
      onTertiaryContainer: Color(0xff000d15),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff141218),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff5edf9),
      outlineVariant: Color(0xffc7c0cb),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe7e0e8),
      inversePrimary: Color(0xff503e76),
      primaryFixed: Color(0xffeaddff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffd2bcfd),
      onPrimaryFixedVariant: Color(0xff17023c),
      secondaryFixed: Color(0xffc2efae),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffa7d394),
      onSecondaryFixedVariant: Color(0xff011500),
      tertiaryFixed: Color(0xffc3e8ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff8fcef3),
      onTertiaryFixedVariant: Color(0xff00131d),
      surfaceDim: Color(0xff141218),
      surfaceBright: Color(0xff524f55),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff211f24),
      surfaceContainer: Color(0xff322f35),
      surfaceContainerHigh: Color(0xff3d3a40),
      surfaceContainerHighest: Color(0xff49454c),
    );
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
    );
  }

  static ThemeData get darkHighContrastTheme {
    final materialTheme = MaterialTheme(GoogleFonts.poppinsTextTheme());
    final theme = materialTheme.darkHighContrast();

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
    );
  }
}
