import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import 'package:orsocook/config.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/models/user_profile.dart';
import 'package:orsocook/services/auth_service.dart';

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
          .map((recipe) => Recipe.fromJson(recipe))
          .toList(),
      recentFavorites: (json['recentFavorites'] as List)
          .map((recipe) => Recipe.fromJson(recipe))
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

  ProfileService(AuthService authService) : _authService = authService;

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

  void updateAvatarLocally(String newAvatarUrl) {
    if (_currentProfile != null) {
      final updatedUser =
          _currentProfile!.user.copyWith(avatarUrl: newAvatarUrl);
      _currentProfile = _currentProfile!.copyWith(user: updatedUser);
      _safeNotify();
      if (kDebugMode) {
        print(
            '✅ ProfileService: Avatar aggiornato localmente a: $newAvatarUrl');
      }
    } else {
      if (kDebugMode) {
        print(
            '⚠️ ProfileService: Nessun profilo corrente per aggiornare l\'avatar');
      }
    }
  }

  void updateProfile(ProfileResponse newProfile) {
    if (_isDisposed) return;

    _currentProfile = newProfile;
    _error = null;
    _safeNotify();

    if (kDebugMode) {
      print('🔄 ProfileService: Profile updated via updateProfile()');
      print('🔄 ProfileService: New avatar URL: ${newProfile.user.avatarUrl}');
    }
  }

  Future<ProfileResponse?> fetchUserProfile(String userId) async {
    if (_isDisposed) return _currentProfile;

    if (_isLoading) {
      if (kDebugMode) {
        print('⏳ ProfileService: Already loading, returning current profile');
      }
      return _currentProfile;
    }

    _isLoading = true;
    _error = null;
    _safeNotify();

    try {
      final token = _authService.token;
      if (token == null) {
        _error = 'Utente non autenticato';
        _isLoading = false;
        _safeNotify();
        return null;
      }

      final url = '${Config.apiBaseUrl}/api/auth/profile/$userId';
      if (kDebugMode) {
        print('🔄 ProfileService: Fetching profile from: $url');
        print('🔄 ProfileService: User ID: $userId');
        print('🔄 ProfileService: Has listeners: $hasListeners');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (kDebugMode) {
        print('📥 ProfileService: Response status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final avatarUrl = data['data']['user']['avatarUrl'];
          if (kDebugMode) {
            print('✅ ProfileService: Avatar URL in response: $avatarUrl');
          }

          _currentProfile = ProfileResponse.fromJson(data['data']);
          _error = null;

          if (kDebugMode) {
            print('✅ ProfileService: Profile loaded successfully');
            print(
                '✅ ProfileService: Current avatar URL: ${_currentProfile!.user.avatarUrl}');
          }

          _safeNotify();
        } else {
          _error = data['message'] ?? 'Errore nel recupero del profilo';
          if (kDebugMode) {
            print('❌ ProfileService: API error: $_error');
          }
        }
      } else if (response.statusCode == 401) {
        _error = 'Sessione scaduta. Effettua nuovamente il login.';
      } else if (response.statusCode == 403) {
        _error = 'Non autorizzato ad accedere a questo profilo';
      } else if (response.statusCode == 404) {
        _error = 'Profilo utente non trovato';
      } else {
        _error = 'Errore server: ${response.statusCode}';
        if (kDebugMode) {
          print('❌ ProfileService: HTTP error ${response.statusCode}');
        }
      }
    } catch (e) {
      _error = 'Errore di connessione: $e';
      if (kDebugMode) {
        print('❌ ProfileService: Exception: $e');
      }
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotify();
      }

      if (kDebugMode) {
        print(
            '🏁 ProfileService: Fetch completed. Has profile: ${_currentProfile != null}');
      }
    }

    return _currentProfile;
  }

  Future<List<Recipe>> fetchUserRecipes(String userId,
      {int page = 1, int limit = 10}) async {
    try {
      final token = _authService.token;

      if (token == null) {
        throw Exception('Utente non autenticato');
      }

      final response = await http.get(
        Uri.parse(
            '${Config.apiBaseUrl}/api/recipes/user/$userId?page=$page&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          final recipesData = data['data']['recipes'] as List;
          return recipesData.map((recipe) => Recipe.fromJson(recipe)).toList();
        } else {
          throw Exception(
              data['message'] ?? 'Errore nel recupero delle ricette');
        }
      } else {
        throw Exception('Errore server: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Fetch user recipes error: $e');
      }
      rethrow;
    }
  }

  void clearProfile() {
    if (_isDisposed) return;

    _currentProfile = null;
    _error = null;
    _isLoading = false;
    _safeNotify();
  }

  void retry() {
    if (_isDisposed) return;

    if (_currentProfile != null) {
      fetchUserProfile(_currentProfile!.user.id);
    } else if (_authService.userId != null) {
      fetchUserProfile(_authService.userId!);
    }
  }

  @override
  void dispose() {
    super.dispose(); // ← CHIAMA PRIMA super.dispose()
    _isDisposed = true; // ← POI il tuo codice
  }
}
