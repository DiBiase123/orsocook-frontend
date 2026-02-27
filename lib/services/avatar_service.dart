import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:orsocook/config.dart';
import 'package:orsocook/utils/logger.dart';

class AvatarService extends ChangeNotifier {
  bool _isUploading = false;
  String? _uploadError;

  // Getters
  bool get isUploading => _isUploading;
  String? get uploadError => _uploadError;

  // Helper per determinare il MediaType in base all'estensione
  MediaType _getMediaType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      case 'bmp':
        return MediaType('image', 'bmp');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  // Reset error
  void _resetError() {
    if (_uploadError != null) {
      _uploadError = null;
      notifyListeners();
    }
  }

  // Upload avatar - MODIFICATO per accettare Uint8List
  Future<Map<String, dynamic>> uploadAvatar({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    _isUploading = true;
    _resetError();
    notifyListeners();

    AppLogger.log("AvatarService: Upload avatar iniziato");

    try {
      // Prepara la richiesta multipart
      final url = Config.buildUrl('/api/auth/avatar');

      // Ottieni il token da SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Utente non autenticato');
      }

      // DEBUG ESTESO
      AppLogger.debug("=== AVATAR SERVICE DEBUG ===");
      AppLogger.debug("1. File name: $fileName");
      AppLogger.debug("2. File size: ${imageBytes.length} bytes");
      AppLogger.debug("3. Token length: ${token.length}");
      AppLogger.debug("4. URL: $url");

      // Crea la richiesta multipart
      final request = http.MultipartRequest('PUT', Uri.parse(url));

      // Aggiungi header Authorization
      request.headers['Authorization'] = 'Bearer $token';

      // Ottieni l'estensione del file per determinare il content-type
      final extension = fileName.split('.').last.toLowerCase();
      final contentType = _getMediaType(extension);

      AppLogger.debug("5. File extension: $extension");
      AppLogger.debug("6. Content-Type: ${contentType.mimeType}");

      // Crea il multipart file direttamente dai bytes
      final multipartFile = http.MultipartFile.fromBytes(
        'avatar',
        imageBytes,
        filename: fileName,
        contentType: contentType,
      );

      request.files.add(multipartFile);

      AppLogger.debug("7. Request files count: ${request.files.length}");
      AppLogger.debug("=== END AVATAR DEBUG ===");

      // Invia la richiesta
      AppLogger.debug("Invio richiesta multipart...");
      final streamedResponse = await request.send();

      // Debug della risposta
      AppLogger.debug('📥 RESPONSE STATUS: ${streamedResponse.statusCode}');

      final response = await http.Response.fromStream(streamedResponse);

      _isUploading = false;

      // Debug della risposta
      AppLogger.debug("Avatar upload response status: ${response.statusCode}");
      AppLogger.debug("Avatar upload response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          AppLogger.success("Avatar upload completato con successo");

          // Estrai l'URL del nuovo avatar dalla risposta
          final userData = responseData['data']['user'];
          final newAvatarUrl = userData['avatarUrl'];
          final successMessage =
              responseData['message'] ?? 'Avatar aggiornato con successo';

          // Salva l'avatar URL in SharedPreferences
          await prefs.setString('avatarUrl', newAvatarUrl);
          AppLogger.debug(
              "Avatar URL salvato in SharedPreferences: $newAvatarUrl");

          // Aggiorna il token se presente nella risposta (opzionale)
          if (responseData['data']['token'] != null) {
            await prefs.setString('token', responseData['data']['token']);
          }

          notifyListeners();

          return {
            'success': true,
            'message': successMessage,
            'avatarUrl': newAvatarUrl,
            'user': userData,
          };
        } else {
          _uploadError = responseData['message'] ?? 'Errore sconosciuto';
          AppLogger.error("Avatar upload fallito: $_uploadError");
          notifyListeners();

          return {
            'success': false,
            'message': _uploadError,
          };
        }
      } else {
        String errorMsg;
        try {
          final errorData = jsonDecode(response.body);
          errorMsg =
              errorData['message'] ?? 'Errore HTTP ${response.statusCode}';
        } catch (e) {
          errorMsg = 'Errore HTTP ${response.statusCode}';
        }

        _uploadError = errorMsg;
        AppLogger.error("Avatar upload HTTP error: $_uploadError");
        notifyListeners();

        return {
          'success': false,
          'message': _uploadError,
        };
      }
    } catch (e) {
      _isUploading = false;
      _uploadError = e.toString();

      AppLogger.error("Avatar upload exception", e);
      notifyListeners();

      return {
        'success': false,
        'message': 'Errore durante l\'upload: ${e.toString()}',
      };
    }
  }

  // Delete avatar (opzionale)
  Future<Map<String, dynamic>> deleteAvatar() async {
    AppLogger.log("AvatarService: deleteAvatar non implementato nel backend");

    return {
      'success': false,
      'message': 'Eliminazione avatar non supportata',
    };
  }

  // Reset stato
  void reset() {
    _isUploading = false;
    _uploadError = null;
    notifyListeners();
  }
}
