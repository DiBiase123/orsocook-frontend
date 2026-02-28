import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;
  final bool requiresVerification;
  final bool isLocked;
  final int? lockTime;
  final String? email;
  final int? attemptsLeft;

  AuthResponse({
    required this.success,
    required this.message,
    this.data,
    this.requiresVerification = false,
    this.isLocked = false,
    this.lockTime,
    this.email,
    this.attemptsLeft,
  });

  factory AuthResponse.fromHttpResponse(http.Response response) {
    try {
      final Map<String, dynamic> json =
          jsonDecode(utf8.decode(response.bodyBytes));

      // Estrai data se presente
      final Map<String, dynamic>? data = json['data'] as Map<String, dynamic>?;

      // ✅ CERCA requiresVerification IN TRE POSTI:
      // 1. A livello root (json['requiresVerification'])
      // 2. Dentro data (data?['requiresVerification'])
      // 3. Nei campi speciali per login (json['data']?['requiresVerification'])
      bool requiresVerification = false;

      // Controllo a livello root
      if (json['requiresVerification'] != null) {
        requiresVerification = json['requiresVerification'] as bool;
      }
      // Se non trovato, controlla dentro data
      else if (data != null && data['requiresVerification'] != null) {
        requiresVerification = data['requiresVerification'] as bool;
      }
      // Controllo nel caso login (struttura diversa)
      else if (json['data'] is Map &&
          (json['data'] as Map)['requiresVerification'] != null) {
        requiresVerification =
            (json['data'] as Map)['requiresVerification'] as bool;
      }

      // ✅ GESTIONE MIGLIORATA PER I CAMPI DI SICUREZZA
      bool isLocked = false;
      if (json['locked'] != null) {
        isLocked = json['locked'] as bool;
      } else if (data != null && data['locked'] != null) {
        isLocked = data['locked'] as bool;
      }

      int? lockTime;
      if (json['lockTime'] != null) {
        lockTime = _parseInt(json['lockTime']);
      } else if (data != null && data['lockTime'] != null) {
        lockTime = _parseInt(data['lockTime']);
      }

      int? attemptsLeft;
      if (json['attemptsLeft'] != null) {
        attemptsLeft = _parseInt(json['attemptsLeft']);
      } else if (data != null && data['attemptsLeft'] != null) {
        attemptsLeft = _parseInt(data['attemptsLeft']);
      }

      String? email;
      if (json['email'] != null) {
        email = json['email'] as String;
      } else if (data != null && data['email'] != null) {
        email = data['email'] as String;
      }

      return AuthResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? 'Unknown error',
        data: data,
        requiresVerification: requiresVerification,
        isLocked: isLocked,
        lockTime: lockTime,
        email: email,
        attemptsLeft: attemptsLeft,
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Error parsing response: ${e.toString()}',
      );
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory AuthResponse.networkError(String message) => AuthResponse(
        success: false,
        message: message,
      );

  factory AuthResponse.success(String message, {Map<String, dynamic>? data}) =>
      AuthResponse(
        success: true,
        message: message,
        data: data,
      );

  factory AuthResponse.error(String message) => AuthResponse(
        success: false,
        message: message,
      );

  // Helper per estrarre l'utente dalla risposta
  Map<String, dynamic>? get userData {
    if (data != null && data!.containsKey('user')) {
      return data!['user'] as Map<String, dynamic>;
    }
    return null;
  }

  // Helper per estrarre i token
  String? get token => data?['token'] as String?;
  String? get refreshToken => data?['refreshToken'] as String?;
}
