import 'package:flutter/material.dart';
import 'package:orsocook/utils/responsive_utils.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        ResponsiveValues.gapLarge(context),
        ResponsiveValues.gapLarge(context),
        ResponsiveValues.gapLarge(context),
        ResponsiveValues.gapLarge(context),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'OrsoCook',
                style: TextStyle(
                  fontSize: ResponsiveValues.titleSize(context),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          Text(
            'Le migliori ricette,\ndalla tua cucina alla tavola',
            style: TextStyle(
              fontSize: ResponsiveValues.titleSize(context),
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          SizedBox(height: ResponsiveValues.gapSmall(context)),
          Text(
            'Scopri, crea e condividi',
            style: TextStyle(
              fontSize: ResponsiveValues.bodySize(context),
              color: Colors.white.withAlpha(230),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
