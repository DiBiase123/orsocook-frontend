import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/responsive_values.dart';

class DetailIngredientsSection extends StatelessWidget {
  final Recipe recipe;

  const DetailIngredientsSection({super.key, required this.recipe});

  String _formatIngredient(Ingredient ingredient) {
    final buffer = StringBuffer();

    if (ingredient.quantity != null && ingredient.quantity!.isNotEmpty) {
      buffer.write(ingredient.quantity);
    }

    if (ingredient.unit != null && ingredient.unit!.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(ingredient.unit);
    }

    if (buffer.isNotEmpty) buffer.write(' ');
    buffer.write(ingredient.name);

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingredienti',
          style: TextStyle(
            fontSize: ResponsiveValues.titleSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: ResponsiveValues.gapMedium(context)),
        ...recipe.ingredients.map((ingredient) => Padding(
              padding:
                  EdgeInsets.only(bottom: ResponsiveValues.gapSmall(context)),
              child: Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatIngredient(ingredient),
                      style: TextStyle(
                        fontSize: ResponsiveValues.bodySize(context),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
