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

  static const String _prefKeySelectedCategory = 'selected_category';

  // Getters
  String? get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get isLoadingFilters => _isLoadingFilters;
  bool get isFirstLoad => _isFirstLoad;
  List<Recipe> get recipes => _recipeService.cachedRecipes;
  bool get isRecipesLoading => _recipeService.isLoading;

  HomeViewModel({
    required RecipeService recipeService,
    required LikeService likeService,
    required CategoryService categoryService,
  })  : _recipeService = recipeService,
        _likeService = likeService,
        _categoryService = categoryService {
    _loadSavedCategory();
  }

  // ========== CATEGORIA SALVATA ==========
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

  // ========== CARICAMENTO INIZIALE ==========
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

      _isFirstLoad = false;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Errore caricamento ricette iniziali', e);
      _isFirstLoad = false;
      notifyListeners();
    }
  }

  Future<void> _checkAndResetEmptyCategory() async {
    if (_recipeService.cachedRecipes.isEmpty && _selectedCategory != null) {
      AppLogger.debug(
          'Nessuna ricetta per categoria $_selectedCategory, reset a Tutte');

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

  // ========== FILTRI ==========
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
    } catch (e) {
      AppLogger.error('Errore nel caricamento filtri', e);
    } finally {
      _isLoadingFilters = false;
      notifyListeners();
    }
  }

  // ========== UTILITY ==========
  void disposeViewModel() {
    _searchDebounce?.cancel();
  }

  bool shouldShowLoading(bool recipesEmpty) {
    return _isFirstLoad || (_recipeService.isLoading && recipesEmpty);
  }
}
