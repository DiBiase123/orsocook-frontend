import 'package:shared_preferences/shared_preferences.dart';
import 'package:orsocook/services/auth_modules/models/auth_data.dart';

class AuthStorage {
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'userId';
  static const String _usernameKey = 'username';
  static const String _avatarUrlKey = 'avatarUrl';
  static const String _tokenExpiryKey = 'tokenExpiry';
  static const String _isVerifiedKey = 'isVerified';

  Future<void> saveAuthData(AuthData authData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_tokenKey, authData.token);
      await prefs.setString(_refreshTokenKey, authData.refreshToken);
      await prefs.setString(_userIdKey, authData.userId);
      await prefs.setString(_usernameKey, authData.username);
      await prefs.setBool(_isVerifiedKey, authData.isVerified);
      await prefs.setString(
          _tokenExpiryKey, authData.tokenExpiry.toIso8601String());

      if (authData.avatarUrl != null) {
        await prefs.setString(_avatarUrlKey, authData.avatarUrl!);
      } else {
        await prefs.remove(_avatarUrlKey);
      }
    } catch (e) {
      throw Exception('Failed to save auth data: $e');
    }
  }

  Future<AuthData?> loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString(_tokenKey);
      final refreshToken = prefs.getString(_refreshTokenKey);
      final userId = prefs.getString(_userIdKey);
      final username = prefs.getString(_usernameKey);
      final avatarUrl = prefs.getString(_avatarUrlKey);
      final isVerified = prefs.getBool(_isVerifiedKey) ?? false;
      final expiryString = prefs.getString(_tokenExpiryKey);

      // Se manca qualche campo essenziale, restituisci null
      if (token == null ||
          refreshToken == null ||
          userId == null ||
          username == null ||
          expiryString == null) {
        return null;
      }

      return AuthData(
        token: token,
        refreshToken: refreshToken,
        userId: userId,
        username: username,
        avatarUrl: avatarUrl,
        isVerified: isVerified,
        tokenExpiry: DateTime.parse(expiryString),
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> updateAvatar(String avatarUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_avatarUrlKey, avatarUrl);
    } catch (e) {
      throw Exception('Failed to update avatar: $e');
    }
  }

  Future<void> updateVerificationStatus(bool isVerified) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isVerifiedKey, isVerified);
    } catch (e) {
      throw Exception('Failed to update verification status: $e');
    }
  }

  Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_usernameKey);
      await prefs.remove(_avatarUrlKey);
      await prefs.remove(_tokenExpiryKey);
      await prefs.remove(_isVerifiedKey);
    } catch (e) {
      throw Exception('Failed to clear auth data: $e');
    }
  }

  Future<bool> hasStoredCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey) != null &&
          prefs.getString(_userIdKey) != null;
    } catch (e) {
      return false;
    }
  }
}
