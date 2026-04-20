import 'package:flutter/material.dart';

class InformativeTheme {
  static Color sectionBg(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFFF0F9FF)
        : const Color(0xFF0C4A6E);
  }

  static Color border(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFFBAE6FD)
        : const Color(0xFF38BDF8);
  }

  static Color accent(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? const Color(0xFF0284C7)
        : const Color(0xFF7DD3FC);
  }

  static Color headerBg(ColorScheme colorScheme) {
    return colorScheme.brightness == Brightness.light
        ? accent(colorScheme)
        : const Color(0xFF0C4A6E);
  }
}
