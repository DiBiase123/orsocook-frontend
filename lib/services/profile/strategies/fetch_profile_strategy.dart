import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orsocook/config.dart';
import 'package:orsocook/models/profile_response.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';

class FetchProfileStrategy {
  final AuthService _authService;
  static const _timeout = Duration(seconds: 15);

  FetchProfileStrategy(this._authService);

  Future<ProfileResponse?> execute(String userId, {bool force = false}) async {
    AppLogger.debug('📥 FetchProfileStrategy - userId: $userId, force: $force');

    final token = _authService.token;
    if (token == null) {
      throw 'Utente non autenticato';
    }

    final url = '${Config.apiBaseUrl}/api/auth/profile/$userId';
    AppLogger.api('GET /api/auth/profile/$userId');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    ).timeout(_timeout);

    AppLogger.debug('📥 Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success'] == true) {
        return ProfileResponse.fromJson(data['data']);
      } else {
        throw data['message'] ?? 'Errore profilo';
      }
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
