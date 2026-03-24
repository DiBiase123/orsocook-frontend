import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:orsocook/models/recipe.dart';
import 'carousel_card.dart';
import 'carousel_previous_button.dart';
import 'carousel_next_button.dart';

class CarouselDesktop extends StatefulWidget {
  final List<Recipe> recipes;
  final Function(Recipe) onRecipeTap;

  const CarouselDesktop({
    super.key,
    required this.recipes,
    required this.onRecipeTap,
  });

  @override
  State<CarouselDesktop> createState() => _CarouselDesktopState();
}

class _CarouselDesktopState extends State<CarouselDesktop> {
  late CarouselSliderController _carouselController;

  @override
  void initState() {
    super.initState();
    _carouselController = CarouselSliderController();
  }

  void _nextPage() {
    _carouselController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _carouselController.previousPage(
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
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              height: carouselHeight,
              viewportFraction: 0.6,
              enlargeCenterPage: true,
              enlargeFactor: 0.25,
              enableInfiniteScroll: true,
              autoPlay: false,
            ),
            items: widget.recipes.map((recipe) {
              return _buildCardWithPeek(recipe);
            }).toList(),
          ),
          // Freccia sinistra
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
          // Freccia destra
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

  Widget _buildCardWithPeek(Recipe recipe) {
    final index = widget.recipes.indexOf(recipe);
    final nextIndex = (index + 1) % widget.recipes.length;
    final nextNextIndex = (index + 2) % widget.recipes.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // Card grande (60%)
          Expanded(
            flex: 12,
            child: CarouselCard.buildMainCard(
              recipe,
              () => widget.onRecipeTap(recipe),
            ),
          ),
          const SizedBox(width: 24), // Aumentato da 16 a 24
          // Card piccole impilate (40%)
          Expanded(
            flex: 8,
            child: Column(
              children: [
                Expanded(
                  child: CarouselCard.buildSmallCard(
                    widget.recipes[nextIndex],
                    () => widget.onRecipeTap(widget.recipes[nextIndex]),
                  ),
                ),
                const SizedBox(height: 24), // Aumentato da 16 a 24
                Expanded(
                  child: CarouselCard.buildSmallCard(
                    widget.recipes[nextNextIndex],
                    () => widget.onRecipeTap(widget.recipes[nextNextIndex]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
