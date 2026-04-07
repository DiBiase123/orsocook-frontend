import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/utils/responsive_values.dart';

class EmptyState extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback onRetry;
  final VoidCallback onCreateRecipe;

  const EmptyState({
    super.key,
    this.searchQuery,
    required this.onRetry,
    required this.onCreateRecipe,
  });

  @override
  Widget build(BuildContext context) {
    final recipeService = Provider.of<RecipeService>(context);

    if (recipeService.isLoading) {
      return const _LoadingState();
    }

    if (recipeService.lastError != null) {
      return _ErrorState(
        error: recipeService.lastError!,
        onRetry: onRetry,
      );
    }

    if (searchQuery?.isNotEmpty == true) {
      return _EmptySearchState(searchQuery: searchQuery!);
    }

    return _EmptyDefaultState(onCreateRecipe: onCreateRecipe);
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          const Text('Caricamento ricette...'),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          const Text(
            'Errore nel caricamento',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: ResponsiveValues.gapSmall(context)),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          SizedBox(height: ResponsiveValues.gapLarge(context)),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(120, ResponsiveValues.buttonHeight(context)),
            ),
            child: const Text('RIPROVA'),
          ),
        ],
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  final String searchQuery;

  const _EmptySearchState({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          const Text(
            'Nessuna ricetta trovata',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: ResponsiveValues.gapSmall(context)),
          Text(
            'Nessun risultato per "$searchQuery"',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _EmptyDefaultState extends StatelessWidget {
  final VoidCallback onCreateRecipe;

  const _EmptyDefaultState({required this.onCreateRecipe});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
          SizedBox(height: ResponsiveValues.gapMedium(context)),
          const Text(
            'Nessuna ricetta disponibile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: ResponsiveValues.gapSmall(context)),
          const Text(
            'Sii il primo a creare una ricetta!',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: ResponsiveValues.gapLarge(context)),
          ElevatedButton(
            onPressed: onCreateRecipe,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(200, ResponsiveValues.buttonHeight(context)),
            ),
            child: const Text('CREA LA TUA PRIMA RICETTA'),
          ),
        ],
      ),
    );
  }
}
