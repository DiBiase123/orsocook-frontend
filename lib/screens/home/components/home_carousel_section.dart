import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/screens/home/widgets/carousel/index.dart';
import 'package:orsocook/utils/responsive_breakpoints.dart';

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
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);

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
