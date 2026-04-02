import 'package:flutter/material.dart';

class TermsModalStyle {
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth * 0.7; // 70% della larghezza schermo
  }

  static double getCardHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * 0.75; // 75% dell'altezza schermo
  }

  static const double borderRadius = 24.0;
}
