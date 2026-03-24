import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'carousel_desktop.dart';
import 'carousel_mobile.dart';

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
  bool _isMobile = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    _isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade200,
      child: _isMobile
          ? CarouselMobile(
              recipes: widget.recipes,
              onRecipeTap: widget.onRecipeTap,
            )
          : CarouselDesktop(
              recipes: widget.recipes,
              onRecipeTap: widget.onRecipeTap,
            ),
    );
  }
}
