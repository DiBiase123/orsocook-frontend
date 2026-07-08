import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:orsocook/config.dart';
import 'package:orsocook/services/auth_modules/storage/auth_storage.dart';

class WebDocumentsService {
  final Dio _dio;
  final AuthStorage _authStorage;

  WebDocumentsService({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? Config.buildUrl(''),
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        _authStorage = AuthStorage();

  Future<Map<String, String>> _getHeaders() async {
    final authData = await _authStorage.loadAuthData();
    return {
      'Content-Type': 'application/json',
      if (authData != null) 'Authorization': 'Bearer ${authData.token}',
    };
  }

  // GET - Lista documenti
  Future<List<dynamic>> getDocuments() async {
    try {
      final response = await _dio.get(
        '/api/webdocuments',
        options: Options(headers: await _getHeaders()),
      );

      if (response.data['success'] == true) {
        return response.data['data'] ?? [];
      }
      throw Exception('Errore nel caricamento documenti');
    } catch (e) {
      debugPrint('❌ getDocuments error: $e');
      throw Exception('Errore nel caricamento documenti');
    }
  }

  // GET - Singolo documento
  Future<Map<String, dynamic>> getDocumentById(String id) async {
    try {
      final response = await _dio.get(
        '/api/webdocuments/$id',
        options: Options(headers: await _getHeaders()),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception('Documento non trovato');
    } catch (e) {
      debugPrint('❌ getDocumentById error: $e');
      throw Exception('Documento non trovato');
    }
  }

  // POST - Upload documento (base64 via Dio)
  Future<Map<String, dynamic>> createDocument({
    required String description,
    required String documentDate,
    required String ente,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    try {
      final headers = await _getHeaders();

      final response = await _dio.post(
        '/api/webdocuments',
        data: {
          'description': description,
          'documentDate': documentDate,
          'ente': ente,
          'fileName': fileName,
          'fileData': base64.encode(fileBytes),
        },
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Errore nel caricamento');
    } catch (e) {
      debugPrint('❌ createDocument error: $e');
      throw Exception('Errore nel caricamento documento');
    }
  }

  // PUT - Modifica documento
  Future<void> updateDocument({
    required String id,
    String? description,
    String? documentDate,
    String? ente,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};
      if (description != null) body['description'] = description;
      if (documentDate != null) body['documentDate'] = documentDate;
      if (ente != null) body['ente'] = ente;

      final response = await _dio.put(
        '/api/webdocuments/$id',
        data: body,
        options: Options(headers: headers),
      );

      if (response.data['success'] != true) {
        throw Exception('Errore nella modifica documento');
      }
    } catch (e) {
      debugPrint('❌ updateDocument error: $e');
      throw Exception('Errore nella modifica documento');
    }
  }

  // DELETE - Elimina documento
  Future<void> deleteDocument(String id) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.delete(
        '/api/webdocuments/$id',
        options: Options(headers: headers),
      );

      if (response.data['success'] != true) {
        throw Exception('Errore nell\'eliminazione documento');
      }
    } catch (e) {
      debugPrint('❌ deleteDocument error: $e');
      throw Exception('Errore nell\'eliminazione documento');
    }
  }
}
