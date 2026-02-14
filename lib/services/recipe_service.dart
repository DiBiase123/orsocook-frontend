import 'dart:async';
import 'dart:convert';
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

  RecipeService(this._authService) {
    _dio.options.baseUrl = Config.buildUrl('');
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    _dio.options.validateStatus = (status) => status != null && status < 500;
  }

  List<Recipe> get cachedRecipes => _cachedRecipes;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get hasError => _lastError != null;
  String? get lastError => _lastError;

  // ==================== AUTH HEADERS ====================
  Future<Map<String, String>> _getAuthHeaders() async {
    return await _authService.getAuthHeaders();
  }

  // ==================== FETCH RECIPES ====================
  Future<List<Recipe>> fetchRecipes({
    bool forceRefresh = false,
    int page = 1,
  }) async {
    if (_isLoading && !forceRefresh) return _cachedRecipes;

    try {
      _isLoading = true;
      _lastError = null;
      notifyListeners();

      final authHeaders = await _getAuthHeaders();

      final response = await _dio.get(
        '/api/recipes',
        queryParameters: {'page': page, 'limit': 10},
        options: Options(headers: authHeaders),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Errore sconosciuto');
      }

      final List<Recipe> recipes = _parseRecipesResponse(response.data['data']);

      if (forceRefresh || page == 1) {
        _cachedRecipes = recipes;
      } else {
        _cachedRecipes.addAll(recipes);
      }

      _hasMore = recipes.isNotEmpty;
      _currentPage = page;

      return _cachedRecipes;
    } catch (e) {
      _lastError = e.toString();
      return _cachedRecipes;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== PARSE RESPONSE ====================
  List<Recipe> _parseRecipesResponse(dynamic data) {
    List<dynamic> recipesData = [];

    if (data is Map) {
      if (data.containsKey('recipes')) {
        recipesData = data['recipes'] as List<dynamic>;
      } else if (data.containsKey('data')) {
        final nested = data['data'];
        if (nested is Map && nested.containsKey('recipes')) {
          recipesData = nested['recipes'] as List<dynamic>;
        } else if (nested is List) {
          recipesData = nested;
        }
      }
    } else if (data is List) {
      recipesData = data;
    }

    final List<Recipe> recipes = [];

    for (var json in recipesData) {
      if (json is Map) {
        try {
          recipes.add(Recipe.fromJson(Map<String, dynamic>.from(json)));
        } catch (e) {
          AppLogger.error('Errore conversione ricetta', e);
        }
      }
    }

    return recipes;
  }

  // ==================== GET RECIPE BY ID ====================
  Future<Recipe?> getRecipeById(String id) async {
    for (var recipe in _cachedRecipes) {
      if (recipe.id == id) return recipe;
    }

    try {
      final authHeaders = await _getAuthHeaders();
      final response = await _dio.get(
        '/api/recipes/$id',
        options: Options(headers: authHeaders),
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
      final authHeaders = await _getAuthHeaders();

      // Prepara i dati JSON
      final recipeData = recipe.toJson();

      AppLogger.debug(
          '📤 Invio ricetta con imageUrl: ${recipeData['imageUrl']}');

      final response = await _dio.post(
        '/api/recipes',
        data: recipeData,
        options: Options(headers: authHeaders),
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Errore creazione');
      }

      final json = response.data['data'] as Map<String, dynamic>;
      final newRecipe = Recipe.fromJson(json);

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
  Future<Recipe?> updateRecipe(
    String id,
    Recipe recipe,
  ) async {
    try {
      final authHeaders = await _getAuthHeaders();

      // Prepara i dati JSON
      final recipeData = recipe.toJson();

      AppLogger.debug(
          '📤 Aggiornamento ricetta $id con imageUrl: ${recipe.imageUrl}');

      final response = await _dio.put(
        '/api/recipes/$id',
        data: recipeData,
        options: Options(headers: authHeaders),
      );

      if (response.data['success'] != true) {
        AppLogger.error('❌ Risposta errore: ${response.data}');
        return null;
      }

      final json = response.data['data'] as Map<String, dynamic>;
      final updatedRecipe = Recipe.fromJson(json);

      final index = _cachedRecipes.indexWhere((r) => r.id == id);
      if (index != -1) {
        _cachedRecipes[index] = updatedRecipe;
        notifyListeners();
      }

      return updatedRecipe;
    } catch (e) {
      AppLogger.error('❌ Errore aggiornamento', e);
      return null;
    }
  }

  // ==================== DELETE RECIPE ====================
  Future<bool> deleteRecipe(String id) async {
    try {
      final authHeaders = await _getAuthHeaders();
      final response = await _dio.delete(
        '/api/recipes/$id',
        options: Options(headers: authHeaders),
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
      final authHeaders = await _authService.getAuthHeaders();
      final token = authHeaders['Authorization']?.replaceFirst('Bearer ', '');

      if (token == null) return false;

      final response = await _dio.delete(
        '/api/recipes/$recipeId/remove-image',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          method: 'DELETE',
        ),
      );

      if (response.data['success'] != true) return false;

      final index = _cachedRecipes.indexWhere((r) => r.id == recipeId);
      if (index != -1) {
        final updatedRecipe = _cachedRecipes[index].copyWith(imageUrl: '');
        _cachedRecipes[index] = updatedRecipe;
        notifyListeners();
      }

      return true;
    } catch (e) {
      AppLogger.error('❌ Errore rimozione immagine', e);
      return false;
    }
  }

  // ==================== LOAD MORE RECIPES ====================
  Future<void> loadMoreRecipes() async {
    if (_isLoading || !_hasMore) return;
    await fetchRecipes(page: _currentPage + 1);
  }

  // ==================== UPDATE LIKED STATUS ====================
  void updateRecipeLikedStatus(String recipeId, bool isLiked) {
    final index = _cachedRecipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _cachedRecipes[index] = _cachedRecipes[index].copyWith(
        isFavorite: isLiked,
      );
      notifyListeners();
    }
  }

  // ==================== UPDATE COMMENT COUNT ====================
  void updateRecipeCommentCount(String recipeId, int commentCount) {
    final index = _cachedRecipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      _cachedRecipes[index] = _cachedRecipes[index].copyWith(
        commentCount: commentCount,
      );
      notifyListeners();
    }
  }

  // ==================== CLEAR CACHE ====================
  void clearCache() {
    _cachedRecipes.clear();
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  // ==================== CLEAR ERROR ====================
  void clearError() {
    _lastError = null;
    notifyListeners();
  }
}
