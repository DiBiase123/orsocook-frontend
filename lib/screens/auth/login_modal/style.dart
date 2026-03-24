import 'dart:ui';
import 'package:flutter/material.dart';

class LoginModalStyle {
  static const double cardWidth = 520; // da 450 a 520
  static const double borderRadius = 32;
  static const double borderWidth = 1.2;
  static const double blurSigma = 8;
  static const double shadowBlur = 30;
  static const double shadowOffsetY = 15;

  static BoxDecoration get containerDecoration {
    return BoxDecoration(
      color: Colors.white.withAlpha(245),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withAlpha(150),
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(30),
          blurRadius: shadowBlur,
          offset: Offset(0, shadowOffsetY),
        ),
      ],
    );
  }

  static BoxConstraints get constraints {
    return const BoxConstraints(minWidth: 350, maxWidth: 600);
  }
}
