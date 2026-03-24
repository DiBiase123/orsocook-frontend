import 'package:flutter/material.dart';

class CarouselCardGradient {
  static Widget buildMain() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withAlpha(180),
            Colors.black.withAlpha(200),
          ],
          stops: const [0.0, 0.5, 0.85, 1.0],
        ),
      ),
    );
  }

  static Widget buildSmall() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.transparent,
            Colors.black.withAlpha(150),
            Colors.black.withAlpha(180),
          ],
          stops: const [0.0, 0.5, 0.85, 1.0],
        ),
      ),
    );
  }
}
