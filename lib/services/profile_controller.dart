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
    AppLogger.debug('📱 [PROFILE] ProfileController inizializzato');
  }

  @override
  void dispose() {
    _favoriteService.removeListener(_onFavoritesChanged);
    _isDisposed = true;
    AppLogger.debug('🗑️ [PROFILE] ProfileController disposto');
    super.dispose();
  }

  // ================ FAVORITES SYNC ================
  void _onFavoritesChanged() {
    AppLogger.debug('🔔 [PROFILE] _onFavoritesChanged - preferiti cambiati!');
    if (!_isDisposed) {
      AppLogger.debug('🔄 [PROFILE] Ricarico profilo completo');
      _refreshFullProfile();
    }
  }

  Future<void> _refreshFullProfile() async {
    try {
      final userId = _authService.userId;
      if (userId != null) {
        AppLogger.debug('📦 [PROFILE] Ricarico profilo per user $userId');
        await _profileService.fetchUserProfile(userId, force: true);
        AppLogger.success(
            '✅ [PROFILE] Profilo aggiornato dopo cambio preferiti');
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
              'Immagine troppo grande (${sizeInMB.toStringAsFixed(1)}MB). Max 5MB');
        }

        _selectedAvatarXFile = pickedFile;
        _selectedAvatarBytes = bytes;
        AppLogger.debug(
            '🖼️ [PROFILE] Immagine selezionata: ${pickedFile.name}');
        _safeNotify();
      }
    } catch (e) {
      AppLogger.error('❌ [PROFILE] Errore selezione avatar', e);
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
      return {'success': false, 'message': 'Nessuna immagine'};
    }

    _isChangingAvatar = true;
    _lastSuccessMessage = null;
    _safeNotify();

    try {
      AppLogger.debug('📤 [PROFILE] Upload avatar iniziato');
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
            AppLogger.error('❌ [PROFILE] Errore aggiornamento commenti', e);
          }
        }

        _safeNotify();
        await refreshProfile();
        _selectedAvatarXFile = null;
        _selectedAvatarBytes = null;

        AppLogger.success('✅ [PROFILE] Avatar aggiornato: $newAvatarUrl');
        return {
          'success': true,
          'message': _lastSuccessMessage,
          'avatarUrl': newAvatarUrl
        };
      } else {
        _lastSuccessMessage = result['message'] ?? 'Errore upload';
        AppLogger.error('❌ [PROFILE] Upload fallito: $_lastSuccessMessage');
        return {'success': false, 'message': _lastSuccessMessage};
      }
    } catch (e) {
      AppLogger.error('❌ [PROFILE] Errore upload', e);
      return {'success': false, 'message': 'Errore: $e'};
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
    AppLogger.debug('🧹 [PROFILE] Avatar selezionato cancellato');
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
      AppLogger.debug('📥 [PROFILE] Caricamento profilo per user $userId');
      await _profileService.fetchUserProfile(userId);
      _safeNotify();
      AppLogger.success('✅ [PROFILE] Profilo caricato');
    }
  }

  Future<void> refreshProfile() async {
    AppLogger.debug('🔄 [PROFILE] Refresh profilo');
    if (_isDisposed) return;
    await loadProfile();
  }

  Future<void> logout() async {
    if (_isDisposed) return;

    try {
      AppLogger.debug('🚪 [PROFILE] Logout');
      await _authService.logout();
      _profileService.clearProfile();
      _selectedAvatarXFile = null;
      _selectedAvatarBytes = null;
      _lastSuccessMessage = null;
      _safeNotify();
      AppLogger.success('✅ [PROFILE] Logout completato');
    } catch (e) {
      AppLogger.error('❌ [PROFILE] Errore logout', e);
      if (!_isDisposed) rethrow;
    }
  }

  void retry() {
    if (_isDisposed) return;
    AppLogger.debug('🔄 [PROFILE] Retry');
    _profileService.retry();
    _safeNotify();
  }

  // ================ TAB MANAGEMENT ================

  void selectTab(int index) {
    if (_isDisposed) return;
    AppLogger.debug(
        '📌 [PROFILE] Tab selezionato: $index (${index == 0 ? "Le Mie Ricette" : "Preferiti"})');
    _selectedTabIndex = index;
    _safeNotify();
  }

  // ================ UTILITY ================

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

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
