import 'package:flutter/foundation.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/services/auth_modules/models/auth_data.dart';
import 'package:orsocook/services/auth_modules/models/auth_response.dart';
import 'package:orsocook/services/auth_modules/storage/auth_storage.dart';
import 'package:orsocook/services/auth_modules/api/auth_api_client.dart';
import 'package:orsocook/services/auth_modules/managers/token_manager.dart';

class AuthService extends ChangeNotifier {
  final TokenManager _tokenManager;
  final AuthApiClient _apiClient;

  bool _isLoading = false;
  bool _initialized = false;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _tokenManager.isAuthenticated;
  bool get isVerified => _tokenManager.isVerified;
  String? get token => _tokenManager.accessToken;
  String? get userId => _tokenManager.userId;
  String? get username => _tokenManager.username;
  String? get avatarUrl => _tokenManager.avatarUrl;

  AuthService()
      : _apiClient = AuthApiClient(),
        _tokenManager = TokenManager(
          storage: AuthStorage(),
          apiClient: AuthApiClient(),
        );

  Future<void> initialize() async {
    if (_initialized) {
      if (kDebugMode) {
        AppLogger.debug('🔍 AuthService già inizializzato');
      }
      return;
    }

    _initialized = true;

    try {
      await _tokenManager.initialize();

      if (kDebugMode && _tokenManager.isAuthenticated) {
        AppLogger.success(
            '✅ AuthService inizializzato - Utente: ${_tokenManager.username}');
      } else if (kDebugMode) {
        AppLogger.debug('🔍 AuthService inizializzato - Nessun utente loggato');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('❌ Errore inizializzazione AuthService', e);
      }
    }
  }

  // ==================== REGISTRAZIONE CON VERIFICA ====================
  Future<AuthResponse> registerWithVerification(
    String username,
    String email,
    String password,
  ) async {
    _setLoading(true);

    try {
      final response = await _apiClient.register(username, email, password);

      if (kDebugMode) {
        if (response.success) {
          AppLogger.success('✅ Registrazione avviata per: $email');
        } else {
          AppLogger.error('❌ Registrazione fallita: ${response.message}');
        }
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('❌ Errore registrazione', e);
      }
      return AuthResponse.networkError(
          'Errore di connessione: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // ==================== VERIFICA EMAIL ====================
  Future<AuthResponse> verifyEmail(String token) async {
    _setLoading(true);

    try {
      final response = await _apiClient.verifyEmail(token);

      if (response.success && response.data != null) {
        final Map<String, dynamic> user =
            response.data!['user'] as Map<String, dynamic>;
        final String accessToken = response.data!['token'] as String;
        final String refreshToken = response.data!['refreshToken'] as String;

        final authData = AuthData(
          token: accessToken,
          refreshToken: refreshToken,
          userId: user['id'] as String,
          username: user['username'] as String? ?? user['email'] as String,
          avatarUrl: user['avatarUrl'] as String?,
          isVerified: user['isVerified'] as bool? ?? true,
          tokenExpiry: DateTime.now().add(const Duration(minutes: 14)),
        );

        await _tokenManager.saveAuthData(authData);
        notifyListeners();

        if (kDebugMode) {
          AppLogger.success('✅ Account verificato: ${authData.username}');
        }
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('❌ Errore verifica email', e);
      }
      return AuthResponse.networkError(
          'Errore di connessione: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // ==================== LOGIN ====================
  Future<AuthResponse> login(String email, String password) async {
    _setLoading(true);

    try {
      final response = await _apiClient.login(email, password);

      if (response.success && response.data != null) {
        final Map<String, dynamic> user =
            response.data!['user'] as Map<String, dynamic>;
        final String accessToken = response.data!['token'] as String;
        final String refreshToken = response.data!['refreshToken'] as String;

        final authData = AuthData(
          token: accessToken,
          refreshToken: refreshToken,
          userId: user['id'] as String,
          username: user['username'] as String? ?? email,
          avatarUrl: user['avatarUrl'] as String?,
          isVerified: user['isVerified'] as bool? ?? true,
          tokenExpiry: DateTime.now().add(const Duration(minutes: 14)),
        );

        await _tokenManager.saveAuthData(authData);
        notifyListeners();

        if (kDebugMode) {
          AppLogger.success('✅ Login riuscito: ${authData.username}');
        }
      }

      return response;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('❌ Errore login', e);
      }
      return AuthResponse.networkError(
          'Errore di connessione: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    try {
      if (_tokenManager.accessToken != null) {
        await _apiClient.logout(_tokenManager.accessToken!);
      }
    } catch (e) {
      // Ignora errori backend, procedi con logout locale
    }

    await _tokenManager.clearAuthData();
    notifyListeners();

    if (kDebugMode) {
      AppLogger.success('👋 Utente disconnesso');
    }
  }

  // ==================== OPERAZIONI EMAIL ====================
  Future<AuthResponse> forgotPassword(String email) async {
    _setLoading(true);
    try {
      return await _apiClient.forgotPassword(email);
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResponse> resetPassword(
    String token,
    String password,
    String confirmPassword,
  ) async {
    _setLoading(true);
    try {
      return await _apiClient.resetPassword(token, password, confirmPassword);
    } finally {
      _setLoading(false);
    }
  }

  Future<AuthResponse> resendVerificationEmail(String email) async {
    _setLoading(true);
    try {
      return await _apiClient.resendVerification(email);
    } finally {
      _setLoading(false);
    }
  }

  // ==================== UTILITY ====================
  Future<bool> checkAuth() async {
    return await _tokenManager.getAuthData() != null;
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final authData = await _tokenManager.getAuthData();

    final headers = {'Content-Type': 'application/json'};
    if (authData != null) {
      headers['Authorization'] = 'Bearer ${authData.token}';
    }

    return headers;
  }

  Future<void> updateAvatar(String newAvatarUrl) async {
    await _tokenManager.updateAvatar(newAvatarUrl);
    notifyListeners();

    if (kDebugMode) {
      AppLogger.success('✅ Avatar aggiornato');
    }
  }

  void updateVerificationStatus(bool isVerified) {
    _tokenManager.updateVerificationStatus(isVerified);
    notifyListeners();

    if (kDebugMode) {
      AppLogger.debug('🔧 Stato verifica aggiornato: $isVerified');
    }
  }

  // ==================== METODI PRIVATI ====================
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    notifyListeners();
  }

  void disposeService() {
    _tokenManager.dispose();
  }
}
