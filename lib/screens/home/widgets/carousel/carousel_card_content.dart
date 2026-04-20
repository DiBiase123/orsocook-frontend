import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/responsive_utils.dart';

class CarouselCardContent {
  static Widget buildMain(Recipe recipe, BuildContext context) {
    double titleFontSize;

    if (ResponsiveBreakpoints.isLargeDesktop(context)) {
      titleFontSize = 48;
    } else if (ResponsiveBreakpoints.isDesktop(context)) {
      titleFontSize = 42;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      titleFontSize = 36;
    } else {
      titleFontSize = 32;
    }

    return Positioned(
      bottom: ResponsiveValues.gapLarge(context),
      left: ResponsiveValues.gapLarge(context),
      right: ResponsiveValues.gapLarge(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recipe.title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: const [
                Shadow(
                  offset: Offset(0, 2),
                  blurRadius: 8,
                  color: Colors.black87,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.timer, size: 14, color: Colors.white),
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
              Row(
                children: [
                  const Icon(Icons.people, size: 14, color: Colors.white),
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
  }

  static Widget buildSmall(Recipe recipe, BuildContext context) {
    double titleFontSize;

    if (ResponsiveBreakpoints.isLargeDesktop(context)) {
      titleFontSize = 28;
    } else if (ResponsiveBreakpoints.isDesktop(context)) {
      titleFontSize = 24;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      titleFontSize = 22;
    } else {
      titleFontSize = 20;
    }

    return Positioned(
      bottom: ResponsiveValues.gapMedium(context),
      left: ResponsiveValues.gapMedium(context),
      right: ResponsiveValues.gapMedium(context),
      child: Text(
        recipe.title,
        style: TextStyle(
          fontSize: titleFontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: const [
            Shadow(
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
  }
}
