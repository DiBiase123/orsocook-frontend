import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';

class DetailHeaderSection extends StatelessWidget {
  final Recipe recipe;

  const DetailHeaderSection({super.key, required this.recipe});

  String _getAuthorDisplayName() {
    // Prova displayName se non è null e non è vuoto
    if (recipe.author.displayName != null &&
        recipe.author.displayName!.isNotEmpty) {
      return recipe.author.displayName!;
    }

    // Altrimenti prova username (non nullable)
    if (recipe.author.username.isNotEmpty) {
      return recipe.author.username;
    }

    // Fallback
    return 'Autore sconosciuto';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titolo
        Text(
          recipe.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // Autore e categoria
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
        const SizedBox(height: 16),

        // Descrizione (se presente)
        if (recipe.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              recipe.description,
              style: const TextStyle(fontSize: 16),
            ),
          ),
      ],
    );
  }
}
