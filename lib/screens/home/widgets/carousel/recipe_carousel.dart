import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
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

    if (screenWidth < 768) {
      return CarouselMobile(
        recipes: widget.recipes,
        onRecipeTap: widget.onRecipeTap,
      );
    } else if (screenWidth < 1200) {
      // Tablet: mostra solo card centrale + colonna destra (senza peek)
      return CarouselTablet(
        recipes: widget.recipes,
        onRecipeTap: widget.onRecipeTap,
      );
    } else {
      // Desktop: effetto peek completo
      return CarouselDesktop(
        recipes: widget.recipes,
        onRecipeTap: widget.onRecipeTap,
      );
    }
  }
}
