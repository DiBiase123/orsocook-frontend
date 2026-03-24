import 'package:flutter/material.dart';
import 'package:orsocook/utils/logger.dart';

class LoginModalAnimation {
  static Widget entrance({
    required Widget child,
    required Duration duration,
    required Curve curve,
  }) {
    AppLogger.debug(
        '🎬 [ANIMATION] entrance chiamata, durata: ${duration.inMilliseconds}ms');
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: -0.5, end: 0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        // Log per ogni frame (solo per test)
        if (value == -0.5 || value == 0) {
          AppLogger.debug('🎬 [ANIMATION] value: $value');
        }
        return Transform.translate(
          offset: Offset(0, value * 300),
          child: Opacity(
            opacity: 1 - (value.abs() * 0.5).clamp(0, 1),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
