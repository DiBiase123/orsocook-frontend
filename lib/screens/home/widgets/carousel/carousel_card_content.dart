import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';

class CarouselCardContent {
  static Widget buildMain(Recipe recipe) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        double titleFontSize;

        if (screenWidth > 1200) {
          titleFontSize = 48; // ridotto da 84
        } else if (screenWidth > 800) {
          titleFontSize = 42; // ridotto da 72
        } else if (screenWidth > 600) {
          titleFontSize = 36; // ridotto da 60
        } else {
          titleFontSize = 32; // ridotto da 54
        }

        return Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 8,
                      color: Colors.black87,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Timer e porzioni separati
              Row(
                children: [
                  // Timer
                  Row(
                    children: [
                      const Icon(
                        Icons.timer,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.totalTime} min',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Porzioni
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.servings}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget buildSmall(Recipe recipe) {
    return Builder(
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        double titleFontSize;

        if (screenWidth > 1200) {
          titleFontSize = 28; // ridotto da 54
        } else if (screenWidth > 800) {
          titleFontSize = 24; // ridotto da 48
        } else if (screenWidth > 600) {
          titleFontSize = 22; // ridotto da 42
        } else {
          titleFontSize = 20; // ridotto da 39
        }

        return Positioned(
          bottom: 14,
          left: 12,
          right: 12,
          child: Text(
            recipe.title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                const Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 4,
                  color: Colors.black87,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
