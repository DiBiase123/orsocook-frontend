import 'dart:async';
import 'package:flutter/material.dart';
import 'package:orsocook/services/auth_service.dart';
import 'package:orsocook/services/logout_manager.dart';
import 'package:orsocook/utils/logger.dart';
import 'package:orsocook/navigation/go_router.dart';

class ActivityTracker extends ChangeNotifier {
  static const _inactivityTimeout = Duration(minutes: 15);
  static const _refreshInterval = Duration(minutes: 5);

  Timer? _inactivityTimer;
  Timer? _refreshTimer;
  final AuthService _authService;
  final GlobalKey<NavigatorState> _navigatorKey;

  ActivityTracker(this._authService, this._navigatorKey) {
    _startTimers();
  }

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

    final context = _navigatorKey.currentContext;

    if (context != null && context.mounted) {
      LogoutManager.performLogout(context);
    } else {
      await _authService.logout();
      goRouter.go('/login');
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }
}
