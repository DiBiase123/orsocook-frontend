import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/config.dart';

class FavoriteService extends ChangeNotifier {
  final AuthService _authService;

  // 👇 ELIMINIAMO LA CACHE
  // final Map<String, Recipe> _favoritesCache = {};

  bool _isLoading = false;
  String? _error;

  FavoriteService(this._authService);

  bool get isLoading => _isLoading;
  String? get error => _error;

  // 👇 OGNI VOLTA CHE CHIEDIAMO I FAVORITI, ANDIAMO AL BACKEND
  List<Recipe> get favorites => []; // Vuoto, non usiamo cache

  // Verifica se una ricetta è nei preferiti - SEMPRE DAL BACKEND
  Future<bool> isFavorite(String recipeId) async {
    try {
      final result = await checkFavorite(recipeId);
      return result['isFavorite'] ?? false;
    } catch (e) {
      AppLogger.error('Error checking favorite status', e);
      return false;
    }
  }

  // Ottieni i preferiti dell'utente - SEMPRE DAL BACKEND
  Future<List<Recipe>> getFavorites() async {
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
        final favorites = data.map((item) => Recipe.fromJson(item)).toList();

        _isLoading = false;
        AppLogger.success('Loaded ${favorites.length} favorites from API');
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
        AppLogger.success('Added recipe $recipeId to favorites');
        notifyListeners(); // Notifica che qualcosa è cambiato
        return true;
      } else {
        final errorMsg = response.body.isNotEmpty
            ? json.decode(response.body)['error']
            : 'Failed to add favorite';
        throw Exception(errorMsg);
      }
    } catch (e) {
      AppLogger.error('Error adding favorite', e);
      rethrow;
    }
  }

  // Rimuovi dai preferiti
  Future<bool> removeFavorite(String recipeId) async {
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
        AppLogger.success('Removed recipe $recipeId from favorites');
        notifyListeners(); // Notifica che qualcosa è cambiato
        return true;
      } else {
        final errorMsg = response.body.isNotEmpty
            ? json.decode(response.body)['error']
            : 'Failed to remove favorite';
        throw Exception(errorMsg);
      }
    } catch (e) {
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
      AppLogger.error('Error checking favorite status', e);
      return {'isFavorite': false, 'favoritedAt': null};
    }
  }

  // Toggle preferito
  Future<bool> toggleFavorite(String recipeId) async {
    try {
      // 👈 VERIFICA SEMPRE LO STATO ATTUALE DAL BACKEND
      final checkResult = await checkFavorite(recipeId);
      final isCurrentlyFavorite = checkResult['isFavorite'] ?? false;

      AppLogger.debug('🔄 Toggle favorite - Stato reale: $isCurrentlyFavorite');

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

  // Svuota stato (utile per logout)
  void reset() {
    _error = null;
    notifyListeners();
  }
}
