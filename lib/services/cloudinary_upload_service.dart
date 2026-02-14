import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:orsocook/config.dart';
import 'package:orsocook/services/auth_service.dart';

class CloudinaryUploadService {
  final Dio _dio = Dio();
  final AuthService _authService;

  CloudinaryUploadService(this._authService);

  Future<Map<String, dynamic>> _getUploadSignature(String folder) async {
    try {
      final headers = await _authService.getAuthHeaders();
      final response = await _dio.get(
        '${Config.buildUrl('')}/api/upload/signature',
        queryParameters: {'folder': folder},
        options: Options(headers: headers),
      );

      if (response.data['success'] != true) {
        throw Exception('Errore nel recupero firma upload');
      }

      return response.data['data'];
    } catch (e) {
      debugPrint('❌ Errore getUploadSignature: $e');
      rethrow;
    }
  }

  Future<String> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    String folder = 'orsocook/recipes',
  }) async {
    try {
      // 1. Ottieni firma dal backend
      final signatureData = await _getUploadSignature(folder);
      debugPrint('📦 signatureData: $signatureData');

      // 2. Prepara form data per Cloudinary
      final uri = Uri.parse(
          'https://api.cloudinary.com/v1_1/${signatureData['cloudName']}/auto/upload');

      debugPrint('📦 URL: $uri');

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromBytes(imageBytes, filename: fileName),
        'api_key': signatureData['apiKey'],
        'timestamp': signatureData['timestamp'],
        'signature': signatureData['signature'],
        'folder': signatureData['folder'],
      });

      final response = await Dio().post(
        uri.toString(),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode != 200) {
        throw Exception('Upload fallito: ${response.statusCode}');
      }

      debugPrint('✅ Upload completato: ${response.data['secure_url']}');

      // 3. Restituisci URL sicuro
      return response.data['secure_url'];
    } catch (e) {
      debugPrint('❌ Errore upload su Cloudinary: $e');
      rethrow;
    }
  }
}
