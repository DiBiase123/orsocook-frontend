import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/widgets/recipe_card.dart';
import 'package:orsocook/utils/responsive_values.dart';

class CategorySectionTablet extends StatelessWidget {
  final String title;
  final String categorySlug;
  final List<Recipe> recipes;
  final VoidCallback? onSeeAllTap;
  final Color categoryColor;

  const CategorySectionTablet({
    super.key,
    required this.title,
    required this.categorySlug,
    required this.recipes,
    this.onSeeAllTap,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = 240.0;
    final cardHeight = 300.0;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveValues.gapExtraLarge(context),
        vertical: ResponsiveValues.gapMedium(context),
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer, // 👈 cambiato
        borderRadius: BorderRadius.circular(20),
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
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveValues.gapLarge(context),
              vertical: ResponsiveValues.gapMedium(context),
            ),
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: ResponsiveValues.titleSize(context),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveValues.gapMedium(context),
                        vertical: ResponsiveValues.gapSmall(context),
                      ),
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
          SizedBox(height: ResponsiveValues.gapLarge(context)),
          SizedBox(
            height: cardHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const AlwaysScrollableScrollPhysics(),
              dragStartBehavior: DragStartBehavior.down,
              padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveValues.gapMedium(context)),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Container(
                  width: cardWidth,
                  margin: EdgeInsets.only(
                      right: ResponsiveValues.gapLarge(context)),
                  child: RecipeCard(
                    recipe: recipe,
                    onTap: () => context.push('/recipe/detail/${recipe.id}',
                        extra: recipe),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: ResponsiveValues.gapLarge(context)),
        ],
      ),
    );
  }
}
