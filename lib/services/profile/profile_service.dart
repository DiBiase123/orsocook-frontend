import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:orsocook/models/profile_response.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'strategies/fetch_profile_strategy.dart';
import 'strategies/fetch_user_recipes_strategy.dart';
import 'strategies/fetch_user_favorites_strategy.dart';
import 'strategies/upload_avatar_strategy.dart';

class ProfileService extends ChangeNotifier {
  final AuthService _authService;
  final FetchProfileStrategy _fetchProfileStrategy;
  final FetchUserRecipesStrategy _fetchUserRecipesStrategy;
  final FetchUserFavoritesStrategy _fetchUserFavoritesStrategy;
  final UploadAvatarStrategy _uploadAvatarStrategy;

  ProfileResponse? _currentProfile;
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;

  ProfileService(this._authService)
      : _fetchProfileStrategy = FetchProfileStrategy(_authService),
        _fetchUserRecipesStrategy = FetchUserRecipesStrategy(_authService),
        _fetchUserFavoritesStrategy = FetchUserFavoritesStrategy(_authService),
        _uploadAvatarStrategy = UploadAvatarStrategy(_authService);

  ProfileResponse? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  @override
  void dispose() {
    _isDisposed = true;
    _currentProfile = null;
    _error = null;
    _isLoading = false;
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed && hasListeners) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && hasListeners) notifyListeners();
      });
    }
  }

  void updateAvatarLocally(String newAvatarUrl) {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(
        user: _currentProfile!.user.copyWith(avatarUrl: newAvatarUrl),
      );
      _safeNotify();
      AppLogger.debug('Avatar aggiornato localmente');
    }
  }

  void updateProfile(ProfileResponse newProfile) {
    if (!_isDisposed) {
      _currentProfile = newProfile;
      _error = null;
      _safeNotify();
    }
  }

  Future<ProfileResponse?> fetchUserProfile(String userId,
      {bool force = false}) async {
    AppLogger.debug('📥 fetchUserProfile - userId: $userId, force: $force');

    if (_isDisposed) return _currentProfile;

    if (!force && _currentProfile?.user.id == userId) {
      AppLogger.debug('📦 Usando profilo in cache');
      return _currentProfile;
    }

    if (_isLoading) {
      AppLogger.debug('⏳ Già in caricamento');
      return _currentProfile;
    }

    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      _currentProfile = await _fetchProfileStrategy.execute(userId);
      _error = null;
      AppLogger.success('Profilo caricato - ${_currentProfile?.user.username}');
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Errore: $e', true);
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotify();
      }
    }
    return _currentProfile;
  }

  Future<List<Recipe>> fetchUserRecipes(String userId,
      {int page = 1, int limit = 10}) async {
    try {
      return await _fetchUserRecipesStrategy.execute(userId,
          page: page, limit: limit);
    } catch (e) {
      AppLogger.error('Errore caricamento ricette: $e', true);
      rethrow;
    }
  }

  Future<List<Recipe>> fetchUserFavorites(String userId,
      {int page = 1, int limit = 10}) async {
    try {
      return await _fetchUserFavoritesStrategy.execute(userId,
          page: page, limit: limit);
    } catch (e) {
      AppLogger.error('Errore caricamento preferiti: $e', true);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadAvatar({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    return await _uploadAvatarStrategy.execute(
      imageBytes: imageBytes,
      fileName: fileName,
    );
  }

  Future<ProfileResponse?> refreshProfile() {
    if (_currentProfile != null) {
      return fetchUserProfile(_currentProfile!.user.id, force: true);
    } else if (_authService.userId != null) {
      return fetchUserProfile(_authService.userId!, force: true);
    }
    return Future.value(null);
  }

  void clearProfile() {
    if (!_isDisposed) {
      _currentProfile = null;
      _error = null;
      _isLoading = false;
      _safeNotify();
    }
  }

  void retry() {
    refreshProfile();
  }
}
