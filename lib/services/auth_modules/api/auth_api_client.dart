import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:orsocook/config.dart';
import 'package:orsocook/services/auth_modules/models/auth_response.dart';

class AuthApiClient {
  final String baseUrl;

  AuthApiClient({String? baseUrl}) : baseUrl = baseUrl ?? Config.buildUrl();

  Future<AuthResponse> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      return AuthResponse.fromHttpResponse(response);
    } catch (e) {
      return AuthResponse.networkError('Connection error: ${e.toString()}');
    }
  }

  Future<AuthResponse> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      return AuthResponse.fromHttpResponse(response);
    } catch (e) {
      return AuthResponse.networkError('Connection error: ${e.toString()}');
    }
  }

  Future<AuthResponse> postWithToken(
    String endpoint,
    Map<String, dynamic> body,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      return AuthResponse.fromHttpResponse(response);
    } catch (e) {
      return AuthResponse.networkError('Connection error: ${e.toString()}');
    }
  }

  // Metodi specifici per operazioni auth
  Future<AuthResponse> login(String email, String password) async {
    return await post('login', {'email': email, 'password': password});
  }

  Future<AuthResponse> register(
    String username,
    String email,
    String password,
  ) async {
    return await post('register', {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<AuthResponse> verifyEmail(String token) async {
    return await get('verify-email/$token');
  }

  Future<AuthResponse> forgotPassword(String email) async {
    return await post('forgot-password', {'email': email});
  }

  Future<AuthResponse> resetPassword(
    String token,
    String password,
    String confirmPassword,
  ) async {
    return await post('reset-password/$token', {
      'password': password,
      'confirmPassword': confirmPassword,
    });
  }

  Future<AuthResponse> resendVerification(String email) async {
    return await post('resend-verification', {'email': email});
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    return await post('refresh', {'refreshToken': refreshToken});
  }

  Future<AuthResponse> logout(String token) async {
    return await postWithToken('logout', {}, token);
  }
}
