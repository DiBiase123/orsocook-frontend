import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/utils/logger.dart';

class CategoryRecipesViewModel extends ChangeNotifier {
  final RecipeService _recipeService;
  final String categorySlug;
  String categoryName = '';

  List<Recipe> _recipes = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  CategoryRecipesViewModel({
    required RecipeService recipeService,
    required this.categorySlug,
  }) : _recipeService = recipeService {
    loadCategoryRecipes();
  }

  Future<void> loadCategoryRecipes({bool refresh = false}) async {
    if (_isLoading) return;
    if (!refresh && !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (refresh) {
        _currentPage = 1;
        _recipes.clear();
        _hasMore = true;
      }

      final result = await _recipeService.fetchRecipesByCategory(
        categorySlug: categorySlug,
        page: _currentPage,
        limit: 12,
      );

      if (refresh) {
        _recipes = result.recipes;
      } else {
        _recipes.addAll(result.recipes);
      }

      _hasMore = result.hasMore;
      _currentPage++;

      // Salva il nome della categoria dalla prima ricetta
      if (result.recipes.isNotEmpty && categoryName.isEmpty) {
        final firstRecipe = result.recipes.first;
        categoryName = firstRecipe.category?.name ?? categorySlug;
      }

      notifyListeners();
    } catch (e) {
      _error = 'Errore nel caricamento: $e';
      AppLogger.error('Errore caricamento ricette categoria', e);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_hasMore && !_isLoading) {
      await loadCategoryRecipes();
    }
  }

  void disposeViewModel() {
    // Cleanup if needed
  }
}
