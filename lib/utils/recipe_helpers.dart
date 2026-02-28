import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';

class RecipeHelpers {
  /// Estrae l'ID autore dall'oggetto author (può essere UserAuthor, Map o String)
  static String? extractAuthorId(dynamic author) {
    if (author == null) return null;

    // CASO 1: Se è UserAuthor
    if (author is UserAuthor) {
      return author.id;
    }

    // CASO 2: Se è Map (vecchio formato)
    if (author is Map<String, dynamic>) {
      if (author.isEmpty) return null;

      const possibleKeys = ['id', 'userId', '_id', 'authorId', 'user_id'];

      for (final key in possibleKeys) {
        final value = author[key];
        if (value != null && value.toString().isNotEmpty) {
          return value.toString();
        }
      }

      if (author.containsKey('user') && author['user'] is Map) {
        final userMap = author['user'] as Map<String, dynamic>;
        for (final key in possibleKeys) {
          final value = userMap[key];
          if (value != null && value.toString().isNotEmpty) {
            return value.toString();
          }
        }
      }
    }

    // CASO 3: Se è già una stringa (direttamente l'ID)
    if (author is String) {
      return author;
    }

    return null;
  }

  /// Converte i tag in lista di stringhe (nomi dei tag)
  static List<String> tagNames(List<Tag>? tags) {
    if (tags == null || tags.isEmpty) return [];
    return tags.map((tag) => tag.name).toList();
  }

  /// Aggiorna una ricetta con nuovi valori (like count, favorite)
  static Recipe updateRecipeWithExtras(
    Recipe original, {
    int? likeCount,
    bool? isFavorite,
  }) {
    return original.copyWith(
      likeCount: likeCount ?? original.likeCount,
      isFavorite: isFavorite ?? original.isFavorite,
    );
  }

  /// Formatta il tempo di preparazione in formato leggibile
  static String formatPrepTime(int? minutes) {
    if (minutes == null || minutes <= 0) return 'Non specificato';

    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours h';
      } else {
        return '$hours h $remainingMinutes min';
      }
    }
  }

  /// Formatta la difficoltà con icona e colore
  static ({String label, IconData icon, Color color}) getDifficultyData(
    String? difficulty,
  ) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return (
          label: 'Facile',
          icon: Icons.sentiment_satisfied,
          color: Colors.green,
        );
      case 'medium':
        return (
          label: 'Media',
          icon: Icons.sentiment_neutral,
          color: Colors.orange,
        );
      case 'hard':
        return (
          label: 'Difficile',
          icon: Icons.sentiment_dissatisfied,
          color: Colors.red,
        );
      default:
        return (
          label: difficulty ?? 'Non specificato',
          icon: Icons.help_outline,
          color: Colors.grey,
        );
    }
  }

  /// Valida gli ingredienti (assicura che non siano vuoti)
  static bool validateIngredients(List<Ingredient>? ingredients) {
    if (ingredients == null || ingredients.isEmpty) return false;
    return ingredients.every((ing) => ing.name.trim().isNotEmpty);
  }

  /// Valida le istruzioni (assicura che non siano vuote)
  static bool validateInstructions(List<Instruction>? instructions) {
    if (instructions == null || instructions.isEmpty) return false;
    return instructions.every((step) => step.description.trim().isNotEmpty);
  }

  /// Tronca il testo alla lunghezza specificata
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Estrae i tag unici da una lista di ricette (come stringhe)
  static Set<String> extractUniqueTagNames(List<Recipe> recipes) {
    final tags = <String>{};
    for (final recipe in recipes) {
      tags.addAll(tagNames(recipe.tags));
    }
    return tags;
  }

  /// Filtra le ricette per tag (cerca nel nome del tag)
  static List<Recipe> filterByTagName(List<Recipe> recipes, String? tagName) {
    if (tagName == null || tagName.isEmpty) return recipes;
    return recipes.where((recipe) {
      return recipe.tags.any((tag) => tag.name == tagName);
    }).toList();
  }

  /// Cerca ricette per titolo o ingredienti
  static List<Recipe> searchRecipes(
    List<Recipe> recipes,
    String query, {
    bool searchIngredients = false,
  }) {
    if (query.isEmpty) return recipes;

    final lowerQuery = query.toLowerCase();
    return recipes.where((recipe) {
      // Cerca nel titolo
      if (recipe.title.toLowerCase().contains(lowerQuery)) return true;

      // Cerca nella descrizione
      if (recipe.description.toLowerCase().contains(lowerQuery)) return true;

      // Cerca negli ingredienti (opzionale)
      if (searchIngredients) {
        for (final ingredient in recipe.ingredients) {
          if (ingredient.name.toLowerCase().contains(lowerQuery)) {
            return true;
          }
        }
      }

      return false;
    }).toList();
  }
}
