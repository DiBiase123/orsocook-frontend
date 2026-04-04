import 'package:flutter/foundation.dart';

class Config {
  static String get environment {
    if (kIsWeb) {
      return 'prod';
    }
    if (kDebugMode) {
      return 'local';
    }
    return 'prod';
  }

  static const Map<String, String> apiUrls = {
    'dev': 'http://10.0.2.2:5000',
    'local': 'http://localhost:5000',
    'prod': 'https://orsocook-backend.onrender.com', // ← URL corretto di Render
  };

  static String? _cachedApiBaseUrl;

  static String get apiBaseUrl {
    if (_cachedApiBaseUrl != null) {
      return _cachedApiBaseUrl!;
    }

    final url = apiUrls[environment];
    if (url == null) {
      throw Exception('Ambiente "$environment" non configurato');
    }

    if (kDebugMode) {
      debugPrint('🔧 Config: ambiente "$environment" -> $url');
    }

    _cachedApiBaseUrl = url;
    return url;
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
