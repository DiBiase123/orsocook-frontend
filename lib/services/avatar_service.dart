import 'dart:async';
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

  bool get isUploading => _isUploading;
  String? get uploadError => _uploadError;

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

  void _resetError() {
    if (_uploadError != null) {
      _uploadError = null;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> uploadAvatar({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    _isUploading = true;
    _resetError();
    notifyListeners();

    AppLogger.log("AvatarService: Upload avatar iniziato");

    try {
      final url = Config.buildUrl('/api/auth/avatar');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        throw Exception('Utente non autenticato');
      }

      _logDebugInfo(fileName, imageBytes.length, token.length, url);

      final request = http.MultipartRequest('PUT', Uri.parse(url))
        ..headers['Authorization'] = 'Bearer $token';

      final extension = fileName.split('.').last.toLowerCase();
      final contentType = _getMediaType(extension);

      request.files.add(http.MultipartFile.fromBytes(
        'avatar',
        imageBytes,
        filename: fileName,
        contentType: contentType,
      ));

      AppLogger.debug("Invio richiesta multipart...");
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _isUploading = false;
      AppLogger.debug("Avatar upload response status: ${response.statusCode}");

      return _handleResponse(response, prefs);
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

  Map<String, dynamic> _handleResponse(
      http.Response response, SharedPreferences prefs) {
    try {
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['success'] == true) {
          return _handleSuccessResponse(responseData, prefs);
        }
      }

      return _handleErrorResponse(response, responseData);
    } catch (e) {
      _uploadError = 'Errore HTTP ${response.statusCode}';
      AppLogger.error("Avatar upload HTTP error: $_uploadError");
      notifyListeners();
      return {
        'success': false,
        'message': _uploadError!,
      };
    }
  }

  Map<String, dynamic> _handleSuccessResponse(
      Map<String, dynamic> responseData, SharedPreferences prefs) {
    final userData = responseData['data']['user'];
    final newAvatarUrl = userData['avatarUrl'];
    final successMessage =
        responseData['message'] ?? 'Avatar aggiornato con successo';

    unawaited(prefs.setString('avatarUrl', newAvatarUrl));

    if (responseData['data']['token'] != null) {
      unawaited(prefs.setString('token', responseData['data']['token']));
    }

    AppLogger.success("Avatar upload completato con successo");
    notifyListeners();

    return {
      'success': true,
      'message': successMessage,
      'avatarUrl': newAvatarUrl,
      'user': userData,
    };
  }

  Map<String, dynamic> _handleErrorResponse(
      http.Response response, Map<String, dynamic> responseData) {
    final errorMsg =
        responseData['message'] ?? 'Errore HTTP ${response.statusCode}';
    _uploadError = errorMsg;
    AppLogger.error("Avatar upload fallito: $_uploadError");
    notifyListeners();

    return {
      'success': false,
      'message': errorMsg,
    };
  }

  void _logDebugInfo(
      String fileName, int bytesLength, int tokenLength, String url) {
    AppLogger.debug("=== AVATAR SERVICE DEBUG ===");
    AppLogger.debug("1. File name: $fileName");
    AppLogger.debug("2. File size: $bytesLength bytes");
    AppLogger.debug("3. Token length: $tokenLength");
    AppLogger.debug("4. URL: $url");
    AppLogger.debug("=== END AVATAR DEBUG ===");
  }

  Future<Map<String, dynamic>> deleteAvatar() async {
    AppLogger.log("AvatarService: deleteAvatar non implementato nel backend");
    return {
      'success': false,
      'message': 'Eliminazione avatar non supportata',
    };
  }

  void reset() {
    _isUploading = false;
    _uploadError = null;
    notifyListeners();
  }
}
