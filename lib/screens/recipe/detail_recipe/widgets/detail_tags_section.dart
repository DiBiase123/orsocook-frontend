import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';

class DetailTagsSection extends StatelessWidget {
  final Recipe recipe;

  const DetailTagsSection({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    if (recipe.tags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Tag',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recipe.tags.map((tag) {
            return Chip(
              label: Text(
                tag.name, // 👈 DIRETTAMENTE tag.name
                style: const TextStyle(fontSize: 14),
              ),
              backgroundColor: Colors.orange[50],
              side: BorderSide(color: Colors.orange[300]!),
              labelStyle: TextStyle(
                color: Colors.orange[900],
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
