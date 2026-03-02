import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orsocook/services/avatar_service.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/profile_service.dart';
import 'package:orsocook/services/comment_service.dart';
import 'package:orsocook/services/favorite_service.dart';
import 'package:orsocook/models/recipe.dart';
import 'package:orsocook/models/user_profile.dart';
import 'package:orsocook/utils/logger.dart';

class ProfileController extends ChangeNotifier {
  // Dependencies
  final AuthService _authService;
  final ProfileService _profileService;
  final AvatarService _avatarService;
  final CommentService _commentService;
  final FavoriteService _favoriteService;

  // State
  XFile? _selectedAvatarXFile;
  Uint8List? _selectedAvatarBytes;
  bool _isChangingAvatar = false;
  bool _isPickingAvatar = false;
  int _selectedTabIndex = 0;
  String? _lastSuccessMessage;
  bool _isDisposed = false;
  bool _isRefreshing = false; // 👈 AGGIUNTO per evitare doppi refresh

  // Getters
  XFile? get selectedAvatar => _selectedAvatarXFile;
  Uint8List? get selectedAvatarBytes => _selectedAvatarBytes;
  bool get isChangingAvatar => _isChangingAvatar;
  bool get isPickingAvatar => _isPickingAvatar;
  int get selectedTabIndex => _selectedTabIndex;
  String? get lastSuccessMessage => _lastSuccessMessage;
  bool get isLoading => _profileService.isLoading;
  String? get error => _profileService.error;
  bool get hasProfile => _profileService.currentProfile != null;

  // TIPI CORRETTI
  UserProfile? get userProfile => _profileService.currentProfile?.user;
  UserStats? get userStats => _profileService.currentProfile?.stats;
  List<Recipe>? get recentRecipes =>
      _profileService.currentProfile?.recentRecipes;
  List<Recipe>? get recentFavorites =>
      _profileService.currentProfile?.recentFavorites;

  bool get isShowingTempAvatar => _selectedAvatarXFile != null;
  bool get isBusy =>
      _isChangingAvatar || _isPickingAvatar || _profileService.isLoading;

  String? get displayAvatarUrl {
    if (_selectedAvatarXFile != null) return null;
    final profileAvatar = _profileService.currentProfile?.user.avatarUrl;
    final authAvatar = _authService.avatarUrl;
    return profileAvatar ?? authAvatar;
  }

  ProfileController({
    required AuthService authService,
    required ProfileService profileService,
    required AvatarService avatarService,
    required CommentService commentService,
    required FavoriteService favoriteService,
  })  : _authService = authService,
        _profileService = profileService,
        _avatarService = avatarService,
        _commentService = commentService,
        _favoriteService = favoriteService {
    _isDisposed = false;
    _favoriteService.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoriteService.removeListener(_onFavoritesChanged);
    _isDisposed = true;
    super.dispose();
  }

  // ================ FAVORITES SYNC ================
  void _onFavoritesChanged() {
    if (!_isDisposed && !_isRefreshing) {
      _isRefreshing = true;
      AppLogger.debug(
          '🔄 [PROFILE] Preferiti cambiati, ricarico profilo completo');
      _refreshFullProfile().whenComplete(() {
        _isRefreshing = false;
      });
    }
  }

  // 👈 NUOVO: Ricarica TUTTO il profilo
  Future<void> _refreshFullProfile() async {
    try {
      final userId = _authService.userId;
      if (userId != null) {
        AppLogger.debug(
            '📦 [PROFILE] Ricarico profilo completo per user $userId');

        // Forza il refresh COMPLETO del profilo
        await _profileService.fetchUserProfile(userId, force: true);

        AppLogger.debug('✅ [PROFILE] Profilo aggiornato completamente');
      }
    } catch (e) {
      AppLogger.error('❌ [PROFILE] Errore refresh profilo', e);
    }
  }

  // ================ AVATAR MANAGEMENT ================

  Future<void> pickAvatarImage() async {
    if (_isDisposed || _isPickingAvatar) return;

    _isPickingAvatar = true;
    _safeNotify();

    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final sizeInMB = bytes.length / (1024 * 1024);

        if (sizeInMB > 5.0) {
          throw Exception(
              'L\'immagine è troppo grande (${sizeInMB.toStringAsFixed(1)}MB). Massimo 5MB');
        }

        _selectedAvatarXFile = pickedFile;
        _selectedAvatarBytes = bytes;
        _safeNotify();
      }
    } catch (e) {
      if (!_isDisposed) rethrow;
    } finally {
      _isPickingAvatar = false;
      _safeNotify();
    }
  }

  Future<Map<String, dynamic>> uploadAvatar() async {
    if (_isDisposed ||
        _selectedAvatarXFile == null ||
        _selectedAvatarBytes == null) {
      return {
        'success': false,
        'message': 'Controller dismesso o nessuna immagine'
      };
    }

    _isChangingAvatar = true;
    _lastSuccessMessage = null;
    _safeNotify();

    try {
      final result = await _avatarService.uploadAvatar(
        imageBytes: _selectedAvatarBytes!,
        fileName: _selectedAvatarXFile!.name,
      );

      if (result['success'] == true) {
        final newAvatarUrl = result['avatarUrl'] as String?;
        final userId = _authService.userId;
        _lastSuccessMessage = result['message'];

        if (newAvatarUrl != null && _authService.isLoggedIn) {
          _authService.updateAvatar(newAvatarUrl);
        }

        if (newAvatarUrl != null) {
          _profileService.updateAvatarLocally(newAvatarUrl);
        }

        if (userId != null && newAvatarUrl != null) {
          try {
            _commentService.updateAvatarInComments(userId, newAvatarUrl);
          } catch (e) {
            // Ignora errori secondari
          }
        }

        _safeNotify();
        await refreshProfile();
        _selectedAvatarXFile = null;
        _selectedAvatarBytes = null;

        return {
          'success': true,
          'message': _lastSuccessMessage,
          'avatarUrl': newAvatarUrl,
        };
      } else {
        _lastSuccessMessage = result['message'] ?? 'Errore durante l\'upload';
        _safeNotify();

        return {
          'success': false,
          'message': _lastSuccessMessage,
        };
      }
    } catch (e) {
      if (!_isDisposed) {
        _isChangingAvatar = false;
        _lastSuccessMessage = 'Errore durante l\'upload: $e';
        _safeNotify();
      }

      return {
        'success': false,
        'message': _lastSuccessMessage,
      };
    } finally {
      if (!_isDisposed) {
        _isChangingAvatar = false;
        _safeNotify();
      }
    }
  }

  void clearSelectedAvatar() {
    if (_isDisposed) return;
    _selectedAvatarXFile = null;
    _selectedAvatarBytes = null;
    _safeNotify();
  }

  void clearSuccessMessage() {
    if (_isDisposed) return;
    _lastSuccessMessage = null;
    _safeNotify();
  }

  // ================ PROFILE MANAGEMENT ================

  Future<void> loadProfile() async {
    if (_isDisposed) return;

    final userId = _authService.userId;
    if (userId != null) {
      await _profileService.fetchUserProfile(userId);
      _safeNotify();
    }
  }

  Future<void> refreshProfile() async {
    if (_isDisposed) return;
    await loadProfile();
  }

  Future<void> logout() async {
    if (_isDisposed) return;

    try {
      // Svuota cache preferiti PRIMA del logout
      _favoriteService.clearCache();

      await _authService.logout();
      _profileService.clearProfile();
      _selectedAvatarXFile = null;
      _selectedAvatarBytes = null;
      _lastSuccessMessage = null;
      _safeNotify();
    } catch (e) {
      if (!_isDisposed) rethrow;
    }
  }

  void retry() {
    if (_isDisposed) return;
    _profileService.retry();
    _safeNotify();
  }

  // ================ TAB MANAGEMENT ================

  void selectTab(int index) {
    if (_isDisposed) return;
    _selectedTabIndex = index;
    _safeNotify();
  }

  // ================ UTILITY ================

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // ================ SAFE NOTIFY ================

  void _safeNotify() {
    if (!_isDisposed && hasListeners) {
      Future.microtask(() {
        if (!_isDisposed && hasListeners) {
          notifyListeners();
        }
      });
    }
  }
}
