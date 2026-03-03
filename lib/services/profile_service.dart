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
    AppLogger.debug('📦 [PROFILE_SERVICE] Parsing ProfileResponse');

    final user = UserProfile.fromJson(json['user']);
    final stats = UserStats.fromJson(json['stats']);

    final recentRecipes = (json['recentRecipes'] as List)
        .map((r) {
          try {
            return Recipe.fromJson(r);
          } catch (e) {
            AppLogger.error(
                '❌ [PROFILE_SERVICE] Errore parsing ricetta recente', e);
            return null;
          }
        })
        .whereType<Recipe>()
        .toList();

    final recentFavorites = (json['recentFavorites'] as List)
        .map((r) {
          try {
            return Recipe.fromJson(r);
          } catch (e) {
            AppLogger.error('❌ [PROFILE_SERVICE] Errore parsing preferito', e);
            return null;
          }
        })
        .whereType<Recipe>()
        .toList();

    // A (CORRETTO):
    AppLogger.debug(
        '✅ [PROFILE_SERVICE] Parsed: user=${user.username}, stats=${stats.recipesCount} ricette, ${recentFavorites.length} preferiti');
    return ProfileResponse(
      user: user,
      stats: stats,
      recentRecipes: recentRecipes,
      recentFavorites: recentFavorites,
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
    AppLogger.debug('🖼️ [PROFILE_SERVICE] updateAvatarLocally: $newAvatarUrl');
    if (_currentProfile != null) {
      _currentProfile = _currentProfile!.copyWith(
        user: _currentProfile!.user.copyWith(avatarUrl: newAvatarUrl),
      );
      _safeNotify();
      _log('Avatar aggiornato localmente');
    }
  }

  void updateProfile(ProfileResponse newProfile) {
    AppLogger.debug('📝 [PROFILE_SERVICE] updateProfile');
    if (!_isDisposed) {
      _currentProfile = newProfile;
      _error = null;
      _safeNotify();
    }
  }

  Future<ProfileResponse?> fetchUserProfile(String userId,
      {bool force = false}) async {
    AppLogger.debug(
        '📥 [PROFILE_SERVICE] fetchUserProfile chiamato - userId: $userId, force: $force');

    if (_isDisposed) {
      AppLogger.debug('⚠️ [PROFILE_SERVICE] Service dismesso');
      return _currentProfile;
    }

    if (!force && _currentProfile?.user.id == userId) {
      AppLogger.debug('📦 [PROFILE_SERVICE] Usando profilo in cache');
      return _currentProfile;
    }

    if (_isLoading) {
      AppLogger.debug('⏳ [PROFILE_SERVICE] Già in caricamento');
      return _currentProfile;
    }

    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final token = _authService.token;
      if (token == null) {
        throw 'Utente non autenticato';
      }

      final url = '${Config.apiBaseUrl}/api/auth/profile/$userId';
      AppLogger.api('GET /api/auth/profile/$userId');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      ).timeout(_timeout);

      AppLogger.debug(
          '📥 [PROFILE_SERVICE] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _currentProfile = ProfileResponse.fromJson(data['data']);
          _error = null;
          _log('Profilo caricato - ${_currentProfile?.user.username}');
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
    AppLogger.debug(
        '📦 [PROFILE_SERVICE] fetchUserRecipes - page: $page, limit: $limit');
    return _fetchList(
        '${Config.apiBaseUrl}/api/recipes/user/$userId?page=$page&limit=$limit',
        'ricette');
  }

  Future<List<Recipe>> fetchUserFavorites(String userId,
      {int page = 1, int limit = 10}) async {
    AppLogger.debug(
        '📦 [PROFILE_SERVICE] fetchUserFavorites - page: $page, limit: $limit');
    // URL corretto senza /user/$userId
    return _fetchList(
        '${Config.apiBaseUrl}/api/favorites?page=$page&limit=$limit',
        'preferiti');
  }

  Future<List<Recipe>> _fetchList(String url, String type) async {
    try {
      final token = _authService.token;
      if (token == null) {
        throw 'Utente non autenticato';
      }

      AppLogger.api('GET ${url.replaceAll(Config.apiBaseUrl, '')}');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      ).timeout(_timeout);

      AppLogger.debug(
          '📥 [PROFILE_SERVICE] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);

        List<dynamic> items = [];
        if (data is Map) {
          if (data['success'] == true && data['data'] != null) {
            items = data['data'] is List ? data['data'] : [];
          } else if (data['data'] is List) {
            items = data['data'];
          }
        } else if (data is List) {
          items = data;
        }

        AppLogger.debug('📦 [PROFILE_SERVICE] Ricevuti ${items.length} items');

        final recipes = <Recipe>[];
        for (var i = 0; i < items.length; i++) {
          try {
            final recipe = Recipe.fromJson(items[i]);
            recipes.add(recipe);
            AppLogger.debug('   ✅ ${i + 1}. ${recipe.title} (${recipe.id})');
          } catch (e) {
            AppLogger.error('❌ [PROFILE_SERVICE] Errore parsing item $i', e);
          }
        }

        _log('Caricate ${recipes.length} $type su ${items.length} totali');
        return recipes;
      } else if (response.statusCode == 404) {
        AppLogger.debug('📭 [PROFILE_SERVICE] Nessun $type trovato (404)');
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
    AppLogger.debug('🔄 [PROFILE_SERVICE] refreshProfile');
    if (_currentProfile != null) {
      return fetchUserProfile(_currentProfile!.user.id, force: true);
    } else if (_authService.userId != null) {
      return fetchUserProfile(_authService.userId!, force: true);
    }
    return Future.value(null);
  }

  void clearProfile() {
    AppLogger.debug('🧹 [PROFILE_SERVICE] clearProfile');
    if (!_isDisposed) {
      _currentProfile = null;
      _error = null;
      _isLoading = false;
      _safeNotify();
    }
  }

  void retry() {
    AppLogger.debug('🔄 [PROFILE_SERVICE] retry');
    refreshProfile();
  }

  @override
  void dispose() {
    AppLogger.debug('🗑️ [PROFILE_SERVICE] dispose');
    _isDisposed = true;
    _currentProfile = null;
    _error = null;
    _isLoading = false;
    super.dispose();
  }
}
