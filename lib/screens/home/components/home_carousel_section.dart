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
    final isDesktop = screenWidth > 1200; // Desktop solo sopra 1200px
    final isTablet = screenWidth >= 768 && screenWidth <= 1200;

    double height;
    if (isDesktop) {
      height = MediaQuery.of(context).size.height - 64;
    } else if (isTablet) {
      height = MediaQuery.of(context).size.height - 100;
    } else {
      height = 400;
    }

    return SizedBox(
      height: height,
      child: RecipeCarousel(
        recipes: recipes,
        title: '',
        onRecipeTap: onRecipeTap,
      ),
    );
  }
}
