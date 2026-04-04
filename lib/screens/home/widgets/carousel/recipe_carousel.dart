import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/logger.dart';
import 'carousel_desktop.dart';
import 'carousel_mobile.dart';
import 'carousel_tablet.dart';

class RecipeCarousel extends StatefulWidget {
  final List<Recipe> recipes;
  final String title;
  final VoidCallback? onSeeAllTap;
  final Function(Recipe) onRecipeTap;

  const RecipeCarousel({
    super.key,
    required this.recipes,
    required this.title,
    this.onSeeAllTap,
    required this.onRecipeTap,
  });

  @override
  State<RecipeCarousel> createState() => _RecipeCarouselState();
}

class _RecipeCarouselState extends State<RecipeCarousel> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    AppLogger.debug('🔍 [RECIPECAROUSEL] screenWidth: $screenWidth');
    AppLogger.debug(
        '🔍 [RECIPECAROUSEL] Numero ricette: ${widget.recipes.length}');

    if (screenWidth > 1200) {
      // Desktop: effetto peek + colonna destra + frecce laterali
      return CarouselDesktop(
        recipes: widget.recipes,
        onRecipeTap: widget.onRecipeTap,
      );
    } else if (screenWidth >= 768) {
      // Tablet: colonna centrale + colonna destra + frecce laterali (senza peek)
      return CarouselTablet(
        recipes: widget.recipes,
        onRecipeTap: widget.onRecipeTap,
      );
    } else {
      // Mobile: card singola + dots
      return CarouselMobile(
        recipes: widget.recipes,
        onRecipeTap: widget.onRecipeTap,
      );
    }
  }
}
