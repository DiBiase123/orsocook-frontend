import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/responsive_values.dart';
import 'package:orsocook/screens/home/widgets/carousel/carousel_card.dart';
import 'package:orsocook/screens/home/widgets/carousel/carousel_previous_button.dart';
import 'package:orsocook/screens/home/widgets/carousel/carousel_next_button.dart';

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
    final carouselHeight = screenHeight - 100;

    return SizedBox(
      height: carouselHeight,
      child: Stack(
        children: [
          CarouselSlider(
            carouselController: _carouselController,
            options: CarouselOptions(
              height: carouselHeight,
              viewportFraction: 1.0, // 👈 NESSUN PEEK, solo blocco centrale
              enlargeCenterPage: false,
              enableInfiniteScroll: true,
              autoPlay: false,
            ),
            items: widget.recipes.map((recipe) {
              return _buildCardWithPeek(recipe, context);
            }).toList(),
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

  Widget _buildCardWithPeek(Recipe recipe, BuildContext context) {
    final index = widget.recipes.indexOf(recipe);
    final nextIndex = (index + 1) % widget.recipes.length;
    final nextNextIndex = (index + 2) % widget.recipes.length;

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: ResponsiveValues.gapSmall(context)),
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
                    () => widget.onRecipeTap(widget.recipes[nextIndex]),
                    context,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: CarouselCard.buildSmallCard(
                    widget.recipes[nextNextIndex],
                    () => widget.onRecipeTap(widget.recipes[nextNextIndex]),
                    context,
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
