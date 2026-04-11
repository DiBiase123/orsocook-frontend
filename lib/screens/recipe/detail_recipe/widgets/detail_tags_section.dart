import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/responsive_values.dart';

class DetailTagsSection extends StatelessWidget {
  final Recipe recipe;

  const DetailTagsSection({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    if (recipe.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveValues.gapLarge(context)),
        Text(
          'Tag',
          style: TextStyle(
            fontSize: ResponsiveValues.titleSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveValues.gapMedium(context)),
        Wrap(
          spacing: ResponsiveValues.gapSmall(context),
          runSpacing: ResponsiveValues.gapSmall(context),
          children: recipe.tags.map((tag) {
            return Chip(
              label: Text(
                tag.name,
                style: TextStyle(
                  fontSize: ResponsiveValues.bodySize(context),
                ),
              ),
              backgroundColor: colorScheme.tertiaryContainer,
              side: BorderSide(color: colorScheme.tertiary),
              labelStyle: TextStyle(
                color: colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
