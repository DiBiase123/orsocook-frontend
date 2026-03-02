import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/config.dart';

class FavoriteService extends ChangeNotifier {
  final AuthService _authService;

  // Cache locale per risposte immediate
  final Map<String, bool> _favoriteCache = {};

  bool _isLoading = false;
  String? _error;

  FavoriteService(this._authService);

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Verifica se una ricetta è nei preferiti - USA CACHE
  Future<bool> isFavorite(String recipeId) async {
    if (_favoriteCache.containsKey(recipeId)) {
      return _favoriteCache[recipeId]!;
    }

    try {
      final result = await checkFavorite(recipeId);
      final isFavorite = result['isFavorite'] ?? false;
      _favoriteCache[recipeId] = isFavorite;
      return isFavorite;
    } catch (e) {
      AppLogger.error('Error checking favorite status', e);
      return false;
    }
  }

  // Ottieni i preferiti dell'utente
  Future<List<Recipe>> getFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!_authService.isLoggedIn) {
        throw Exception('Utente non autenticato');
      }

      final authHeaders = await _authService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/favorites'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final favorites = data.map((item) => Recipe.fromJson(item)).toList();

        // Aggiorna cache
        for (final recipe in favorites) {
          _favoriteCache[recipe.id] = true;
        }

        _isLoading = false;
        notifyListeners();

        return favorites;
      } else {
        throw Exception('Failed to load favorites: ${response.statusCode}');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      AppLogger.error('Error loading favorites', e);
      notifyListeners();
      rethrow;
    }
  }

  // Aggiungi ai preferiti
  Future<bool> addFavorite(String recipeId) async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('Utente non autenticato');
      }

      // Optimistic update
      _favoriteCache[recipeId] = true;
      notifyListeners();

      final authHeaders = await _authService.getAuthHeaders();

      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/favorites/$recipeId'),
        headers: authHeaders,
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        // Rollback
        _favoriteCache[recipeId] = false;
        notifyListeners();
        throw Exception('Failed to add favorite');
      }
    } catch (e) {
      _favoriteCache[recipeId] = false;
      notifyListeners();
      AppLogger.error('Error adding favorite', e);
      rethrow;
    }
  }

  // Rimuovi dai preferiti
  Future<bool> removeFavorite(String recipeId) async {
    try {
      if (!_authService.isLoggedIn) {
        throw Exception('Utente non autenticato');
      }

      // Optimistic update
      _favoriteCache[recipeId] = false;
      notifyListeners();

      final authHeaders = await _authService.getAuthHeaders();

      final response = await http.delete(
        Uri.parse('${Config.apiBaseUrl}/api/favorites/$recipeId'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        // Rollback
        _favoriteCache[recipeId] = true;
        notifyListeners();
        throw Exception('Failed to remove favorite');
      }
    } catch (e) {
      _favoriteCache[recipeId] = true;
      notifyListeners();
      AppLogger.error('Error removing favorite', e);
      rethrow;
    }
  }

  // Controlla se una ricetta è preferita
  Future<Map<String, dynamic>> checkFavorite(String recipeId) async {
    try {
      if (!_authService.isLoggedIn) {
        return {'isFavorite': false, 'favoritedAt': null};
      }

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
      AppLogger.error('Error checking favorite status', e);
      return {'isFavorite': false, 'favoritedAt': null};
    }
  }

  // Toggle preferito
  Future<bool> toggleFavorite(String recipeId) async {
    try {
      final isCurrentlyFavorite = _favoriteCache[recipeId] ?? false;

      if (isCurrentlyFavorite) {
        return await removeFavorite(recipeId);
      } else {
        return await addFavorite(recipeId);
      }
    } catch (e) {
      AppLogger.error('Error toggling favorite', e);
      rethrow;
    }
  }

  // 👇 NUOVO: Svuota cache (da chiamare al logout)
  void clearCache() {
    _favoriteCache.clear();
    notifyListeners();
    AppLogger.debug('🧹 Cache preferiti svuotata');
  }

  // Svuota stato
  void reset() {
    _error = null;
    _favoriteCache.clear();
    notifyListeners();
  }
}
