import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:orsocook/config.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/models/user_profile.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';

class ProfileResponse {
  final UserProfile user;
  final UserStats stats;
  final List<Recipe> recentRecipes;
  final List<Recipe> recentFavorites;

  ProfileResponse({
    required this.user,
    required this.stats,
    required this.recentRecipes,
    required this.recentFavorites,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      user: UserProfile.fromJson(json['user']),
      stats: UserStats.fromJson(json['stats']),
      recentRecipes: (json['recentRecipes'] as List)
          .map((r) => Recipe.fromJson(r))
          .toList(),
      recentFavorites: (json['recentFavorites'] as List)
          .map((r) => Recipe.fromJson(r))
          .toList(),
    );
  }

  ProfileResponse copyWith({UserProfile? user}) {
    return ProfileResponse(
      user: user ?? this.user,
      stats: stats,
      recentRecipes: recentRecipes,
      recentFavorites: recentFavorites,
    );
  }
}

class ProfileService extends ChangeNotifier {
  final AuthService _authService;
  ProfileResponse? _currentProfile;
  bool _isLoading = false;
  String? _error;
  bool _isDisposed = false;
  static const _timeout = Duration(seconds: 15);

  ProfileService(this._authService);

  ProfileResponse? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _safeNotify() {
    if (!_isDisposed && hasListeners) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && hasListeners) {
          notifyListeners();
        }
      });
    }
  }

  void _log(String msg, [bool isError = false]) {
    if (kDebugMode) {
      debugPrint('${isError ? '❌' : '✅'} ProfileService: $msg');
    }
    if (isError) {
      AppLogger.error('ProfileService: $msg');
    } else {
      AppLogger.success('ProfileService: $msg');
    }
  }

  void updateAvatarLocally(String newAvatarUrl) {
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(
        user: _currentProfile!.user.copyWith(avatarUrl: newAvatarUrl),
      );
      _safeNotify();
      _log('Avatar aggiornato localmente');
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
    if (_isDisposed) return _currentProfile;
    if (!force && _currentProfile?.user.id == userId) return _currentProfile;
    if (_isLoading) return _currentProfile;

    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final token = _authService.token;
      if (token == null) {
        throw 'Utente non autenticato';
      }

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/auth/profile/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _currentProfile = ProfileResponse.fromJson(data['data']);
          _error = null;
          _log('Profilo caricato');
        } else {
          throw data['message'] ?? 'Errore profilo';
        }
      } else {
        throw _handleHttpError(response.statusCode);
      }
    } catch (e) {
      _error = e.toString();
      _log('Errore: $e', true);
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
    return _fetchList(
        '${Config.apiBaseUrl}/api/recipes/user/$userId?page=$page&limit=$limit',
        'ricette');
  }

  Future<List<Recipe>> fetchUserFavorites(String userId,
      {int page = 1, int limit = 10}) async {
    return _fetchList(
        '${Config.apiBaseUrl}/api/favorites/user/$userId?page=$page&limit=$limit',
        'preferiti');
  }

  Future<List<Recipe>> _fetchList(String url, String type) async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw 'Utente non autenticato';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> items =
            data['success'] == true ? data['data'] : (data is List ? data : []);
        final recipes = items.map((r) => Recipe.fromJson(r)).toList();
        _log('Caricate ${recipes.length} $type');
        return recipes;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw _handleHttpError(response.statusCode);
      }
    } catch (e) {
      _log('Errore caricamento $type: $e', true);
      rethrow;
    }
  }

  String _handleHttpError(int code) {
    switch (code) {
      case 401:
        return 'Sessione scaduta';
      case 403:
        return 'Non autorizzato';
      case 404:
        return 'Non trovato';
      default:
        return 'Errore server: $code';
    }
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

  @override
  void dispose() {
    _isDisposed = true;
    _currentProfile = null;
    _error = null;
    _isLoading = false;
    super.dispose();
  }
}
