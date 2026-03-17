import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:orsocook/config.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'dart:convert';

class UploadAvatarStrategy {
  final AuthService _authService;
  static const _timeout = Duration(seconds: 30);

  UploadAvatarStrategy(this._authService);

  Future<Map<String, dynamic>> execute({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    AppLogger.debug('📤 UploadAvatarStrategy - fileName: $fileName');

    final token = _authService.token;
    if (token == null) {
      return {'success': false, 'message': 'Utente non autenticato'};
    }

    final url = '${Config.apiBaseUrl}/api/auth/avatar';
    AppLogger.api('PUT /api/auth/avatar');

    final request = http.MultipartRequest('PUT', Uri.parse(url))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(http.MultipartFile.fromBytes(
        'avatar',
        imageBytes,
        filename: fileName,
      ));

    try {
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      AppLogger.debug('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Avatar aggiornato',
            'avatarUrl': data['data']?['user']?['avatarUrl'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Errore upload'
          };
        }
      } else {
        return {
          'success': false,
          'message': _handleHttpError(response.statusCode)
        };
      }
    } catch (e) {
      AppLogger.error('❌ UploadAvatarStrategy error', e);
      return {'success': false, 'message': 'Errore di connessione'};
    }
  }

  String _handleHttpError(int code) {
    switch (code) {
      case 400:
        return 'Richiesta non valida';
      case 401:
        return 'Sessione scaduta';
      case 403:
        return 'Non autorizzato';
      case 413:
        return 'File troppo grande (max 5MB)';
      case 415:
        return 'Formato file non supportato';
      default:
        return 'Errore server: $code';
    }
  }
}
