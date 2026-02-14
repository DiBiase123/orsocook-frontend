import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo sezione
        const Text(
          'Ingredienti',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Lista ingredienti
        ...recipe.ingredients.map((ingredient) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formatIngredient(ingredient),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
