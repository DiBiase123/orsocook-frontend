import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/utils/responsive_values.dart';

class DetailHeaderSection extends StatelessWidget {
  final Recipe recipe;

  const DetailHeaderSection({super.key, required this.recipe});

  String _getAuthorDisplayName() {
    if (recipe.author.displayName != null &&
        recipe.author.displayName!.isNotEmpty) {
      return recipe.author.displayName!;
    }

    if (recipe.author.username.isNotEmpty) {
      return recipe.author.username;
    }

    return 'Autore sconosciuto';
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('DetailHeaderSection - category: ${recipe.category}');
    AppLogger.debug(
        'DetailHeaderSection - category name: ${recipe.category?.name}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.title,
          style: TextStyle(
            fontSize: ResponsiveValues.titleSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveValues.gapSmall(context)),
        Row(
          children: [
            const Icon(Icons.person, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              _getAuthorDisplayName(),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.category, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              recipe.category?.name ?? 'Senza categoria',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        SizedBox(height: ResponsiveValues.gapMedium(context)),
        if (recipe.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              recipe.description,
              style: TextStyle(fontSize: ResponsiveValues.bodySize(context)),
            ),
          ),
      ],
    );
  }
}
