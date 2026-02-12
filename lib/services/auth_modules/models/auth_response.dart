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

      return AuthResponse(
        success: json['success'] as bool? ?? false,
        message: json['message'] as String? ?? 'Unknown error',
        data: json['data'] as Map<String, dynamic>?,
        requiresVerification: json['requiresVerification'] as bool? ?? false,
        isLocked: json['locked'] as bool? ?? false,
        lockTime: _parseInt(json['lockTime']),
        email: json['email'] as String?,
        attemptsLeft: _parseInt(json['attemptsLeft']),
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
