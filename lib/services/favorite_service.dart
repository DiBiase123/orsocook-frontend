import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/config.dart';

class FavoriteService extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String? _error;

  // Cache temporanea per i titoli (opzionale, per log migliori)
  final Map<String, String> _recipeTitles = {};

  FavoriteService(this._authService);

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Registra il titolo di una ricetta per log migliori
  void registerRecipeTitle(String recipeId, String title) {
    _recipeTitles[recipeId] = title;
  }

  String _getRecipeTitle(String recipeId) {
    return _recipeTitles[recipeId] ?? 'ricetta sconosciuta';
  }

  // Verifica se una ricetta è nei preferiti
  Future<bool> isFavorite(String recipeId) async {
    final title = _getRecipeTitle(recipeId);
    try {
      final result = await checkFavorite(recipeId);
      final isFavorite = result['isFavorite'] ?? false;
      return isFavorite;
    } catch (e) {
      AppLogger.error(
          '❌ [FAVORITE] Error checking favorite status per "$title"', e);
      return false;
    }
  }

  // Ottieni i preferiti dell'utente
  Future<List<Recipe>> getFavorites() async {
    AppLogger.debug('📦 [FAVORITE] getFavorites chiamato');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_authService.isLoggedIn) {
        throw Exception('Utente non autenticato');
      }

      AppLogger.api('GET /api/favorites');
      final authHeaders = await _authService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/favorites'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        final favorites = <Recipe>[];
        for (var i = 0; i < data.length; i++) {
          try {
            final recipe = Recipe.fromJson(data[i]);
            favorites.add(recipe);
            // Registra il titolo nella cache locale
            _recipeTitles[recipe.id] = recipe.title;
          } catch (e) {
            AppLogger.error('❌ [FAVORITE] Errore parsing ricetta $i', e);
          }
        }

        _isLoading = false;
        AppLogger.success(
            '✅ [FAVORITE] Caricati ${favorites.length} preferiti');
        notifyListeners();

        return favorites;
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      AppLogger.error('❌ [FAVORITE] Error loading favorites', e);
      notifyListeners();
      rethrow;
    }
  }

  // Aggiungi ai preferiti
  Future<bool> addFavorite(String recipeId) async {
    final title = _getRecipeTitle(recipeId);
    AppLogger.api('POST /api/favorites/$recipeId');

    try {
      if (!_authService.isLoggedIn) {
        throw Exception('Utente non autenticato');
      }

      final authHeaders = await _authService.getAuthHeaders();

      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/favorites/$recipeId'),
        headers: authHeaders,
      );

      if (response.statusCode == 201) {
        AppLogger.success('✅ [FAVORITE] Aggiunta "$title" ai preferiti');
        notifyListeners();
        return true;
      } else {
        final errorMsg = response.body.isNotEmpty
            ? json.decode(response.body)['error']
            : 'Failed to add favorite';
        AppLogger.error('❌ [FAVORITE] Failed to add "$title": $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      AppLogger.error('❌ [FAVORITE] Error adding "$title" ai preferiti', e);
      rethrow;
    }
  }

  // Rimuovi dai preferiti
  Future<bool> removeFavorite(String recipeId) async {
    final title = _getRecipeTitle(recipeId);
    AppLogger.api('DELETE /api/favorites/$recipeId');

    try {
      if (!_authService.isLoggedIn) {
        throw Exception('Utente non autenticato');
      }

      final authHeaders = await _authService.getAuthHeaders();

      final response = await http.delete(
        Uri.parse('${Config.apiBaseUrl}/api/favorites/$recipeId'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        AppLogger.success('✅ [FAVORITE] Rimossa "$title" dai preferiti');
        notifyListeners();
        return true;
      } else {
        final errorMsg = response.body.isNotEmpty
            ? json.decode(response.body)['error']
            : 'Failed to remove favorite';
        AppLogger.error('❌ [FAVORITE] Failed to remove "$title": $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      AppLogger.error('❌ [FAVORITE] Error removing "$title" dai preferiti', e);
      rethrow;
    }
  }

  // Controlla se una ricetta è preferita
  Future<Map<String, dynamic>> checkFavorite(String recipeId) async {
    final title = _getRecipeTitle(recipeId);
    try {
      if (!_authService.isLoggedIn) {
        return {'isFavorite': false, 'favoritedAt': null};
      }

      AppLogger.api('GET /api/favorites/check/$recipeId');

      final authHeaders = await _authService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/favorites/check/$recipeId'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check favorite: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error(
          '❌ [FAVORITE] Error checking favorite status per "$title"', e);
      return {'isFavorite': false, 'favoritedAt': null};
    }
  }

  // Toggle preferito
  Future<bool> toggleFavorite(String recipeId) async {
    final title = _getRecipeTitle(recipeId);
    AppLogger.debug(
        '🔄 [FAVORITE] toggleFavorite chiamato per "$title" ($recipeId)');
    try {
      final checkResult = await checkFavorite(recipeId);
      final isCurrentlyFavorite = checkResult['isFavorite'] ?? false;

      if (isCurrentlyFavorite) {
        return await removeFavorite(recipeId);
      } else {
        return await addFavorite(recipeId);
      }
    } catch (e) {
      AppLogger.error('❌ [FAVORITE] Error toggling favorite per "$title"', e);
      rethrow;
    }
  }

  // Svuota stato (utile per logout)
  void reset() {
    AppLogger.debug('🧹 [FAVORITE] reset chiamato');
    _error = null;
    _recipeTitles.clear();
    notifyListeners();
  }
}
