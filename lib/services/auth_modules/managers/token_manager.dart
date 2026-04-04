import 'dart:async';
import 'package:orsocook/services/auth_modules/models/auth_data.dart';
import 'package:orsocook/services/auth_modules/models/token_pair.dart';
import 'package:orsocook/services/auth_modules/api/auth_api_client.dart';
import 'package:orsocook/services/auth_modules/storage/auth_storage.dart';
import 'package:orsocook/utils/logger.dart';

class TokenManager {
  final AuthStorage _storage;
  final AuthApiClient _apiClient;

  AuthData? _currentAuthData;
  Timer? _tokenRefreshTimer;
  bool _isRefreshing = false;
  bool _refreshFailed = false;

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

    if (_currentAuthData != null && _currentAuthData!.isTokenExpired) {
      AppLogger.debug('🔄 [TOKEN] Token scaduto, tentativo refresh');
      final refreshed = await refreshToken();
      if (!refreshed) {
        AppLogger.error('❌ [TOKEN] Refresh fallito, utente disconnesso');
        return null;
      }
    }

    return _currentAuthData;
  }

  Future<bool> refreshToken() async {
    // Se già in errore, non riprovare
    if (_refreshFailed) {
      AppLogger.debug('⏭️ [TOKEN] Refresh già fallito, salto');
      return false;
    }

    // Se già in corso, salta
    if (_isRefreshing) {
      AppLogger.debug('⏭️ [TOKEN] Refresh già in corso, salto');
      return false;
    }

    if (_currentAuthData == null || !_currentAuthData!.canRefresh) {
      AppLogger.debug('⏭️ [TOKEN] Impossibile refresh: no refresh token');
      return false;
    }

    _isRefreshing = true;

    try {
      AppLogger.debug('🔄 [TOKEN] Tentativo refresh token');
      final response =
          await _apiClient.refreshToken(_currentAuthData!.refreshToken);

      if (response.success && response.data != null) {
        final tokenPair = TokenPair.fromApiResponse(response.data!);

        final updatedAuthData = AuthData(
          token: tokenPair.accessToken,
          refreshToken: tokenPair.refreshToken,
          userId: _currentAuthData!.userId,
          username: _currentAuthData!.username,
          avatarUrl: _currentAuthData!.avatarUrl,
          isVerified: _currentAuthData!.isVerified,
          tokenExpiry: tokenPair.expiresAt,
        );

        await saveAuthData(updatedAuthData);
        _refreshFailed = false;
        AppLogger.success('✅ [TOKEN] Token refreshato con successo');
        return true;
      }

      _refreshFailed = true;
      AppLogger.error('❌ [TOKEN] Refresh fallito: ${response.message}');
      return false;
    } catch (e) {
      _refreshFailed = true;
      AppLogger.error('❌ [TOKEN] Errore refresh', e);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> updateTokens(
      String newAccessToken, String newRefreshToken) async {
    if (_currentAuthData != null) {
      final updated = AuthData(
        token: newAccessToken,
        refreshToken: newRefreshToken,
        userId: _currentAuthData!.userId,
        username: _currentAuthData!.username,
        avatarUrl: _currentAuthData!.avatarUrl,
        isVerified: _currentAuthData!.isVerified,
        tokenExpiry: DateTime.now().add(const Duration(hours: 6)),
      );
      await saveAuthData(updated);
      _refreshFailed = false;
      AppLogger.success('✅ [TOKEN] Token aggiornati manualmente');
    }
  }

  Future<void> saveAuthData(AuthData authData) async {
    await _storage.saveAuthData(authData);
    _currentAuthData = authData;
    _refreshFailed = false;
    _setupTokenRefreshTimer();
  }

  Future<void> clearAuthData() async {
    await _storage.clearAuthData();
    _currentAuthData = null;
    _refreshFailed = false;
    _cancelTokenRefreshTimer();
    AppLogger.debug('🧹 [TOKEN] Auth data cancellati');
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

    if (_refreshFailed) {
      AppLogger.debug('⏭️ [TOKEN] Refresh fallito, timer non avviato');
      return;
    }

    if (_currentAuthData == null || _currentAuthData!.isTokenExpired) {
      return;
    }

    final refreshTime = _currentAuthData!.tokenExpiry
        .subtract(const Duration(hours: 1))
        .difference(DateTime.now());

    if (refreshTime.isNegative) {
      Timer.run(() => refreshToken());
      return;
    }

    _tokenRefreshTimer = Timer(refreshTime, () async {
      await refreshToken();
      _setupTokenRefreshTimer();
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
