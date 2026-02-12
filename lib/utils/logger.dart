import 'package:flutter/foundation.dart';

/// 🎯 Logger professionale con livelli di verbosità
enum LogLevel {
  none(0), // Nessun log
  error(1), // Solo errori
  warning(2), // Errori + warning
  info(3), // Info importanti
  debug(4), // Debug dettagliato
  verbose(5); // Tutto (massima verbosità)

  final int level;
  const LogLevel(this.level);
}

/// 📍 Logger configurabile per l'app Ricette
class AppLogger {
  // 🔧 LIVELLO DI LOG CONFIGURABILE
  static LogLevel currentLevel = kDebugMode ? LogLevel.info : LogLevel.error;

  // 🔧 Abilita/disabilita categorie specifiche
  static bool showApiLogs = true;
  static bool showWidgetBuildLogs = false;
  static bool showCredentialLogs = false;
  static bool showRecipeStatusLogs = false;

  // 📱 LOG GENERICO
  static void log(String message) {
    _logWithLevel('📱 [APP]', message, LogLevel.info);
  }

  // 🧭 LOG NAVIGAZIONE
  static void navigation(String message) {
    _logWithLevel('🧭 [NAV]', message, LogLevel.info);
  }

  // 🔐 LOG AUTENTICAZIONE
  static void auth(String message) {
    _logWithLevel('🔐 [AUTH]', message, LogLevel.info);
  }

  // 🍳 LOG RICETTE
  static void recipe(String message) {
    _logWithLevel('🍳 [RECIPE]', message, LogLevel.info);
  }

  // 📡 LOG API/RETE
  static void api(String message) {
    if (showApiLogs) {
      _logWithLevel('📡 [API]', message, LogLevel.debug);
    }
  }

  // ⚠️ LOG ERRORI
  static void error(String message, [dynamic error]) {
    final fullMessage = '$message${error != null ? ": $error" : ""}';
    _logWithLevel('❌ [ERROR]', fullMessage, LogLevel.error);
  }

  // 🔧 LOG DEBUG
  static void debug(String message) {
    _logWithLevel('🔧 [DEBUG]', message, LogLevel.debug);
  }

  // 🔧 LOG DEBUG WIDGET BUILD
  static void widgetBuild(String widgetName) {
    if (showWidgetBuildLogs) {
      _logWithLevel('🏗️ [WIDGET]', 'Building $widgetName', LogLevel.verbose);
    }
  }

  // 🔧 LOG CREDENZIALI
  static void credentials(String message) {
    if (showCredentialLogs) {
      _logWithLevel('🔑 [CRED]', message, LogLevel.verbose);
    }
  }

  // 🔧 LOG STATO RICETTA
  static void recipeStatus(String recipeId, String status) {
    if (showRecipeStatusLogs) {
      _logWithLevel(
          '📊 [RECIPE-STATUS]', 'Recipe $recipeId $status', LogLevel.verbose);
    }
  }

  // ✅ LOG SUCCESSO
  static void success(String message) {
    _logWithLevel('✅ [SUCCESS]', message, LogLevel.info);
  }

  // 🖼️ LOG IMMAGINI
  static void image(String message) {
    _logWithLevel('🖼️ [IMAGE]', message, LogLevel.debug);
  }

  // ⚠️ LOG WARNING
  static void warning(String message) {
    _logWithLevel('⚠️ [WARNING]', message, LogLevel.warning);
  }

  // 🔧 METODO PRIVATO PER LOG CON LIVELLO
  static void _logWithLevel(
      String prefix, String message, LogLevel requiredLevel) {
    if (kDebugMode && currentLevel.level >= requiredLevel.level) {
      debugPrint('$prefix $message');
    }
  }

  // 🔧 CONFIGURAZIONE RAPIDA
  static void setProductionMode() {
    currentLevel = LogLevel.error;
    showApiLogs = false;
    showWidgetBuildLogs = false;
    showCredentialLogs = false;
    showRecipeStatusLogs = false;
  }

  static void setDevelopmentMode() {
    currentLevel = LogLevel.info;
    showApiLogs = true;
    showWidgetBuildLogs = false;
    showCredentialLogs = false;
    showRecipeStatusLogs = false;
  }

  static void setVerboseMode() {
    currentLevel = LogLevel.verbose;
    showApiLogs = true;
    showWidgetBuildLogs = true;
    showCredentialLogs = true;
    showRecipeStatusLogs = true;
  }
}
