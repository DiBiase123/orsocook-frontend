// lib/config.dart - CONFIGURAZIONE DINAMICA

import 'package:flutter/foundation.dart';

class Config {
  // 🔧 FORZATO SU PRODUZIONE (Render)
  static const String _forcedApiUrl = 'https://orsocook-api.onrender.com';

  static String? _cachedApiBaseUrl;

  static String get apiBaseUrl {
    if (_cachedApiBaseUrl != null) {
      return _cachedApiBaseUrl!;
    }

    _cachedApiBaseUrl = _forcedApiUrl;

    if (kDebugMode) {
      debugPrint('🔧 Config: API URL -> $_cachedApiBaseUrl');
    }

    return _cachedApiBaseUrl!;
  }

  static String buildUrl([String endpoint = '']) {
    final base = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;

    if (endpoint.isEmpty) {
      return base;
    }

    final path = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$base/$path';
  }

  static String buildApiUrl(String endpoint) {
    return buildUrl('/api/$endpoint');
  }
}
