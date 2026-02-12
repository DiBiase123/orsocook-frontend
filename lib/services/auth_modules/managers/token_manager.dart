import 'dart:async';
import 'package:orsocook/services/auth_modules/models/auth_data.dart';
import 'package:orsocook/services/auth_modules/models/token_pair.dart';
import 'package:orsocook/services/auth_modules/api/auth_api_client.dart';
import 'package:orsocook/services/auth_modules/storage/auth_storage.dart';

class TokenManager {
  final AuthStorage _storage;
  final AuthApiClient _apiClient;

  AuthData? _currentAuthData;
  Timer? _tokenRefreshTimer;

  TokenManager({
    required AuthStorage storage,
    required AuthApiClient apiClient,
  })  : _storage = storage,
        _apiClient = apiClient;

  Future<void> initialize() async {
    _currentAuthData = await _storage.loadAuthData();
    _setupTokenRefreshTimer();
  }

  Future<AuthData?> getAuthData() async {
    _currentAuthData ??= await _storage.loadAuthData();

    // Se il token è scaduto, prova a refresharlo
    if (_currentAuthData != null && _currentAuthData!.isTokenExpired) {
      final refreshed = await refreshToken();
      if (!refreshed) {
        return null;
      }
    }

    return _currentAuthData;
  }

  Future<bool> refreshToken() async {
    if (_currentAuthData == null || !_currentAuthData!.canRefresh) {
      return false;
    }

    try {
      final response =
          await _apiClient.refreshToken(_currentAuthData!.refreshToken);

      if (response.success && response.data != null) {
        final tokenPair = TokenPair.fromApiResponse(response.data!);

        // Aggiorna AuthData con nuovo token
        final updatedAuthData = AuthData(
          token: tokenPair.accessToken,
          refreshToken: _currentAuthData!
              .refreshToken, // Mantieni lo stesso refresh token
          userId: _currentAuthData!.userId,
          username: _currentAuthData!.username,
          avatarUrl: _currentAuthData!.avatarUrl,
          isVerified: _currentAuthData!.isVerified,
          tokenExpiry: tokenPair.expiresAt,
        );

        await saveAuthData(updatedAuthData);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveAuthData(AuthData authData) async {
    await _storage.saveAuthData(authData);
    _currentAuthData = authData;
    _setupTokenRefreshTimer();
  }

  Future<void> clearAuthData() async {
    await _storage.clearAuthData();
    _currentAuthData = null;
    _cancelTokenRefreshTimer();
  }

  Future<void> updateAvatar(String avatarUrl) async {
    if (_currentAuthData != null) {
      await _storage.updateAvatar(avatarUrl);
      _currentAuthData = _currentAuthData!.copyWith(avatarUrl: avatarUrl);
    }
  }

  Future<void> updateVerificationStatus(bool isVerified) async {
    if (_currentAuthData != null) {
      await _storage.updateVerificationStatus(isVerified);
      _currentAuthData = _currentAuthData!.copyWith(isVerified: isVerified);
    }
  }

  bool get isAuthenticated =>
      _currentAuthData != null && !_currentAuthData!.isTokenExpired;
  String? get accessToken => _currentAuthData?.token;
  String? get userId => _currentAuthData?.userId;
  String? get username => _currentAuthData?.username;
  String? get avatarUrl => _currentAuthData?.avatarUrl;
  bool get isVerified => _currentAuthData?.isVerified ?? false;

  void _setupTokenRefreshTimer() {
    _cancelTokenRefreshTimer();

    if (_currentAuthData == null || _currentAuthData!.isTokenExpired) {
      return;
    }

    // Calcola quando refreshare (5 minuti prima della scadenza)
    final refreshTime = _currentAuthData!.tokenExpiry
        .subtract(const Duration(minutes: 5))
        .difference(DateTime.now());

    if (refreshTime.isNegative) {
      // Se già meno di 5 minuti, refresh immediato
      Timer.run(() => refreshToken());
      return;
    }

    _tokenRefreshTimer = Timer(refreshTime, () async {
      await refreshToken();
      _setupTokenRefreshTimer(); // Ricalcola per il prossimo refresh
    });
  }

  void _cancelTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  void dispose() {
    _cancelTokenRefreshTimer();
  }
}
