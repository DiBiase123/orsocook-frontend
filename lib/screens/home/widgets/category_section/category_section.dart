import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/responsive_breakpoints.dart';
import 'category_section_mobile.dart';
import 'category_section_tablet.dart';
import 'category_section_desktop.dart';

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
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);
    final categoryColor = _getCategoryColor(categorySlug);

    if (recipes.isEmpty) return const SizedBox.shrink();

    if (isMobile) {
      return CategorySectionMobile(
        title: title,
        categorySlug: categorySlug,
        recipes: recipes,
        onSeeAllTap: onSeeAllTap,
        categoryColor: categoryColor,
      );
    } else if (isTablet) {
      return CategorySectionTablet(
        title: title,
        categorySlug: categorySlug,
        recipes: recipes,
        onSeeAllTap: onSeeAllTap,
        categoryColor: categoryColor,
      );
    } else {
      return CategorySectionDesktop(
        title: title,
        categorySlug: categorySlug,
        recipes: recipes,
        onSeeAllTap: onSeeAllTap,
        categoryColor: categoryColor,
      );
    }
  }
}
