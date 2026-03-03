import 'dart:async';
import 'package:flutter/material.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/utils/logger.dart';

class ActivityTracker extends ChangeNotifier {
  static const _inactivityTimeout = Duration(minutes: 15);
  static const _refreshInterval = Duration(minutes: 5);

  Timer? _inactivityTimer;
  Timer? _refreshTimer;
  final AuthService _authService;

  ActivityTracker(this._authService) {
    _startTimers();
    _setupListeners();
  }

  void _setupListeners() {
    // Listener per tocchi usando Listener widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Non possiamo usare GestureBinding direttamente,
      // useremo un approccio diverso
    });
  }

  // Metodo pubblico da chiamare quando c'è attività utente
  void reportUserActivity() {
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityTimeout, _logout);
    AppLogger.debug('⏱️ Timer inattività resettato');
  }

  void _startTimers() {
    _resetInactivityTimer();

    // Refresh timer
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _refreshToken();
    });
  }

  Future<void> _refreshToken() async {
    if (!_authService.isLoggedIn) return;

    AppLogger.debug('🔄 Refresh automatico token');
    await _authService.refreshToken();
  }

  Future<void> _logout() async {
    if (!_authService.isLoggedIn) return;

    AppLogger.warning('🚪 Logout per inattività (15 min)');
    await _authService.logout();
    notifyListeners();
  }

  void dispose() {
    _inactivityTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
}
