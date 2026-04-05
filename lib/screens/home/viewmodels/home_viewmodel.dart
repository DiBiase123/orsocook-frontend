import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/recipe_service.dart';
import 'package:orsocook/services/like_service.dart';
import 'package:orsocook/services/category_service.dart';
import 'package:orsocook/utils/logger.dart';

class HomeViewModel extends ChangeNotifier {
  final RecipeService _recipeService;
  final LikeService _likeService;
  final CategoryService _categoryService;

  String? _searchQuery;
  String? _selectedCategory;
  bool _isLoadingFilters = false;
  bool _isFirstLoad = true;
  Timer? _searchDebounce;
  final Map<String, List<Recipe>> _sectionRecipes = {};
  bool _isLoadingSections = false;

  int _loadRetryCount = 0;
  static const int _maxRetries = 3;

  static const String _prefKeySelectedCategory = 'selected_category';

  // Getters
  String? get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get isLoadingFilters => _isLoadingFilters;
  bool get isFirstLoad => _isFirstLoad;
  List<Recipe> get recipes => _recipeService.cachedRecipes;
  bool get isRecipesLoading => _recipeService.isLoading;
  List<CategoryModel> get categories => _categoryService.categories;
  Map<String, List<Recipe>> get sectionRecipes => _sectionRecipes;
  bool get isLoadingSections => _isLoadingSections;
  bool get hasActiveFilter =>
      _selectedCategory != null ||
      (_searchQuery != null && _searchQuery!.isNotEmpty);

  HomeViewModel({
    required RecipeService recipeService,
    required LikeService likeService,
    required CategoryService categoryService,
  })  : _recipeService = recipeService,
        _likeService = likeService,
        _categoryService = categoryService {
    _loadSavedCategory();
  }

  Future<void> _loadSavedCategory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCategory = prefs.getString(_prefKeySelectedCategory);
      if (savedCategory != null && savedCategory.isNotEmpty) {
        _selectedCategory = savedCategory;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('Errore nel caricamento categoria salvata', e);
    }
  }

  Future<void> saveCategoryPreference(String? categorySlug) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (categorySlug == null) {
        await prefs.remove(_prefKeySelectedCategory);
      } else {
        await prefs.setString(_prefKeySelectedCategory, categorySlug);
      }
    } catch (e) {
      AppLogger.error('Errore nel salvare categoria', e);
    }
  }

  Future<void> loadInitialRecipes() async {
    try {
      if (_categoryService.categories.isEmpty) {
        await _categoryService.fetchCategories(forceRefresh: false);
      }

      await _recipeService.fetchRecipes(
        forceRefresh: true,
        page: 1,
        category: _selectedCategory,
      );

      await _checkAndResetEmptyCategory();

      final recipeIds = _recipeService.cachedRecipes.map((r) => r.id).toList();
      _likeService.preloadLikesCount(recipeIds);
      await _loadSections();

      if (_recipeService.cachedRecipes.isEmpty &&
          _loadRetryCount < _maxRetries) {
        _loadRetryCount++;
        AppLogger.debug(
            '🔄 Ricette vuote, tentativo $_loadRetryCount di $_maxRetries');
        await Future.delayed(Duration(seconds: _loadRetryCount));
        await loadInitialRecipes();
        return;
      }

      _loadRetryCount = 0;
      _isFirstLoad = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Errore caricamento ricette iniziali', e);

      if (_loadRetryCount < _maxRetries) {
        _loadRetryCount++;
        AppLogger.debug(
            '🔄 Errore, tentativo $_loadRetryCount di $_maxRetries');
        await Future.delayed(Duration(seconds: _loadRetryCount));
        await loadInitialRecipes();
        return;
      }

      _loadRetryCount = 0;
      _isFirstLoad = false;
      notifyListeners();
    }
  }

  Future<void> _loadSections() async {
    if (_isLoadingSections) return;

    _isLoadingSections = true;
    notifyListeners();

    try {
      _sectionRecipes.clear();

      for (final category in _categoryService.categories) {
        try {
          final result = await _recipeService.fetchRecipesByCategory(
            categorySlug: category.slug,
            page: 1,
            limit: 6,
          );

          if (result.recipes.isNotEmpty) {
            _sectionRecipes[category.slug] = result.recipes;
          }
        } catch (e) {
          AppLogger.error('Errore caricamento sezione ${category.name}', e);
        }
      }
    } finally {
      _isLoadingSections = false;
      notifyListeners();
    }
  }

  Future<void> refreshSections() async {
    if (hasActiveFilter) {
      if (_sectionRecipes.isNotEmpty) {
        _sectionRecipes.clear();
        notifyListeners();
      }
      return;
    }
    await _loadSections();
  }

  Future<void> _checkAndResetEmptyCategory() async {
    if (_recipeService.cachedRecipes.isEmpty && _selectedCategory != null) {
      _selectedCategory = null;
      await saveCategoryPreference(null);
      await _recipeService.fetchRecipes(
        forceRefresh: true,
        page: 1,
        category: null,
      );
      notifyListeners();
    }
  }

  void onCategorySelected(String? categorySlug) {
    final effectiveSlug = categorySlug?.isEmpty == true ? null : categorySlug;
    if (_selectedCategory == effectiveSlug) return;

    _selectedCategory = effectiveSlug;
    notifyListeners();
    saveCategoryPreference(effectiveSlug);
    loadRecipesWithFilters();
  }

  void onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchQuery = query.isEmpty ? null : query;
    notifyListeners();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      loadRecipesWithFilters();
    });
  }

  Future<void> loadRecipesWithFilters() async {
    if (_isLoadingFilters) return;

    _isLoadingFilters = true;
    notifyListeners();

    try {
      await _recipeService.fetchRecipes(
        forceRefresh: true,
        page: 1,
        category: _selectedCategory,
        search: _searchQuery,
      );

      final recipeIds = _recipeService.cachedRecipes.map((r) => r.id).toList();
      _likeService.preloadLikesCount(recipeIds);
      await refreshSections();
    } catch (e) {
      AppLogger.error('Errore nel caricamento filtri', e);
    } finally {
      _isLoadingFilters = false;
      notifyListeners();
    }
  }

  void disposeViewModel() {
    _searchDebounce?.cancel();
  }

  bool shouldShowLoading(bool recipesEmpty) {
    return _isFirstLoad || (_recipeService.isLoading && recipesEmpty);
  }
}
