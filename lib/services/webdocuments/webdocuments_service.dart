import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orsocook/config.dart';
import 'package:orsocook/services/auth_modules/storage/auth_storage.dart';

class WebDocumentsService {
  final String baseUrl;
  final AuthStorage _authStorage;

  WebDocumentsService({String? baseUrl})
      : baseUrl = baseUrl ?? Config.buildUrl(),
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
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/webdocuments'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    }
    throw Exception('Errore nel caricamento documenti');
  }

  // GET - Singolo documento
  Future<Map<String, dynamic>> getDocumentById(String id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/webdocuments/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    }
    throw Exception('Documento non trovato');
  }

  // POST - Upload documento (base64)
  Future<Map<String, dynamic>> createDocument({
    required String description,
    required String documentDate,
    required String ente,
    required List<int> fileBytes,
    required String fileName,
  }) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'description': description,
      'documentDate': documentDate,
      'ente': ente,
      'fileName': fileName,
      'fileData': base64.encode(fileBytes),
    });

    final response = await http.post(
      Uri.parse('$baseUrl/api/webdocuments'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['data'];
    }
    throw Exception(
        'Errore nel caricamento documento: ${response.statusCode} ${response.body}');
  }

  // PUT - Modifica documento
  Future<void> updateDocument({
    required String id,
    String? description,
    String? documentDate,
    String? ente,
  }) async {
    final headers = await _getHeaders();
    final body = <String, dynamic>{};
    if (description != null) body['description'] = description;
    if (documentDate != null) body['documentDate'] = documentDate;
    if (ente != null) body['ente'] = ente;

    final response = await http.put(
      Uri.parse('$baseUrl/api/webdocuments/$id'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Errore nella modifica documento');
    }
  }

  // DELETE - Elimina documento
  Future<void> deleteDocument(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/webdocuments/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Errore nell\'eliminazione documento');
    }
  }
}
