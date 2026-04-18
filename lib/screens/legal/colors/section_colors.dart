import 'package:flutter/material.dart';

class SectionColors {
  static const List<Color> lightColors = [
    Color(0xFF0284C7),
    Color(0xFF0D9488),
    Color(0xFF059669),
    Color(0xFF7C3AED),
    Color(0xFFEA580C),
    Color(0xFFDB2777),
    Color(0xFF4F46E5),
    Color(0xFF0891B2),
    Color(0xFFD946EF),
    Color(0xFF16A34A),
  ];

  static const List<Color> darkColors = [
    Color(0xFF7DD3FC),
    Color(0xFF5EEAD4),
    Color(0xFF86EFAC),
    Color(0xFFC4B5FD),
    Color(0xFFFDBA74),
    Color(0xFFF9A8D4),
    Color(0xFFA5B4FC),
    Color(0xFF67E8F9),
    Color(0xFFF0ABFC),
    Color(0xFFBBF7D0),
  ];

  static Color getColor(int index, bool isDarkMode) {
    return isDarkMode
        ? darkColors[index % darkColors.length]
        : lightColors[index % lightColors.length];
  }
}
