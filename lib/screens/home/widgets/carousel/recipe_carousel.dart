import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:orsocook/models/recipe.dart';
import 'carousel_card.dart';

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
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth >= 768 && screenWidth <= 1200;
    final enableInfinite = widget.recipes.length >= 3;

    double viewportFraction;
    double cardWidth;
    double cardHeight;

    if (isDesktop) {
      viewportFraction = 0.6;
      cardWidth = 280;
      cardHeight = 500;
    } else if (isTablet) {
      viewportFraction = 0.7;
      cardWidth = 260;
      cardHeight = 450;
    } else {
      viewportFraction = 0.85;
      cardWidth = 220;
      cardHeight = 350;
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: cardHeight,
        viewportFraction: viewportFraction,
        enlargeCenterPage: isDesktop ? true : false,
        enlargeFactor: 0.25,
        enableInfiniteScroll: enableInfinite,
        autoPlay: false,
      ),
      items: widget.recipes.map((recipe) {
        return Container(
          width: cardWidth,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: CarouselCard.buildMainCard(
            recipe,
            () => widget.onRecipeTap(recipe),
          ),
        );
      }).toList(),
    );
  }
}
