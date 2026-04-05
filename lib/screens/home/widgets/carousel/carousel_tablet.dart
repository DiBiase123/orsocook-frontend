import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:orsocook/models/recipe.dart';
import 'carousel_card.dart';
import 'carousel_previous_button.dart';
import 'carousel_next_button.dart';

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 1.0,
      initialPage: 1000,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final carouselHeight = screenHeight - 80;

    return SizedBox(
      height: carouselHeight,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: 1000000,
            scrollDirection: Axis.horizontal,
            physics: const AlwaysScrollableScrollPhysics(),
            dragStartBehavior: DragStartBehavior.down,
            itemBuilder: (context, index) {
              final realIndex = index % widget.recipes.length;
              final recipe = widget.recipes[realIndex];
              final nextIndex = (realIndex + 1) % widget.recipes.length;
              final nextNextIndex = (realIndex + 2) % widget.recipes.length;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 12,
                      child: CarouselCard.buildMainCard(
                        recipe,
                        () => widget.onRecipeTap(recipe),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          Expanded(
                            child: CarouselCard.buildSmallCard(
                              widget.recipes[nextIndex],
                              () =>
                                  widget.onRecipeTap(widget.recipes[nextIndex]),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: CarouselCard.buildSmallCard(
                              widget.recipes[nextNextIndex],
                              () => widget
                                  .onRecipeTap(widget.recipes[nextNextIndex]),
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
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: CarouselPreviousButton(
                onTap: _previousPage,
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: CarouselNextButton(
                onTap: _nextPage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
