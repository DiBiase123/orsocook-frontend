import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/screens/home/widgets/carousel/index.dart';

class HomeCarouselSection extends StatelessWidget {
  final List<Recipe> recipes;
  final Function(Recipe) onRecipeTap;

  const HomeCarouselSection({
    super.key,
    required this.recipes,
    required this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    // Desktop: altezza piena schermo
    // Mobile: altezza fissa 400px
    return isDesktop
        ? SizedBox(
            height: MediaQuery.of(context).size.height - 64,
            child: RecipeCarousel(
              recipes: recipes,
              title: '',
              onRecipeTap: onRecipeTap,
            ),
          )
        : SizedBox(
            height: 400,
            child: RecipeCarousel(
              recipes: recipes,
              title: '',
              onRecipeTap: onRecipeTap,
            ),
          );
  }
}
