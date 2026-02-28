// lib/config.dart - CONFIGURAZIONE DINAMICA

import 'package:flutter/foundation.dart';

class Config {
  // 🔧 AMBIENTE DINAMICO (cambia in base a debug/production)
  static String get environment {
    if (kDebugMode) {
      return 'local'; // Sviluppo locale
    }
    return 'prod'; // Produzione
  }

  static const Map<String, String> apiUrls = {
    'dev': 'http://10.0.2.2:5000', // Per emulatore Android
    'local': 'http://localhost:5000', // Per sviluppo locale
    'prod': 'https://orsocook-api.onrender.com', // Produzione
  };

  static String get apiBaseUrl {
    final url = apiUrls[environment];
    if (url == null) {
      throw Exception('Ambiente "$environment" non configurato');
    }
    print('🔧 Config: usando ambiente "$environment" -> $url'); // 👈 LOG
    return url;
  }

  // 🛠️ METODO buildUrl con parametro OPZIONALE
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

  // 🛠️ METODO buildApiUrl per API
  static String buildApiUrl(String endpoint) {
    return buildUrl('/api/$endpoint');
  }
}
