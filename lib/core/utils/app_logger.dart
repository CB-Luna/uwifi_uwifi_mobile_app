import 'dart:developer' as developer;

/// Utilidad para logging en la aplicación
class AppLogger {
  static const String _prefix = '🎬 UWIFI';

  /// Log general de información
  static void info(String message) {
    developer.log('$_prefix INFO: $message');
  }

  /// Log de errores
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      '$_prefix ERROR: $message',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log específico para videos
  static void videoInfo(String message) {
    developer.log('$_prefix 📹 VIDEO: $message');
  }

  /// Log de errores específico para videos
  static void videoError(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    developer.log(
      '$_prefix 📹 VIDEO ERROR: $message',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log de advertencias específico para videos
  static void videoWarning(String message) {
    developer.log('$_prefix 📹 VIDEO WARNING: $message');
  }

  /// Log específico para categorías
  static void categoryInfo(String message) {
    developer.log('$_prefix 🏷️ CATEGORY: $message');
  }

  /// Log específico para autenticación
  static void authInfo(String message) {
    developer.log('$_prefix 🔐 AUTH: $message');
  }

  /// Log de errores específico para autenticación
  static void authError(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    developer.log(
      '$_prefix 🔐 AUTH ERROR: $message',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log de advertencias específico para autenticación
  static void authWarning(String message) {
    developer.log('$_prefix 🔐 AUTH WARNING: $message');
  }

  /// Log específico para red/API
  static void networkInfo(String message) {
    developer.log('$_prefix 🌐 NETWORK: $message');
  }

  /// Log específico para navegación
  static void navInfo(String message) {
    developer.log('$_prefix 🧭 NAV: $message');
  }

  /// Log de errores específico para navegación
  static void navError(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    developer.log(
      '$_prefix 🧭 NAV ERROR: $message',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log específico para onboarding
  static void onboardingInfo(String message) {
    developer.log('$_prefix 🚀 ONBOARDING: $message');
  }

  /// Log de errores específico para onboarding
  static void onboardingError(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    developer.log(
      '$_prefix 🚀 ONBOARDING ERROR: $message',
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log específico para caché
  static void cacheInfo(String message) {
    developer.log('$_prefix 💾 CACHE: $message');
  }
}
