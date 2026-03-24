import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/config.dart';
import 'package:orsocook/services/category_service.dart';

// ==================== CLASSE RISULTATO PER CATEGORIA ====================
class CategoryRecipesResult {
  final List<Recipe> recipes;
  final bool hasMore;
  final int total;

  CategoryRecipesResult({
    required this.recipes,
    required this.hasMore,
    required this.total,
  });
}

class RecipeService extends ChangeNotifier {
  final Dio _dio = Dio();
  final AuthService _authService;
  final CategoryService _categoryService;

  List<Recipe> _cachedRecipes = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _lastError;

  static const int _pageLimit = 10;

  RecipeService(this._authService, this._categoryService) {
    _dio.options.baseUrl = Config.buildUrl('');
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.validateStatus = (status) => status != null && status < 500;
  }

  // Getters
  List<Recipe> get cachedRecipes => _cachedRecipes;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get lastError => _lastError;

  // ==================== AUTH HEADERS ====================
  Future<Map<String, String>> _getAuthHeaders() =>
      _authService.getAuthHeaders();

  // ==================== FETCH RECIPES ====================
  Future<List<Recipe>> fetchRecipes({
    bool forceRefresh = false,
    int page = 1,
    String? category,
    String? search,
  }) async {
    if (_isLoading && !forceRefresh) return _cachedRecipes;

    _setLoading(true);

    try {
      final queryParams = {
        'page': page,
        'limit': _pageLimit,
        if (category?.isNotEmpty == true) 'category': category,
        if (search?.isNotEmpty == true) 'search': search,
      };

      final response = await _dio.get(
        '/api/recipes',
        queryParameters: queryParams,
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Errore sconosciuto');
      }

      final recipes = _parseRecipes(response.data['data']);
      _updateCache(recipes, forceRefresh, page);
    } catch (e) {
      _lastError = e.toString();
      AppLogger.error('fetchRecipes error', e);
    } finally {
      _setLoading(false);
    }

    return _cachedRecipes;
  }

  // ==================== FETCH RECIPES BY CATEGORY ====================
  Future<CategoryRecipesResult> fetchRecipesByCategory({
    required String categorySlug,
    int page = 1,
    int limit = 12,
  }) async {
    try {
      final response = await _dio.get(
        '/api/recipes',
        queryParameters: {
          'category': categorySlug,
          'page': page,
          'limit': limit,
        },
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final recipes = (data['recipes'] as List)
            .map((json) => Recipe.fromJson(Map<String, dynamic>.from(json)))
            .toList();

        return CategoryRecipesResult(
          recipes: recipes,
          hasMore: data['hasMore'] ?? false,
          total: data['total'] ?? 0,
        );
      } else {
        throw Exception(response.data['message'] ??
            'Errore caricamento ricette per categoria');
      }
    } catch (e) {
      AppLogger.error('fetchRecipesByCategory error', e);
      throw Exception('Impossibile caricare le ricette: $e');
    }
  }

  List<Recipe> _parseRecipes(dynamic data) {
    final List<dynamic> recipesData = _extractRecipesData(data);

    return recipesData
        .map((json) => Recipe.fromJson(Map<String, dynamic>.from(json)))
        .whereType<Recipe>()
        .toList();
  }

  List<dynamic> _extractRecipesData(dynamic data) {
    if (data is Map) {
      if (data.containsKey('recipes')) return data['recipes'] as List;
      if (data.containsKey('data')) {
        final nested = data['data'];
        if (nested is Map && nested.containsKey('recipes')) {
          return nested['recipes'] as List;
        }
        if (nested is List) return nested;
      }
    } else if (data is List) {
      return data;
    }
    return [];
  }

  void _updateCache(List<Recipe> newRecipes, bool forceRefresh, int page) {
    final shouldReplace = forceRefresh || page == 1;

    if (shouldReplace) {
      _cachedRecipes = newRecipes;
    } else {
      _cachedRecipes.addAll(newRecipes);
    }

    _hasMore = newRecipes.length == _pageLimit;
    _currentPage = page;
  }

  // ==================== GET RECIPE BY ID ====================
  Future<Recipe?> getRecipeById(String id) async {
    // Cerca in cache
    try {
      return _cachedRecipes.firstWhere((r) => r.id == id);
    } catch (_) {
      // Non trovato, procedi con API
    }

    try {
      final response = await _dio.get(
        '/api/recipes/$id',
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.data['success'] == true) {
        final recipe = Recipe.fromJson(response.data['data']);
        _cachedRecipes.add(recipe);
        _notify();
        return recipe;
      }
    } catch (e) {
      AppLogger.error('getRecipeById error', e);
    }

    return null;
  }

  // ==================== CREATE RECIPE ====================
  Future<Recipe?> createRecipe(Recipe recipe) async {
    try {
      final data = _prepareRecipeData(recipe);
      final response = await _dio.post(
        '/api/recipes',
        data: data,
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Errore creazione');
      }

      final newRecipe = Recipe.fromJson(response.data['data']);
      _cachedRecipes.insert(0, newRecipe);
      _notify();
      return newRecipe;
    } catch (e) {
      AppLogger.error('createRecipe error', e);
      return null;
    }
  }

  // ==================== UPDATE RECIPE ====================
  Future<Recipe?> updateRecipe(String id, Recipe recipe) async {
    try {
      final data = _prepareRecipeData(recipe);
      final response = await _dio.put(
        '/api/recipes/$id',
        data: data,
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Errore aggiornamento');
      }

      final updatedRecipe = Recipe.fromJson(response.data['data']);
      _updateCachedRecipe(id, updatedRecipe);
      return updatedRecipe;
    } catch (e) {
      AppLogger.error('updateRecipe error', e);
      return null;
    }
  }

  Map<String, dynamic> _prepareRecipeData(Recipe recipe) {
    final data = recipe.toJson();

    if (data['category'] is Map) {
      data['categoryId'] = data['category']['id'];
      data.remove('category');
    }

    return data;
  }

  void _updateCachedRecipe(String id, Recipe updatedRecipe) {
    final index = _cachedRecipes.indexWhere((r) => r.id == id);
    if (index != -1) {
      _cachedRecipes[index] = updatedRecipe;
      _notify();
    }
  }

  // ==================== DELETE RECIPE ====================
  Future<bool> deleteRecipe(String id) async {
    try {
      final response = await _dio.delete(
        '/api/recipes/$id',
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.data['success'] != true) return false;

      _cachedRecipes.removeWhere((recipe) => recipe.id == id);
      _notify();

      // Refresh categorie in background
      _categoryService.refreshCategories().catchError((e) {
        AppLogger.error('refreshCategories after delete error', e);
      });

      return true;
    } catch (e) {
      AppLogger.error('deleteRecipe error', e);
      return false;
    }
  }

  // ==================== REMOVE IMAGE ====================
  Future<bool> removeRecipeImage(String recipeId) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final token = authHeaders['Authorization']?.replaceFirst('Bearer ', '');

      if (token == null) return false;

      final response = await _dio.delete(
        '/api/recipes/$recipeId/remove-image',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data['success'] != true) return false;

      _updateRecipeImage(recipeId, '');
      return true;
    } catch (e) {
      AppLogger.error('removeRecipeImage error', e);
      return false;
    }
  }

  void _updateRecipeImage(String recipeId, String imageUrl) {
    final index = _cachedRecipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _cachedRecipes[index] =
          _cachedRecipes[index].copyWith(imageUrl: imageUrl);
      _notify();
    }
  }

  // ==================== LOAD MORE ====================
  Future<void> loadMoreRecipes() async {
    if (_isLoading || !_hasMore) return;
    await fetchRecipes(page: _currentPage + 1);
  }

  // ==================== UPDATE STATUS ====================
  void updateRecipeLikedStatus(String recipeId, bool isLiked) {
    _updateRecipeField(recipeId, (r) => r.copyWith(isFavorite: isLiked));
  }

  void updateRecipeCommentCount(String recipeId, int commentCount) {
    _updateRecipeField(recipeId, (r) => r.copyWith(commentCount: commentCount));
  }

  void _updateRecipeField(String recipeId, Recipe Function(Recipe) update) {
    AppLogger.debug('📝 [RECIPE] _updateRecipeField per $recipeId');
    final index = _cachedRecipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _cachedRecipes[index] = update(_cachedRecipes[index]);
      AppLogger.debug('✅ [RECIPE] Ricetta aggiornata, notifico');
      _notify();
    }
  }

  // ==================== UTILITY ====================
  void _setLoading(bool loading) {
    if (_isLoading == loading) return;
    _isLoading = loading;
    if (!loading) _lastError = null;
    _notify();
  }

  void _notify() {
    if (!hasListeners) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });
  }

  void clearCache() {
    _cachedRecipes.clear();
    _currentPage = 1;
    _hasMore = true;
    _notify();
  }

  void clearError() {
    _lastError = null;
    _notify();
  }
}
