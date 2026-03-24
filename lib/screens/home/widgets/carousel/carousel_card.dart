import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/screens/recipe/widgets/favorite_button.dart';
import 'hover_card.dart';
import 'carousel_card_image.dart';
import 'carousel_card_gradient.dart';
import 'carousel_card_content.dart';

class CarouselCard {
  // Card grande per desktop e mobile
  static Widget buildMainCard(Recipe recipe, VoidCallback onTap) {
    return HoverCard(
      onTap: onTap,
      borderRadius: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CarouselCardImage.build(recipe.imageUrl, isLarge: true),
            CarouselCardGradient.buildMain(),
            CarouselCardContent.buildMain(recipe),
            _buildTimerBadge(recipe, 20, 18, 14),
            _buildFavoriteButton(recipe, 20, 32),
          ],
        ),
      ),
    );
  }

  // Card grande per mobile (full width) - alias di buildMainCard
  static Widget buildMainCardFullWidth(Recipe recipe, VoidCallback onTap) {
    return buildMainCard(recipe, onTap);
  }

  // Card piccola
  static Widget buildSmallCard(Recipe recipe, VoidCallback onTap) {
    return HoverCard(
      onTap: onTap,
      borderRadius: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CarouselCardImage.build(recipe.imageUrl, isLarge: false),
            CarouselCardGradient.buildSmall(),
            CarouselCardContent.buildSmall(recipe),
            _buildTimerBadge(recipe, 12, 12, 11),
            _buildFavoriteButton(recipe, 12, 24),
          ],
        ),
      ),
    );
  }

  static Widget _buildTimerBadge(
      Recipe recipe, double top, double iconSize, double fontSize) {
    return Positioned(
      top: top,
      left: top,
      child: SizedBox(
        height: 44,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(200),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer, size: iconSize, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                '${recipe.totalTime} min',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildFavoriteButton(Recipe recipe, double top, double size) {
    return Positioned(
      top: top,
      right: top,
      child: SizedBox(
        height: 44,
        child: Center(
          child: FavoriteButton(
            recipeId: recipe.id,
            recipe: recipe,
            size: size,
          ),
        ),
      ),
    );
  }
}
