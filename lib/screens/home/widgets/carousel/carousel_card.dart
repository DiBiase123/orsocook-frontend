import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/screens/recipe/widgets/favorite_button.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/utils/responsive_utils.dart';
import 'package:orsocook/screens/home/widgets/carousel/hover_card.dart';
import 'package:orsocook/screens/home/widgets/carousel/carousel_card_image.dart';
import 'package:orsocook/screens/home/widgets/carousel/carousel_card_gradient.dart';
import 'package:orsocook/screens/home/widgets/carousel/carousel_card_content.dart';

class CarouselCard {
  static Widget buildMainCard(
      Recipe recipe, VoidCallback onTap, BuildContext context) {
    AppLogger.debug('🔍 [CAROUSELCARD] buildMainCard: ${recipe.title}');
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
            CarouselCardContent.buildMain(recipe, context),
            _buildTimerBadge(
                recipe, ResponsiveValues.gapLarge(context), 18, 14, context),
            _buildFavoriteButton(
                recipe, ResponsiveValues.gapLarge(context), 32),
          ],
        ),
      ),
    );
  }

  static Widget buildMainCardFullWidth(
      Recipe recipe, VoidCallback onTap, BuildContext context) {
    return buildMainCard(recipe, onTap, context);
  }

  static Widget buildSmallCard(
      Recipe recipe, VoidCallback onTap, BuildContext context) {
    AppLogger.debug('🔍 [CAROUSELCARD] buildSmallCard: ${recipe.title}');
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
            CarouselCardContent.buildSmall(recipe, context),
            _buildTimerBadge(
                recipe, ResponsiveValues.gapMedium(context), 12, 11, context),
            _buildFavoriteButton(
                recipe, ResponsiveValues.gapMedium(context), 24),
          ],
        ),
      ),
    );
  }

  static Widget _buildTimerBadge(Recipe recipe, double top, double iconSize,
      double fontSize, BuildContext context) {
    return Positioned(
      top: top,
      left: top,
      child: SizedBox(
        height: 44,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveValues.gapMedium(context),
            vertical: ResponsiveValues.gapSmall(context),
          ),
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
