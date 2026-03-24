import 'package:flutter/material.dart';

class ForgotPasswordModalStyle {
  static const double cardWidth = 520;
  static const double borderRadius = 32;
  static const double borderWidth = 1.2;
  static const double blurSigma = 8;
  static const double shadowBlur = 40;
  static const double shadowOffsetY = 20;

  static BoxConstraints get constraints {
    return const BoxConstraints(minWidth: 350, maxWidth: 600);
  }
}
