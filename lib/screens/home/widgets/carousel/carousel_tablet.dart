import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/responsive_values.dart';
import 'package:orsocook/screens/home/widgets/carousel/carousel_card.dart';

class CarouselTablet extends StatefulWidget {
  final List<Recipe> recipes;
  final Function(Recipe) onRecipeTap;

  const CarouselTablet({
    super.key,
    required this.recipes,
    required this.onRecipeTap,
  });

  @override
  State<CarouselTablet> createState() => _CarouselTabletState();
}

class _CarouselTabletState extends State<CarouselTablet> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
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
              final recipe = widget.recipes[index];
              final nextIndex = (index + 1) % widget.recipes.length;
              final nextNextIndex = (index + 2) % widget.recipes.length;

              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveValues.gapSmall(context)),
                child: Row(
                  children: [
                    Expanded(
                      flex: 12,
                      child: CarouselCard.buildMainCard(
                        recipe,
                        () => widget.onRecipeTap(recipe),
                        context,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          Expanded(
                            child: CarouselCard.buildSmallCard(
                              widget.recipes[nextIndex],
                              () =>
                                  widget.onRecipeTap(widget.recipes[nextIndex]),
                              context,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: CarouselCard.buildSmallCard(
                              widget.recipes[nextNextIndex],
                              () => widget
                                  .onRecipeTap(widget.recipes[nextNextIndex]),
                              context,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
          (index) => GestureDetector(
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
    );
  }
}
