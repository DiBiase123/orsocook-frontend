import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orsocook/config.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';

class FetchUserFavoritesStrategy {
  final AuthService _authService;
  static const _timeout = Duration(seconds: 15);

  FetchUserFavoritesStrategy(this._authService);

  Future<List<Recipe>> execute(String userId,
      {int page = 1, int limit = 10}) async {
    AppLogger.debug(
        '📦 FetchUserFavoritesStrategy - page: $page, limit: $limit');

    final token = _authService.token;
    if (token == null) {
      throw 'Utente non autenticato';
    }

    final url = '${Config.apiBaseUrl}/api/favorites?page=$page&limit=$limit';
    AppLogger.api('GET /api/favorites?page=$page&limit=$limit');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    ).timeout(_timeout);

    AppLogger.debug('📥 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);

      List<dynamic> items = [];
      if (data is Map) {
        if (data['success'] == true && data['data'] != null) {
          items = data['data'] is List ? data['data'] : [];
        } else if (data['data'] is List) {
          items = data['data'];
        }
      } else if (data is List) {
        items = data;
      }

      AppLogger.debug('📦 Ricevuti ${items.length} items');

      final recipes = <Recipe>[];
      for (var i = 0; i < items.length; i++) {
        try {
          recipes.add(Recipe.fromJson(items[i]));
        } catch (e) {
          AppLogger.error('❌ Errore parsing item $i', e);
        }
      }

      return recipes;
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw _handleHttpError(response.statusCode);
    }
  }

  String _handleHttpError(int code) {
    switch (code) {
      case 401:
        return 'Sessione scaduta';
      case 403:
        return 'Non autorizzato';
      case 404:
        return 'Non trovato';
      default:
        return 'Errore server: $code';
    }
  }
}
