import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/config.dart';

class LikeService extends ChangeNotifier {
  // Dipendenza su AuthService
  final AuthService _authService;

  // Cache locale dei likes con timestamp
  final Map<String, int> _likesCountCache = {};
  final Map<String, bool> _likedStatusCache = {};
  final Map<String, DateTime> _likesCountTimestamp = {};
  final Map<String, DateTime> _likedStatusTimestamp = {};

  // Cache delle richieste in corso per evitare duplicati
  final Set<String> _pendingRequests = {};

  // Tempo di validità della cache (5 minuti)
  static const Duration _cacheValidity = Duration(minutes: 5);

  // Lista di listener per aggiornamenti like
  final List<Function(String, bool)> _likeUpdateListeners = [];

  // Stati
  final bool _isLoading = false;
  String? _error;

  // Costruttore che riceve AuthService
  LikeService(this._authService);

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================
  // LISTENER MANAGEMENT
  // ============================================

  // Aggiungi un listener per aggiornamenti like
  void addLikeUpdateListener(Function(String recipeId, bool isLiked) listener) {
    if (!_likeUpdateListeners.contains(listener)) {
      _likeUpdateListeners.add(listener);
      AppLogger.debug(
          '📡 LikeService: Listener aggiunto, totali: ${_likeUpdateListeners.length}');
    }
  }

  // Rimuovi un listener
  void removeLikeUpdateListener(Function(String, bool) listener) {
    _likeUpdateListeners.remove(listener);
    AppLogger.debug(
        '📡 LikeService: Listener rimosso, totali: ${_likeUpdateListeners.length}');
  }

  // Notifica tutti i listener
  void _notifyLikeUpdate(String recipeId, bool isLiked) {
    AppLogger.debug(
        '📢 LikeService: Notificando ${_likeUpdateListeners.length} listener(s) per $recipeId -> $isLiked');

    for (final listener in _likeUpdateListeners) {
      try {
        listener(recipeId, isLiked);
      } catch (e) {
        AppLogger.error('Errore in like update listener', e);
      }
    }
  }

  // ============================================
  // METODI DI UTILITY
  // ============================================

  // Verifica se la cache è ancora valida
  bool _isCacheValid(DateTime? timestamp) {
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheValidity;
  }

  // ============================================
  // METODI PUBBLICI
  // ============================================

  // Verifica se una ricetta è stata messa like dall'utente
  bool isLiked(String recipeId) {
    return _likedStatusCache[recipeId] ?? false;
  }

  // Ottieni il conteggio likes per una ricetta
  int getLikesCount(String recipeId) {
    return _likesCountCache[recipeId] ?? 0;
  }

  // Pre-carica i likes count per una lista di ricette
  Future<void> preloadLikesCount(List<String> recipeIds) async {
    if (recipeIds.isEmpty) return;

    AppLogger.debug(
        '📥 Preloading likes count for ${recipeIds.length} recipes');

    try {
      // Filtra solo le ricette non in cache o con cache scaduta
      final recipesToLoad = recipeIds.where((id) {
        // Se c'è già una richiesta in corso per questo ID, salta
        if (_pendingRequests.contains(id)) {
          AppLogger.debug('⏳ Richiesta già in corso per $id, salto');
          return false;
        }

        final hasCount = _likesCountCache.containsKey(id);
        final hasStatus = _likedStatusCache.containsKey(id);
        final countTimestamp = _likesCountTimestamp[id];
        final statusTimestamp = _likedStatusTimestamp[id];

        // Se entrambi sono in cache e validi, non serve ricaricare
        if (hasCount &&
            hasStatus &&
            _isCacheValid(countTimestamp) &&
            _isCacheValid(statusTimestamp)) {
          return false;
        }

        return true;
      }).toList();

      if (recipesToLoad.isEmpty) {
        AppLogger.debug('✅ All likes counts already cached and valid');
        return;
      }

      AppLogger.debug('📊 Need to load ${recipesToLoad.length} likes counts');

      // Marca come pending per evitare doppie richieste
      for (final id in recipesToLoad) {
        _pendingRequests.add(id);
      }

      // Carica i counts in parallelo
      await Future.wait(
        recipesToLoad.map((recipeId) => getLikesCountFromAPI(recipeId)),
      );

      // Carica anche gli stati liked per quelli nuovi
      await Future.wait(
        recipesToLoad.map((recipeId) => checkLiked(recipeId)),
      );

      AppLogger.success(
          '✅ Likes count preloaded for ${recipesToLoad.length} recipes');
    } catch (e) {
      AppLogger.error('Error preloading likes count', e);
    } finally {
      // Rimuovi i pending
      for (final id in recipeIds) {
        _pendingRequests.remove(id);
      }
    }
  }

  // Ottieni likes count da API (pubblico)
  Future<int> getLikesCountFromAPI(String recipeId) async {
    // Se già in cache e valido, restituisci cache
    if (_isCacheValid(_likesCountTimestamp[recipeId])) {
      return _likesCountCache[recipeId] ?? 0;
    }

    AppLogger.api('GET /api/recipes/$recipeId/likes');

    try {
      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/recipes/$recipeId/likes'),
      );

      AppLogger.debug('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final count = data['data']?['count'] ?? 0;

        AppLogger.debug('✅ Final count for $recipeId: $count');

        // Aggiorna cache e timestamp
        _likesCountCache[recipeId] = count;
        _likesCountTimestamp[recipeId] = DateTime.now();

        return count;
      } else {
        throw Exception('Failed to get likes count: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error getting likes count', e);
      rethrow;
    }
  }

  // Controlla se l'utente ha messo like (privato)
  Future<Map<String, dynamic>> checkLiked(String recipeId) async {
    // Se già in cache e valido, restituisci cache
    if (_isCacheValid(_likedStatusTimestamp[recipeId])) {
      return {'liked': _likedStatusCache[recipeId] ?? false, 'likedAt': null};
    }

    try {
      if (!_authService.isLoggedIn) {
        _likedStatusCache[recipeId] = false;
        _likedStatusTimestamp[recipeId] = DateTime.now();
        return {'liked': false, 'likedAt': null};
      }

      AppLogger.api('GET /api/recipes/$recipeId/liked');

      final authHeaders = await _authService.getAuthHeaders();

      final response = await http.get(
        Uri.parse('${Config.apiBaseUrl}/api/recipes/$recipeId/liked'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final likedStatus = data['data']?['liked'] ?? false;

        AppLogger.debug('Recipe $recipeId liked status from API: $likedStatus');

        // Aggiorna cache e timestamp
        _likedStatusCache[recipeId] = likedStatus;
        _likedStatusTimestamp[recipeId] = DateTime.now();
        notifyListeners();

        return {'liked': likedStatus, 'likedAt': null};
      } else {
        throw Exception('Failed to check liked status: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error checking liked status', e);
      return {'liked': false, 'likedAt': null};
    }
  }

  // ============================================
  // METODI PER AGGIUNTA/RIMOZIONE LIKE
  // ============================================

  // Aggiorna la conta likes dal backend (REALE)
  Future<int> _refreshLikesCount(String recipeId) async {
    try {
      AppLogger.debug('🔄 Aggiornamento conta likes per $recipeId da API');
      final count = await getLikesCountFromAPI(recipeId);
      _likesCountCache[recipeId] = count;
      _likesCountTimestamp[recipeId] = DateTime.now();
      AppLogger.debug('✅ Nuova conta likes per $recipeId: $count');
      return count;
    } catch (e) {
      AppLogger.error('❌ Errore aggiornamento conta likes', e);
      return _likesCountCache[recipeId] ?? 0;
    }
  }

  // Aggiungi like
  Future<bool> addLike(String recipeId) async {
    AppLogger.api('POST /api/recipes/$recipeId/like');

    try {
      if (!_authService.isLoggedIn) {
        throw Exception('Utente non autenticato');
      }
      final authHeaders = await _authService.getAuthHeaders();

      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/api/recipes/$recipeId/like'),
        headers: authHeaders,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        AppLogger.debug('Add like response: $data');

        // 1. Aggiorna cache stato liked
        _likedStatusCache[recipeId] = true;
        _likedStatusTimestamp[recipeId] = DateTime.now();

        // 2. OTTIENI CONTA REALE DAL BACKEND
        await _refreshLikesCount(recipeId);

        AppLogger.success('✅ Like aggiunto a ricetta $recipeId');

        // 3. Notifica UI
        notifyListeners();

        // 4. Notifica altri servizi
        _notifyLikeUpdate(recipeId, true);

        return true;
      } else {
        throw Exception('Failed to add like: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error adding like', e);
      rethrow;
    }
  }

  // Rimuovi like
  Future<bool> removeLike(String recipeId) async {
    AppLogger.api('DELETE /api/recipes/$recipeId/like');

    try {
      if (!_authService.isLoggedIn) {
        throw Exception('Utente non autenticato');
      }

      final authHeaders = await _authService.getAuthHeaders();

      final response = await http.delete(
        Uri.parse('${Config.apiBaseUrl}/api/recipes/$recipeId/like'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        AppLogger.debug('Remove like response: $data');

        // 1. Aggiorna cache stato liked
        _likedStatusCache[recipeId] = false;
        _likedStatusTimestamp[recipeId] = DateTime.now();

        // 2. OTTIENI CONTA REALE DAL BACKEND
        await _refreshLikesCount(recipeId);

        AppLogger.success('✅ Like rimosso da ricetta $recipeId');

        // 3. Notifica UI
        notifyListeners();

        // 4. Notifica altri servici
        _notifyLikeUpdate(recipeId, false);

        return true;
      } else {
        throw Exception('Failed to remove like: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error removing like', e);
      rethrow;
    }
  }

  // Toggle like
  Future<bool> toggleLike(String recipeId) async {
    final isCurrentlyLiked = isLiked(recipeId);

    try {
      if (isCurrentlyLiked) {
        return await removeLike(recipeId);
      } else {
        return await addLike(recipeId);
      }
    } catch (e) {
      AppLogger.error('Error toggling like', e);
      rethrow;
    }
  }

  // Svuota cache
  void clearCache() {
    _likesCountCache.clear();
    _likedStatusCache.clear();
    _likesCountTimestamp.clear();
    _likedStatusTimestamp.clear();
    _pendingRequests.clear();
    notifyListeners();
  }
}
