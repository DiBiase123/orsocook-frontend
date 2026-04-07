import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:orsocook/utils/responsive_breakpoints.dart';
import 'package:orsocook/utils/responsive_values.dart';

class ShimmerEffect extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      period: duration,
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }
}

class ShimmerRecipeCard extends StatelessWidget {
  final double height;

  const ShimmerRecipeCard({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height * 0.6,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Container(height: 12, width: 100, color: Colors.grey.shade300),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                        height: 12, width: 60, color: Colors.grey.shade300),
                    const Spacer(),
                    Container(
                        height: 12, width: 40, color: Colors.grey.shade300),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerCarousel extends StatelessWidget {
  final bool isDesktop;

  const ShimmerCarousel({super.key, this.isDesktop = true});

  @override
  Widget build(BuildContext context) {
    final height = isDesktop ? 500.0 : 350.0;

    return ShimmerEffect(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(flex: 12, child: ShimmerRecipeCard(height: height)),
            if (isDesktop) ...[
              const SizedBox(width: 24),
              Expanded(
                flex: 8,
                child: Column(
                  children: [
                    Expanded(child: ShimmerRecipeCard(height: height / 2 - 12)),
                    const SizedBox(height: 24),
                    Expanded(child: ShimmerRecipeCard(height: height / 2 - 12)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ShimmerCategorySection extends StatelessWidget {
  final bool isDesktop;

  const ShimmerCategorySection({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    final cardWidth = isDesktop ? 280.0 : 220.0;
    final cardHeight = isDesktop ? 320.0 : 260.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveValues.gapMedium(context),
            vertical: ResponsiveValues.gapMedium(context),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 150, height: 24, color: Colors.grey.shade300),
              Container(width: 80, height: 20, color: Colors.grey.shade300),
            ],
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
                horizontal: ResponsiveValues.gapMedium(context)),
            itemCount: 4,
            itemBuilder: (_, __) => Container(
              width: cardWidth,
              margin: EdgeInsets.symmetric(
                  horizontal: ResponsiveValues.gapSmall(context)),
              child: ShimmerRecipeCard(height: cardHeight),
            ),
          ),
        ),
        SizedBox(height: ResponsiveValues.gapLarge(context)),
      ],
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int count;

  const ShimmerGrid({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);
    final crossAxisCount =
        isDesktop ? 4 : (ResponsiveBreakpoints.isTablet(context) ? 3 : 2);
    final spacing = ResponsiveValues.gapMedium(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: ResponsiveValues.screenPadding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 0.75,
      ),
      itemCount: count,
      itemBuilder: (_, __) => ShimmerRecipeCard(height: 280),
    );
  }
}
