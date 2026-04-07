import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/responsive_values.dart';
import 'package:orsocook/screens/home/widgets/carousel/carousel_card.dart';

class CarouselMobile extends StatefulWidget {
  final List<Recipe> recipes;
  final Function(Recipe) onRecipeTap;

  const CarouselMobile({
    super.key,
    required this.recipes,
    required this.onRecipeTap,
  });

  @override
  State<CarouselMobile> createState() => _CarouselMobileState();
}

class _CarouselMobileState extends State<CarouselMobile> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSingleCard = widget.recipes.length == 1;

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.recipes.length,
            itemBuilder: (context, index) {
              return CarouselCard.buildMainCardFullWidth(
                widget.recipes[index],
                () => widget.onRecipeTap(widget.recipes[index]),
                context,
              );
            },
          ),
        ),
        if (!isSingleCard) _buildDots(context),
      ],
    );
  }

  Widget _buildDots(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: ResponsiveValues.gapLarge(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.recipes.length,
          (index) => MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _currentIndex == index ? 36 : 14,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _currentIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.withAlpha(150),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
