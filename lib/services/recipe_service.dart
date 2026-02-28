import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/config.dart';

class RecipeService extends ChangeNotifier {
  final Dio _dio = Dio();
  final AuthService _authService;

  List<Recipe> _cachedRecipes = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _lastError;

  static const int _pageLimit = 10;

  RecipeService(this._authService) {
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
  // ==================== FETCH RECIPES ====================
  Future<List<Recipe>> fetchRecipes({
    bool forceRefresh = false,
    int page = 1,
    String? category,
  }) async {
    if (_isLoading && !forceRefresh) return _cachedRecipes;

    _setLoadingState(true);

    try {
      final Map<String, dynamic> queryParams = {
        'page': page,
        'limit': _pageLimit,
      };

      // 👇 CORRETTO: category è già String, nessun problema di tipo
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final response = await _dio.get(
        '/api/recipes',
        queryParameters: queryParams,
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Errore sconosciuto');
      }

      final List<Recipe> recipes = _parseRecipes(response.data['data']);

      _updateCache(recipes, forceRefresh, page);
      return _cachedRecipes;
    } catch (e) {
      _lastError = e.toString();
      return _cachedRecipes;
    } finally {
      _setLoadingState(false);
    }
  }

  // ==================== PARSE RECIPES ====================
  List<Recipe> _parseRecipes(dynamic data) {
    final List<dynamic> recipesData = _extractRecipesData(data);

    return recipesData
        .whereType<Map>()
        .map((json) {
          try {
            return Recipe.fromJson(Map<String, dynamic>.from(json));
          } catch (e) {
            AppLogger.error('Errore conversione ricetta', e);
            return null;
          }
        })
        .whereType<Recipe>()
        .toList();
  }

  List<dynamic> _extractRecipesData(dynamic data) {
    if (data is Map) {
      if (data.containsKey('recipes')) return data['recipes'] as List<dynamic>;
      if (data.containsKey('data')) {
        final nested = data['data'];
        if (nested is Map && nested.containsKey('recipes')) {
          return nested['recipes'] as List<dynamic>;
        }
        if (nested is List) return nested;
      }
    } else if (data is List) {
      return data;
    }
    return [];
  }

  void _updateCache(List<Recipe> newRecipes, bool forceRefresh, int page) {
    if (forceRefresh || page == 1) {
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
      final cached = _cachedRecipes.firstWhere((r) => r.id == id);
      return cached;
    } catch (_) {
      // Non trovato in cache, continua con la chiamata API
    }

    try {
      final response = await _dio.get(
        '/api/recipes/$id',
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.data['success'] == true) {
        final json = response.data['data'] as Map<String, dynamic>;
        final recipe = Recipe.fromJson(json);

        _cachedRecipes.add(recipe);
        notifyListeners();

        return recipe;
      }
    } catch (e) {
      AppLogger.error('Errore fetch dettaglio', e);
    }

    return null;
  }

  // ==================== CREATE RECIPE ====================
  Future<Recipe?> createRecipe(Recipe recipe) async {
    try {
      final response = await _dio.post(
        '/api/recipes',
        data: recipe.toJson(),
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Errore creazione');
      }

      final newRecipe =
          Recipe.fromJson(response.data['data'] as Map<String, dynamic>);

      if (newRecipe.id.isEmpty) {
        throw Exception('Recipe ID vuoto dopo creazione');
      }

      _cachedRecipes.insert(0, newRecipe);
      notifyListeners();

      return newRecipe;
    } catch (e) {
      AppLogger.error('❌ Errore creazione ricetta', e);
      return null;
    }
  }

  // ==================== UPDATE RECIPE ====================
  Future<Recipe?> updateRecipe(String id, Recipe recipe) async {
    try {
      // Prepara i dati per il backend
      final Map<String, dynamic> data = recipe.toJson();

      // 👈 Trasforma l'oggetto category in categoryId
      if (data['category'] != null && data['category'] is Map) {
        data['categoryId'] = data['category']['id'];
        data.remove('category'); // Rimuovi l'oggetto category
      }

      // 👈 Log per debug
      AppLogger.debug('📝 INVIO AL BACKEND - data: $data');

      final response = await _dio.put(
        '/api/recipes/$id',
        data: data,
        options: Options(headers: await _getAuthHeaders()),
      );

      if (response.data['success'] != true) {
        AppLogger.error('❌ Risposta errore: ${response.data}');
        return null;
      }

      final updatedRecipe =
          Recipe.fromJson(response.data['data'] as Map<String, dynamic>);

      _updateCachedRecipe(id, updatedRecipe);

      return updatedRecipe;
    } catch (e) {
      AppLogger.error('❌ Errore aggiornamento', e);
      return null;
    }
  }

  void _updateCachedRecipe(String id, Recipe updatedRecipe) {
    final index = _cachedRecipes.indexWhere((r) => r.id == id);
    if (index != -1) {
      _cachedRecipes[index] = updatedRecipe;
      notifyListeners();
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
      notifyListeners();

      return true;
    } catch (e) {
      AppLogger.error('❌ Errore eliminazione', e);
      return false;
    }
  }

  // ==================== REMOVE RECIPE IMAGE ====================
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
      AppLogger.error('❌ Errore rimozione immagine', e);
      return false;
    }
  }

  void _updateRecipeImage(String recipeId, String imageUrl) {
    final index = _cachedRecipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _cachedRecipes[index] =
          _cachedRecipes[index].copyWith(imageUrl: imageUrl);
      notifyListeners();
    }
  }

  // ==================== LOAD MORE ====================
  Future<void> loadMoreRecipes() async {
    if (_isLoading || !_hasMore) return;
    await fetchRecipes(page: _currentPage + 1);
  }

  // ==================== UPDATE STATUS ====================
  void updateRecipeLikedStatus(String recipeId, bool isLiked) {
    _updateRecipeField(
        recipeId, (recipe) => recipe.copyWith(isFavorite: isLiked));
  }

  void updateRecipeCommentCount(String recipeId, int commentCount) {
    _updateRecipeField(
        recipeId, (recipe) => recipe.copyWith(commentCount: commentCount));
  }

  void _updateRecipeField(String recipeId, Recipe Function(Recipe) update) {
    final index = _cachedRecipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _cachedRecipes[index] = update(_cachedRecipes[index]);
      notifyListeners();
    }
  }

  // ==================== UTILITY ====================
  void _setLoadingState(bool loading) {
    _isLoading = loading;
    if (!loading) _lastError = null;
    notifyListeners();
  }

  void clearCache() {
    _cachedRecipes.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
