import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/widgets/recipe_card.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CategorySection extends StatelessWidget {
  final String title;
  final String categorySlug;
  final List<Recipe> recipes;
  final VoidCallback? onSeeAllTap;

  const CategorySection({
    super.key,
    required this.title,
    required this.categorySlug,
    required this.recipes,
    this.onSeeAllTap,
  });

  Color _getCategoryColor(String slug) {
    final colors = {
      'antipasti': const Color(0xFF7B1FA2),
      'primi-piatti': const Color(0xFF9C27B0),
      'secondi-piatti': const Color(0xFFAB47BC),
      'contorni': const Color(0xFFBA68C8),
      'dolci': const Color(0xFFCE93D8),
      'pane-e-pizza': const Color(0xFF8E24AA),
      'zuppe-e-minestre': const Color(0xFF6A1B9A),
      'insalate': const Color(0xFFB39DDB),
      'salse-e-condimenti': const Color(0xFF9575CD),
      'bevande': const Color(0xFF7E57C2),
      'colazioni-e-brunch': const Color(0xFF673AB7),
      'piatti-unici': const Color(0xFF5E35B1),
    };
    return colors[slug] ?? const Color(0xFF6750A4);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth >= 768 && screenWidth <= 1200;
    final enableInfinite = recipes.length >= 3;

    if (recipes.isEmpty) return const SizedBox.shrink();

    double cardWidth;
    double cardHeight;
    double viewportFraction;
    double horizontalMargin;

    if (isDesktop) {
      cardWidth = 280;
      cardHeight = 320;
      viewportFraction = 0.3;
      horizontalMargin = 96;
    } else if (isTablet) {
      cardWidth = 260;
      cardHeight = 300;
      viewportFraction = 0.5;
      horizontalMargin = 64;
    } else {
      cardWidth = 220;
      cardHeight = 260;
      viewportFraction = 0.8;
      horizontalMargin = 40;
    }

    final categoryColor = _getCategoryColor(categorySlug);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isDesktop ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextButton(
                    onPressed: onSeeAllTap ??
                        () => context.push('/category/$categorySlug'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: const Row(
                      children: [
                        Text('Vedi tutte',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: CarouselSlider(
              options: CarouselOptions(
                height: cardHeight,
                viewportFraction: viewportFraction,
                enlargeCenterPage: false,
                enableInfiniteScroll: enableInfinite,
                autoPlay: false,
              ),
              items: recipes.map((recipe) {
                return Container(
                  width: cardWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: RecipeCard(
                    recipe: recipe,
                    onTap: () => context.push('/recipe/detail/${recipe.id}',
                        extra: recipe),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
