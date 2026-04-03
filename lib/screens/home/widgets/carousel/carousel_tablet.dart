import 'package:flutter/material.dart';
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

  void _nextPage() {
    if (_currentIndex < widget.recipes.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
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
          // Freccia sinistra
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Opacity(
                opacity: _currentIndex == 0 ? 0.3 : 1.0,
                child: CarouselPreviousButton(
                  onTap: _currentIndex > 0 ? _previousPage : () {},
                ),
              ),
            ),
          ),
          // Freccia destra
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: Opacity(
                opacity: _currentIndex == widget.recipes.length - 1 ? 0.3 : 1.0,
                child: CarouselNextButton(
                  onTap: _currentIndex < widget.recipes.length - 1
                      ? _nextPage
                      : () {},
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
